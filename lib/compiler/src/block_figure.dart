/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

import 'block.dart';

MbclLevelItem processFigure(Block block) {
  var figure = MbclLevelItem(MbclLevelItemType.figure);
  var data = MbclFigureData();
  figure.figureData = data;
  for (var part in block.parts) {
    switch (part.name) {
      case 'global':
        if (part.lines.join('\n').trim().isNotEmpty) {
          figure.error +=
              'Some of your code is not inside a tag (e.g. "@code")';
        }
        break;
      case 'caption':
        {
          var captionText = block.compiler.parseParagraph(
            part.lines.join('\n'),
          );
          if (captionText.length != 1 ||
              captionText[0].type != MbclLevelItemType.paragraph) {
          } else {
            data.caption.add(captionText[0]);
          }
        }
        break;
      case 'code':
        {
          data.code = part.lines.join('\n');
          // TODO: stop in case of infinite loops after some seconds!
          //var code = part.lines.join('\n');
          try {
            var parser = smpl_parser.Parser();
            parser.parse(data.code);
            var ic = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
            var interpreter = smpl_interpreter.Interpreter();
            var symbols = interpreter.runProgram(ic);
            if (symbols.containsKey('__figure') == false) {
              figure.error += 'Code does generate a figure.';
            } else {
              var figureSymbol =
                  symbols['__figure'] as smpl_interpreter.InterpreterSymbol;
              data.data = figureSymbol.value.text;
            }
          } catch (e) {
            figure.error += e.toString();
          }
        }
        break;
      case 'path':
        if (part.lines.length != 1) {
          figure.error += 'Invalid figure path.';
        } else {
          /*// TODO: check if path exists!
            var line = part.lines[0].trim();
            if (line.startsWith('#')) {
              var variableId = line.substring(1);
              if (plotData.containsKey(variableId)) {
                data.data = plotData[variableId] as String;
              } else {
                figure.error += 'non-existing variable $line';
              }
            } else {*/
          data.filePath = block.compiler.baseDirectory + part.lines[0].trim();
          data.data = block.compiler.loadFile(data.filePath);
          if (data.data.isEmpty) {
            figure.error +=
                'Could not load image file from path "${data.filePath}".';
          }
        }
        break;
      case 'options':
        for (var line in part.lines) {
          line = line.trim();
          if (line.isEmpty) continue;
          switch (line) {
            case 'width-100':
              data.options.add(MbclFigureOption.width100);
              break;
            case 'width-75':
              data.options.add(MbclFigureOption.width75);
              break;
            case 'width-66':
              data.options.add(MbclFigureOption.width66);
              break;
            case 'width-50':
              data.options.add(MbclFigureOption.width50);
              break;
            case 'width-33':
              data.options.add(MbclFigureOption.width33);
              break;
            case 'width-25':
              data.options.add(MbclFigureOption.width25);
              break;
            default:
              figure.error += 'Unknown option "$line".';
          }
        }
        break;
      default:
        figure.error += 'Unexpected part "${part.name}".';
        break;
    }
  }
  block.processSubblocks(figure);
  return figure;
}

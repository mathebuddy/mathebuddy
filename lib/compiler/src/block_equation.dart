/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'block.dart';

MbclLevelItem processEquation(Block block, bool numbering) {
  var equation = MbclLevelItem(MbclLevelItemType.equation);
  var data = MbclEquationData();
  equation.equationData = data;
  var equationNumber = "-1";
  if (numbering) {
    equationNumber = block.compiler.equationNumber.toString();
    block.compiler.equationNumber++;
  }
  equation.id = equationNumber;
  equation.title = block.title;
  equation.label = block.label;
  for (var part in block.parts) {
    switch (part.name) {
      case 'options':
        for (var line in part.lines) {
          line = line.trim();
          if (line.isEmpty) continue;
          switch (line) {
            case 'align-left':
              data.options.add(MbclEquationOption.alignLeft);
              break;
            case 'align-center':
              data.options.add(MbclEquationOption.alignCenter);
              break;
            case 'align-right':
              data.options.add(MbclEquationOption.alignRight);
              break;
            case 'align-equals':
              // TODO: do NOT store. create LaTeX-code instead!
              data.options.add(MbclEquationOption.alignEquals);
              break;
            default:
              equation.error += 'Unknown option "$line".';
          }
        }
        break;
      case 'global':
      case 'text':
        {
          List<String> nonEmptyLines = [];
          for (var line in part.lines) {
            if (line.trim().isEmpty) continue;
            nonEmptyLines.add(line);
          }
          equation.text += nonEmptyLines.join('\\\\');
        }
        break;
      default:
        equation.error += 'Unexpected part "${part.name}".';
        break;
    }
  }
  block.processSubblocks(equation);
  return equation;
}

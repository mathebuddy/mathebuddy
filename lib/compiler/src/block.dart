/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

import 'compiler.dart';

/*
---
EXAMPLE Addition of complex numbers @ex:myExample
@options
blub
EQUATION
z_1=1+3i ~~ z_2=2+4i ~~ z_1+z_2=3+7i
---
*/

class BlockPart {
  String name = '';
  List<String> lines = [];
}

class Block {
  String type = '';
  String title = '';
  String label = '';
  List<BlockPart> parts = []; // e.g. "@options ..."
  List<Block> subBlocks = []; // e.g. "EQUATION ..."
  int srcLine = 0;
  List<MbclLevelItem> levelItems = [
    MbclLevelItem(MbclLevelItemType.error, 'Block unprocessed.')
  ];
  final Compiler _compiler;

  Block(this._compiler);

  void process() {
    switch (type) {
      case 'DEFINITION':
        levelItems = [_processDefinition(MbclLevelItemType.defDefinition)];
        break;
      case 'THEOREM':
        levelItems = [_processDefinition(MbclLevelItemType.defTheorem)];
        break;
      case 'LEMMA':
        levelItems = [_processDefinition(MbclLevelItemType.defLemma)];
        break;
      case 'COROLLARY':
        levelItems = [_processDefinition(MbclLevelItemType.defCorollary)];
        break;
      case 'PROPOSITION':
        levelItems = [_processDefinition(MbclLevelItemType.defProposition)];
        break;
      case 'CONJECTURE':
        levelItems = [_processDefinition(MbclLevelItemType.defConjecture)];
        break;
      case 'AXIOM':
        levelItems = [_processDefinition(MbclLevelItemType.defAxiom)];
        break;
      case 'CLAIM':
        levelItems = [_processDefinition(MbclLevelItemType.defClaim)];
        break;
      case 'IDENTITY':
        levelItems = [_processDefinition(MbclLevelItemType.defIdentity)];
        break;
      case 'PARADOX':
        levelItems = [_processDefinition(MbclLevelItemType.defParadox)];
        break;
      case 'LEFT':
        levelItems = [_processTextAlign(MbclLevelItemType.alignLeft)];
        break;
      case 'CENTER':
        levelItems = [_processTextAlign(MbclLevelItemType.alignCenter)];
        break;
      case 'RIGHT':
        levelItems = [_processTextAlign(MbclLevelItemType.alignRight)];
        break;
      case 'EQUATION':
        levelItems = [_processEquation(true)];
        break;
      case 'EQUATION*':
        levelItems = [_processEquation(false)];
        break;
      case 'EXAMPLE':
        levelItems = [_processExample()];
        break;
      case 'EXERCISE':
        levelItems = [_processExercise()];
        break;
      case 'TEXT':
        levelItems = _processText();
        break;
      case 'TABLE':
        levelItems = [_processTable()];
        break;
      case 'FIGURE':
        levelItems = [_processFigure()];
        break;
      case 'NEWPAGE':
        levelItems = [MbclLevelItem(MbclLevelItemType.newPage)];
        break;
      default:
        levelItems = [
          MbclLevelItem(MbclLevelItemType.error, 'Unknown block type "$type".')
        ];
    }
  }

  List<MbclLevelItem> _processText() {
    // this block has no parts
    return _compiler.parseParagraph(
      parts[0].lines.join('\n'),
    );
  }

  MbclLevelItem _processTable() {
    int i;
    var table = MbclLevelItem(MbclLevelItemType.table);
    var data = MbclTableData();
    table.tableData = data;
    table.title = title;
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().isNotEmpty) {
            table.error += 'Some of your code is not inside a tag'
                ' (e.g. "@code" or "@text").';
          }
          break;
        case 'options':
          for (var line in part.lines) {
            line = line.trim();
            if (line.isEmpty) continue;
            switch (line) {
              case 'align-left':
                data.options.add(MbclTableOption.alignLeft);
                break;
              case 'align-center':
                data.options.add(MbclTableOption.alignCenter);
                break;
              case 'align-right':
                data.options.add(MbclTableOption.alignRight);
                break;
              default:
                table.error += 'Unknown option "$line".';
            }
          }
          break;
        case 'text':
          i = 0;
          for (var line in part.lines) {
            line = line.trim();
            // TODO: "&" may also be used in math-mode!!
            var columnStrings = line.split('&');
            var row = MbclTableRow();
            if (i == 0) {
              data.head = row;
            } else {
              data.rows.add(row);
            }
            for (var columnString in columnStrings) {
              var columnText = _compiler.parseParagraph(columnString);
              if (columnText.length != 1 ||
                  columnText[0].type != MbclLevelItemType.paragraph) {
                table.error += 'Table cell is not pure text.';
                row.columns.add(MbclLevelItem(MbclLevelItemType.text, 'error'));
              } else {
                row.columns.add(columnText[0]);
              }
            }
            i++;
          }
          break;
        default:
          table.error += 'Unexpected part "${part.name}".';
          break;
      }
    }
    _processSubblocks(table);
    return table;
  }

  MbclLevelItem _processFigure() {
    var figure = MbclLevelItem(MbclLevelItemType.figure);
    var data = MbclFigureData();
    figure.figureData = data;
    Map<String, String> plotData = {};
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().isNotEmpty) {
            figure.error +=
                'Some of your code is not inside a tag (e.g. "@code")';
          }
          break;
        case 'caption':
          {
            var captionText = _compiler.parseParagraph(
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
            data.filePath = _compiler.baseDirectory + part.lines[0].trim();
            data.data = _compiler.loadFile(data.filePath);
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
    _processSubblocks(figure);
    return figure;
  }

  MbclLevelItem _processEquation(bool numbering) {
    var equation = MbclLevelItem(MbclLevelItemType.equation);
    var data = MbclEquationData();
    equation.equationData = data;
    var equationNumber = "-1";
    if (numbering) {
      equationNumber = _compiler.equationNumber.toString();
      _compiler.equationNumber++;
    }
    equation.id = equationNumber;
    equation.title = title;
    equation.label = label;
    for (var part in parts) {
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
    _processSubblocks(equation);
    return equation;
  }

  MbclLevelItem _processExample() {
    var example = MbclLevelItem(MbclLevelItemType.example);
    example.title = title;
    example.label = label;
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          example.items.addAll(_compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          example.error += 'Unexpected part "${part.name}".';
      }
    }
    _processSubblocks(example);
    return example;
  }

  MbclLevelItem _processTextAlign(MbclLevelItemType type) {
    var align = MbclLevelItem(type);
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          align.items.addAll(_compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          align.error += 'Unexpected part "${part.name}".';
      }
    }
    _processSubblocks(align);
    return align;
  }

  MbclLevelItem _processDefinition(MbclLevelItemType type) {
    var def = MbclLevelItem(type);
    def.title = title;
    def.label = label;
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          def.items.addAll(_compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          def.error += 'Unexpected part "${part.name}".';
      }
    }
    _processSubblocks(def);
    return def;
  }

  MbclLevelItem _processExercise() {
    var exercise = MbclLevelItem(MbclLevelItemType.exercise);
    var data = MbclExerciseData();
    exercise.exerciseData = data;
    exercise.title = title;
    // TODO: must guarantee that no two exercises labels are same in entire course!!
    exercise.label = label;
    if (exercise.label.isEmpty) {
      exercise.label = 'ex${_compiler.createUniqueId().toString()}';
    }
    for (var part in parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().isNotEmpty) {
            exercise.error +=
                'Some of your code is not inside a tag (e.g. "@code" or "@text")';
          }
          break;
        case 'code':
          data.code = part.lines.join('\n');
          // TODO: configure number of instances!
          const numInstances = 3;
          for (var i = 0; i < numInstances; i++) {
            // TODO: repeat if same instance is already drawn
            // TODO: must check for endless loops, e.g. happens if search space is restricted!
            try {
              var parser = smpl_parser.Parser();
              parser.parse(data.code);
              var ic = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
              var interpreter = smpl_interpreter.Interpreter();
              var symbols = interpreter.runProgram(ic);
              if (i == 0) {
                for (var symId in symbols.keys) {
                  var sym =
                      symbols[symId] as smpl_interpreter.InterpreterSymbol;
                  data.variables.add(symId);
                  data.smplOperandType[symId] = sym.value.type.name;
                }
              }
              Map<String, String> instance = {};
              for (var v in data.variables) {
                var sym = symbols[v] as smpl_interpreter.InterpreterSymbol;
                instance[v] = sym.value.toString();
                instance['@$v'] = sym.term.toString();
              }
              data.instances.add(instance);
            } catch (e) {
              exercise.error += 'SMPL-Error: $e\n';
              break;
            }
          }
          break;
        case 'text':
          exercise.items.addAll(_compiler.parseParagraph(
            part.lines.join('\n'),
            exercise,
          ));
          break;
        case 'options':
          for (var line in part.lines) {
            line = line.trim();
            if (line.isEmpty) continue;
            var tokens = line.split(':');
            if (tokens.length != 2) {
              exercise.error += 'Invalid option "$line".';
              continue;
            }
            var optionKey = tokens[0].trim();
            var optionValue = tokens[1].trim();
            switch (optionKey) {
              case 'order':
                {
                  if (optionValue == 'static') {
                    data.staticOrder = true;
                  } else {
                    exercise.error +=
                        'Invalid value "${data.staticOrder}" for option "value';
                  }
                  break;
                }
              case 'solution-variable':
                {
                  data.solutionVariableId = optionValue;
                  break;
                }
              case 'choices':
                {
                  if (int.tryParse(optionValue) == null) {
                    exercise.error +=
                        'Option "choices" requires an integer value.';
                  } else {
                    data.numberOfChoices = int.parse(optionValue);
                  }
                  break;
                }
              default:
                {
                  exercise.error += 'Unknown option: "$line".';
                  break;
                }
            }
            /*if(line == 'static-order') {
              data.staticOrder = true;
            } else if(line.startsWith('choices-')) {
              data.numberOfChoices = 
              //
            } else {
              exercise.error += 'Unknown option "$line".';
            }*/
          }
          break;
        default:
          exercise.error += 'Unknown part "${part.name}".';
          break;
      }
    }
    _processSubblocks(exercise);
    return exercise;
  }

  void _processSubblocks(MbclLevelItem item) {
    for (var sub in subBlocks) {
      sub.process();
      var type = item.type;
      if (type.name.startsWith('def')) type = MbclLevelItemType.defDefinition;
      if (mbclSubBlockWhiteList.containsKey(type) &&
          (mbclSubBlockWhiteList[type] as List<MbclLevelItemType>)
              .contains(sub.levelItems[0].type)) {
        item.items.addAll(sub.levelItems);
      } else {
        item.error += 'Error: Subblock type ${sub.levelItems[0].type.name}'
            ' is not allowed for ${type.name}! ';
      }
    }
  }
}

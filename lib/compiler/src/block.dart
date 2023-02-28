/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smplParser;
import '../../smpl/src/interpreter.dart' as smplInterpreter;

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
    new MbclLevelItem(MbclLevelItemType.error, 'block unprocessed')
  ];
  Compiler _compiler;

  Block(this._compiler);

  void process() {
    switch (this.type) {
      case 'DEFINITION':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defDefinition)
        ];
        break;
      case 'THEOREM':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defTheorem)
        ];
        break;
      case 'LEMMA':
        this.levelItems = [this._processDefinition(MbclLevelItemType.defLemma)];
        break;
      case 'COROLLARY':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defCorollary)
        ];
        break;
      case 'PROPOSITION':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defProposition)
        ];
        break;
      case 'CONJECTURE':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defConjecture)
        ];
        break;
      case 'AXIOM':
        this.levelItems = [this._processDefinition(MbclLevelItemType.defAxiom)];
        break;
      case 'CLAIM':
        this.levelItems = [this._processDefinition(MbclLevelItemType.defClaim)];
        break;
      case 'IDENTITY':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defIdentity)
        ];
        break;
      case 'PARADOX':
        this.levelItems = [
          this._processDefinition(MbclLevelItemType.defParadox)
        ];
        break;
      case 'LEFT':
        this.levelItems = [this._processTextAlign(MbclLevelItemType.alignLeft)];
        break;
      case 'CENTER':
        this.levelItems = [
          this._processTextAlign(MbclLevelItemType.alignCenter)
        ];
        break;
      case 'RIGHT':
        this.levelItems = [
          this._processTextAlign(MbclLevelItemType.alignRight)
        ];
        break;
      case 'EQUATION':
        this.levelItems = [this._processEquation(true)];
        break;
      case 'EQUATION*':
        this.levelItems = [this._processEquation(false)];
        break;
      case 'EXAMPLE':
        this.levelItems = [this._processExample()];
        break;
      case 'EXERCISE':
        this.levelItems = [this._processExercise()];
        break;
      case 'TEXT':
        this.levelItems = this._processText();
        break;
      case 'TABLE':
        this.levelItems = [this._processTable()];
        break;
      case 'FIGURE':
        this.levelItems = [this._processFigure()];
        break;
      case 'NEWPAGE':
        this.levelItems = [new MbclLevelItem(MbclLevelItemType.newPage)];
        break;
      default:
        this.levelItems = [
          new MbclLevelItem(
              MbclLevelItemType.error, 'unknown block type "' + this.type + '"')
        ];
    }
  }

  List<MbclLevelItem> _processText() {
    // this block has no parts
    return this._compiler.parseParagraph(
          this.parts[0].lines.join('\n'),
        );
  }

  MbclLevelItem _processTable() {
    int i;
    var table = new MbclLevelItem(MbclLevelItemType.table);
    var data = new MbclTableData();
    table.tableData = data;
    table.title = this.title;
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().length > 0) {
            table.error +=
                'Some of your code is not inside a tag (e.g. "@code" or "@text")';
          }
          break;
        case 'options':
          for (var line in part.lines) {
            line = line.trim();
            if (line.length == 0) continue;
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
                table.error += 'unknown option "' + line + '"';
            }
          }
          break;
        case 'text':
          i = 0;
          for (var line in part.lines) {
            line = line.trim();
            // TODO: "&" may also be used in math-mode!!
            var columnStrings = line.split('&');
            var row = new MbclTableRow();
            if (i == 0)
              data.head = row;
            else
              data.rows.add(row);
            for (var columnString in columnStrings) {
              var columnText = this._compiler.parseParagraph(columnString);
              if (columnText.length != 1 ||
                  columnText[0].type != MbclLevelItemType.paragraph) {
                table.error += 'table cell is not pure text';
                row.columns
                    .add(new MbclLevelItem(MbclLevelItemType.text, 'error'));
              } else {
                row.columns.add(columnText[0]);
              }
            }
            i++;
          }
          break;
        default:
          table.error += 'unexpected part "' + part.name + '"';
          break;
      }
    }
    _processSubblocks(table);
    return table;
  }

  MbclLevelItem _processFigure() {
    var figure = new MbclLevelItem(MbclLevelItemType.figure);
    var data = new MbclFigureData();
    figure.figureData = data;
    Map<String, String> plotData = {};
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().length > 0)
            figure.error +=
                'Some of your code is not inside a tag (e.g. "@code")';
          break;
        case 'caption':
          {
            var captionText = this._compiler.parseParagraph(
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
            // TODO: stop in case of infinite loops after some seconds!
            var code = part.lines.join('\n');
            try {
              print("ERROR: _processFigure NOT IMPLEMENTED");
              /*var parser = new smplParser.Parser();
              parser.parse(code);
              var ic = parser.getAbstractSyntaxTree() as smplParser.AST_Node;
              var interpreter = new smplInterpreter.Interpreter();
              var symbols = interpreter.runProgram(ic);
              for (var key in symbols.keys) {
                var sym = symbols[key] as smplInterpreter.InterpreterSymbol;
                if (sym.value.type == OperandType.FIGURE_2D) {
                  plotData[sym.id] = sym.value.toString();
                }
              }*/
            } catch (e) {
              figure.error += e.toString();
            }
          }
          break;
        case 'path':
          if (part.lines.length != 1) {
            figure.error += 'invalid path';
          } else {
            // TODO: check if path exists!
            var line = part.lines[0].trim();
            if (line.startsWith('#')) {
              var variableId = line.substring(1);
              if (plotData.containsKey(variableId)) {
                data.data = plotData[variableId] as String;
              } else {
                figure.error += 'non-existing variable ' + line;
              }
            } else {
              data.filePath = line;
            }
          }
          break;
        case 'options':
          for (var line in part.lines) {
            line = line.trim();
            if (line.length == 0) continue;
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
                figure.error += 'unknown option "' + line + '"';
            }
          }
          break;
        default:
          figure.error += 'unexpected part "' + part.name + '"';
          break;
      }
    }
    _processSubblocks(figure);
    return figure;
  }

  MbclLevelItem _processEquation(bool numbering) {
    var equation = new MbclLevelItem(MbclLevelItemType.equation);
    var data = new MbclEquationData();
    equation.equationData = data;
    equation.id = (numbering ? 888 : -1).toString(); // TODO: number
    equation.title = this.title;
    equation.label = this.label;
    for (var part in this.parts) {
      switch (part.name) {
        case 'options':
          for (var line in part.lines) {
            line = line.trim();
            if (line.length == 0) continue;
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
                equation.error += 'unknown option "' + line + '"';
            }
          }
          break;
        case 'global':
        case 'text':
          equation.text += part.lines.join('\\\\');
          break;
        default:
          equation.error += 'unexpected part "' + part.name + '"';
          break;
      }
    }
    _processSubblocks(equation);
    return equation;
  }

  MbclLevelItem _processExample() {
    var example = new MbclLevelItem(MbclLevelItemType.example);
    example.title = this.title;
    example.label = this.label;
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          example.items
              .addAll(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          example.error += 'unexpected part "' + part.name + '"';
      }
    }
    _processSubblocks(example);
    return example;
  }

  MbclLevelItem _processTextAlign(MbclLevelItemType type) {
    var align = new MbclLevelItem(type);
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          align.items
              .addAll(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          align.error += 'unexpected part "' + part.name + '"';
      }
    }
    _processSubblocks(align);
    return align;
  }

  MbclLevelItem _processDefinition(MbclLevelItemType type) {
    var def = new MbclLevelItem(type);
    def.title = this.title;
    def.label = this.label;
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          def.items
              .addAll(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          def.error += 'unexpected part "' + part.name + '"';
      }
    }
    this._processSubblocks(def);
    return def;
  }

  MbclLevelItem _processExercise() {
    var exercise = new MbclLevelItem(MbclLevelItemType.exercise);
    var data = new MbclExerciseData();
    exercise.exerciseData = data;
    exercise.title = this.title;
    // TODO: must guarantee that no two exercises labels are same in entire course!!
    exercise.label = this.label;
    if (exercise.label.length == 0) {
      exercise.label = 'ex' + this._compiler.createUniqueId().toString();
    }
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          if (part.lines.join('\n').trim().length > 0)
            exercise.error +=
                'Some of your code is not inside a tag (e.g. "@code" or "@text")';
          break;
        case 'code':
          data.code = part.lines.join('\n');
          // TODO: configure number of instances!
          const numInstances = 3;
          for (var i = 0; i < numInstances; i++) {
            // TODO: repeat if same instance is already drawn
            // TODO: must check for endless loops, e.g. happens if search space is restricted!
            try {
              var parser = new smplParser.Parser();
              parser.parse(data.code);
              var ic = parser.getAbstractSyntaxTree() as smplParser.AST_Node;
              var interpreter = new smplInterpreter.Interpreter();
              var symbols = interpreter.runProgram(ic);
              if (i == 0) {
                for (var symId in symbols.keys) {
                  var sym = symbols[symId] as smplInterpreter.InterpreterSymbol;
                  data.variables.add(symId);
                  data.smplOperandType___[symId] = sym.value.type.name;
                }
              }
              Map<String, String> instance = {};
              for (var v in data.variables) {
                var sym = symbols[v] as smplInterpreter.InterpreterSymbol;
                instance[v] = sym.value.toString();
                instance['@' + v] = sym.term.toString();
              }
              data.instances.add(instance);
            } catch (e) {
              exercise.error += 'SMPL-Error: ' + e.toString() + '\n';
            }
          }
          break;
        case 'text':
          exercise.items.addAll(this._compiler.parseParagraph(
                part.lines.join('\n'),
                exercise,
              ));
          break;
        default:
          exercise.error += 'unknown part "' + part.name + '"';
          break;
      }
    }
    _processSubblocks(exercise);
    return exercise;
  }

  void _processSubblocks(MbclLevelItem item) {
    for (var sub in this.subBlocks) {
      sub.process();
      if (mbclSubBlockWhiteList.containsKey(item.type) &&
          (mbclSubBlockWhiteList[item.type] as List<MbclLevelItemType>)
              .contains(sub.levelItems[0].type)) {
        item.items.addAll(sub.levelItems);
      } else {
        item.error += 'subblock type ' +
            sub.levelItems[0].type.name +
            ' is not allowed here';
      }
    }
  }
}

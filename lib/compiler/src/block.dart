/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../math-runtime/src/operand.dart';
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
  MBCL_LevelItem levelItem =
      new MBCL_LevelItem(MBCL_LevelItemType.Error, 'block unprocessed');
  Compiler _compiler;

  Block(this._compiler);

  void process() {
    switch (this.type) {
      case 'DEFINITION':
        this.levelItem =
            this._processDefinition(MBCL_LevelItemType.DefDefinition);
        break;
      case 'THEOREM':
        this.levelItem = this._processDefinition(MBCL_LevelItemType.DefTheorem);
        break;
      case 'LEMMA':
        this.levelItem = this._processDefinition(MBCL_LevelItemType.DefLemma);
        break;
      case 'COROLLARY':
        this.levelItem =
            this._processDefinition(MBCL_LevelItemType.DefCorollary);
        break;
      case 'PROPOSITION':
        this.levelItem =
            this._processDefinition(MBCL_LevelItemType.DefProposition);
        break;
      case 'CONJECTURE':
        this.levelItem =
            this._processDefinition(MBCL_LevelItemType.DefConjecture);
        break;
      case 'AXIOM':
        this.levelItem = this._processDefinition(MBCL_LevelItemType.DefAxiom);
        break;
      case 'CLAIM':
        this.levelItem = this._processDefinition(MBCL_LevelItemType.DefClaim);
        break;
      case 'IDENTITY':
        this.levelItem =
            this._processDefinition(MBCL_LevelItemType.DefIdentity);
        break;
      case 'PARADOX':
        this.levelItem = this._processDefinition(MBCL_LevelItemType.DefParadox);
        break;
      case 'LEFT':
        this.levelItem = this._processTextAlign(MBCL_LevelItemType.AlignLeft);
        break;
      case 'CENTER':
        this.levelItem = this._processTextAlign(MBCL_LevelItemType.AlignCenter);
        break;
      case 'RIGHT':
        this.levelItem = this._processTextAlign(MBCL_LevelItemType.AlignRight);
        break;
      case 'EQUATION':
        this.levelItem = this._processEquation(true);
        break;
      case 'EQUATION*':
        this.levelItem = this._processEquation(false);
        break;
      case 'EXAMPLE':
        this.levelItem = this._processExample();
        break;
      case 'EXERCISE':
        this.levelItem = this._processExercise();
        break;
      case 'TEXT':
        this.levelItem = this._processText();
        break;
      case 'TABLE':
        this.levelItem = this._processTable();
        break;
      case 'FIGURE':
        this.levelItem = this._processFigure();
        break;
      case 'NEWPAGE':
        this.levelItem = new MBCL_LevelItem(MBCL_LevelItemType.NewPage);
        break;
      default:
        this.levelItem = new MBCL_LevelItem(
            MBCL_LevelItemType.Error, 'unknown block type "' + this.type + '"');
    }
  }

  MBCL_LevelItem _processText() {
    // this block has no parts
    return this._compiler.parseParagraph(
          (this.parts[0] as BlockPart).lines.join('\n'),
        );
  }

  MBCL_LevelItem _processTable() {
    int i;
    var table = new MBCL_LevelItem(MBCL_LevelItemType.Table);
    var data = new MBCL_TableData();
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
                data.options.add(MBCL_Table_Option.AlignLeft);
                break;
              case 'align-center':
                data.options.add(MBCL_Table_Option.AlignCenter);
                break;
              case 'align-right':
                data.options.add(MBCL_Table_Option.AlignRight);
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
            var row = new MBCL_Table_Row();
            if (i == 0)
              data.head = row;
            else
              data.rows.add(row);
            for (var columnString in columnStrings) {
              var column = this._compiler.parseParagraph(columnString);
              row.columns.add(column);
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

  MBCL_LevelItem _processFigure() {
    var figure = new MBCL_LevelItem(MBCL_LevelItemType.Figure);
    var data = new MBCL_FigureData();
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
          data.caption.add(this._compiler.parseParagraph(
                part.lines.join('\n'),
              ));
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
                data.options.add(MBCL_Figure_Option.Width100);
                break;
              case 'width-75':
                data.options.add(MBCL_Figure_Option.Width75);
                break;
              case 'width-66':
                data.options.add(MBCL_Figure_Option.Width66);
                break;
              case 'width-50':
                data.options.add(MBCL_Figure_Option.Width50);
                break;
              case 'width-33':
                data.options.add(MBCL_Figure_Option.Width33);
                break;
              case 'width-25':
                data.options.add(MBCL_Figure_Option.Width25);
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

  MBCL_LevelItem _processEquation(bool numbering) {
    var equation = new MBCL_LevelItem(MBCL_LevelItemType.Equation);
    var data = new MBCL_EquationData();
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
                data.options.add(MBCL_EquationOption.AlignLeft);
                break;
              case 'align-center':
                data.options.add(MBCL_EquationOption.AlignCenter);
                break;
              case 'align-right':
                data.options.add(MBCL_EquationOption.AlignRight);
                break;
              case 'align-equals':
                // TODO: do NOT store. create LaTeX-code instead!
                data.options.add(MBCL_EquationOption.AlignEquals);
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

  MBCL_LevelItem _processExample() {
    var example = new MBCL_LevelItem(MBCL_LevelItemType.Example);
    example.title = this.title;
    example.label = this.label;
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          example.items
              .add(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          example.error += 'unexpected part "' + part.name + '"';
      }
    }
    _processSubblocks(example);
    return example;
  }

  MBCL_LevelItem _processTextAlign(MBCL_LevelItemType type) {
    var align = new MBCL_LevelItem(type);
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          align.items.add(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          align.error += 'unexpected part "' + part.name + '"';
      }
    }
    _processSubblocks(align);
    return align;
  }

  MBCL_LevelItem _processDefinition(MBCL_LevelItemType type) {
    var def = new MBCL_LevelItem(type);
    def.title = this.title;
    def.label = this.label;
    for (var part in this.parts) {
      switch (part.name) {
        case 'global':
          def.items.add(this._compiler.parseParagraph(part.lines.join("\n")));
          break;
        default:
          def.error += 'unexpected part "' + part.name + '"';
      }
    }
    this._processSubblocks(def);
    return def;
  }

  MBCL_LevelItem _processExercise() {
    var exercise = new MBCL_LevelItem(MBCL_LevelItemType.Exercise);
    var data = new MBCL_ExerciseData();
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
                  data.operandType___[symId] = sym.value.type;
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
          exercise.items.add(this._compiler.parseParagraph(
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

  void _processSubblocks(MBCL_LevelItem item) {
    for (var sub in this.subBlocks) {
      sub.process();
      if (MBCL_SubBlockWhiteList.containsKey(item.type) &&
          (MBCL_SubBlockWhiteList[item.type] as List<MBCL_LevelItemType>)
              .contains(sub.levelItem.type)) {
        item.items.add(sub.levelItem);
      } else {
        item.error +=
            'subblock type ' + sub.levelItem.type.name + ' is not allowed here';
      }
    }
  }
}

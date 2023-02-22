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
import 'level_item.dart';

// TODO: define a "whitelist" for allowed subblocks for each block type. CHECK IF ALLOWED!

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
    return table;
    // TODO
    /*
    table.title = this.title;
    // TODO:for(var k=0; k<this.parts.)
    for (var p of this.parts) {
      if (p instanceof BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            if (part.lines.join('\n').trim().length > 0)
              table.error +=
                'Some of your code is not inside a tag (e.g. "@code" or "@text")';
            break;
          case 'options':
            for (var line of part.lines) {
              line = line.trim();
              if (line.length == 0) continue;
              switch (line) {
                case 'align-left':
                  table.options.add(MBL_Table_Option.AlignLeft);
                  break;
                case 'align-center':
                  table.options.add(MBL_Table_Option.AlignCenter);
                  break;
                case 'align-right':
                  table.options.add(MBL_Table_Option.AlignRight);
                  break;
                default:
                  table.error += 'unknown option "' + line + '"';
              }
            }
            break;
          case 'text':
            i = 0;
            for (var line of part.lines) {
              line = line.trim();
              // TODO: "&" may also be used in math-mode!!
              var columnStrings = line.split('&');
              var row = new MBL_Table_Row();
              if (i == 0) table.head = row;
              else table.rows.push(row);
              for (var columnString of columnStrings) {
                var column = this.compiler.parseParagraph(columnString);
                row.columns.push(column);
              }
              i++;
            }
            break;
          default:
            table.error += 'unexpected part "' + part.name + '"';
            break;
        }
      }
    }
    return table;*/
  }

  MBCL_LevelItem _processFigure() {
    var figure = new MBCL_LevelItem(MBCL_LevelItemType.Figure);
    return figure;
    // TODO!!
    /*var plotData: { [id: string]: string } = {};
    for (var p of this.parts) {
      if (p instanceof BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            if (part.lines.join('\n').trim().length > 0)
              figure.error +=
                'Some of your code is not inside a tag (e.g. "@code")';
            break;
          case 'caption':
            figure.caption = this.compiler.parseParagraph(
              part.lines.join('\n'),
            );
            break;
          case 'code':
            {
              // TODO: stop in case of infinite loops after some seconds!
              var code = part.lines.join('\n');
              try {
                var variables = SMPL.interpret(code);
                for (var v of variables) {
                  if (v.type.base === BaseType.FIGURE_2D) {
                    plotData[v.id] = v.value.toString();
                  }
                }
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
                if (variableId in plotData) {
                  figure.data = plotData[variableId];
                } else {
                  figure.error += 'non-existing variable ' + line;
                }
              } else {
                figure.filePath = line;
              }
            }
            break;
          case 'options':
            for (var line of part.lines) {
              line = line.trim();
              if (line.length == 0) continue;
              switch (line) {
                case 'width-100':
                  figure.options.add(MBL_Figure_Option.Width100);
                  break;
                case 'width-75':
                  figure.options.add(MBL_Figure_Option.Width75);
                  break;
                case 'width-66':
                  figure.options.add(MBL_Figure_Option.Width66);
                  break;
                case 'width-50':
                  figure.options.add(MBL_Figure_Option.Width50);
                  break;
                case 'width-33':
                  figure.options.add(MBL_Figure_Option.Width33);
                  break;
                case 'width-25':
                  figure.options.add(MBL_Figure_Option.Width25);
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
    }
    return figure;*/
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
    for (var sub in this.subBlocks) {
      sub.process();
      equation.items.add(sub.levelItem);
    }
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
    for (var sub in this.subBlocks) {
      sub.process();
      example.items.add(sub.levelItem);
    }
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
    for (var sub in this.subBlocks) {
      sub.process();
      align.items.add(sub.levelItem);
    }
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
    for (var sub in this.subBlocks) {
      sub.process();
      def.items.add(sub.levelItem);
    }
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
          for (var i = 0; i < 3; i++) {
            // TODO: configure number of instances!
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
    return exercise;
  }
}

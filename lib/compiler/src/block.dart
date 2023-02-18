/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'compiler.dart';
import 'data/data.dart';
import 'data/dataDefinition.dart';
import 'data/dataEquation.dart';
import 'data/dataError.dart';
import 'data/dataExample.dart';
import 'data/dataExercise.dart';
import 'data/dataFigure.dart';
import 'data/dataLevel.dart';
import 'data/dataTable.dart';
import 'data/dataText.dart';

class BlockPart {
  String name = '';
  List<String> lines = [];
}

class Block {
  String type = '';
  String title = '';
  String label = '';
  //parts: (MBL_LevelItem | BlockPart)[] = [];
  List<BlockPart> parts = [];
  int srcLine = 0;

  Compiler _compiler;

  Block(this._compiler);

  MBL_LevelItem process() {
    switch (this.type) {
      case 'DEFINITION':
        return this._processDefinition(MBL_DefinitionType.Definition);
      case 'THEOREM':
        return this._processDefinition(MBL_DefinitionType.Theorem);
      case 'LEMMA':
        return this._processDefinition(MBL_DefinitionType.Lemma);
      case 'COROLLARY':
        return this._processDefinition(MBL_DefinitionType.Corollary);
      case 'PROPOSITION':
        return this._processDefinition(MBL_DefinitionType.Proposition);
      case 'CONJECTURE':
        return this._processDefinition(MBL_DefinitionType.Conjecture);
      case 'AXIOM':
        return this._processDefinition(MBL_DefinitionType.Axiom);
      case 'CLAIM':
        return this._processDefinition(MBL_DefinitionType.Claim);
      case 'IDENTITY':
        return this._processDefinition(MBL_DefinitionType.Identity);
      case 'PARADOX':
        return this._processDefinition(MBL_DefinitionType.Paradox);

      case 'LEFT':
      case 'CENTER':
      case 'RIGHT':
        return this._processTextAlign(this.type);

      case 'EQUATION':
        return this._processEquation(true);
      case 'EQUATION*':
        return this._processEquation(false);

      case 'EXAMPLE':
        return this._processExample();

      case 'EXERCISE':
        return this._processExercise();

      case 'TEXT':
        return this._processText();

      case 'TABLE':
        return this._processTable();

      case 'FIGURE':
        return this._processFigure();

      case 'NEWPAGE':
        return new MBL_NewPage();

      default:
        {
          var err = new MBL_Error();
          err.message = 'unknown block type "' + this.type + '"';
          return err;
        }
    }
  }

  MBL_Text _processText() {
    // this block has no parts
    return this._compiler.parseParagraph(
          (this.parts[0] as BlockPart).lines.join('\n'),
        );
  }

  MBL_Table _processTable() {
    int i;
    var table = new MBL_Table();
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

  MBL_Figure _processFigure() {
    var figure = new MBL_Figure();
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

  MBL_Equation _processEquation(bool numbering) {
    var equation = new MBL_Equation();
    return equation;
    // TODO
    /*equation.numbering = numbering ? 888 : -1; // TODO: number
    equation.title = this.title;
    equation.label = this.label;
    for (var p of this.parts) {
      if (p is BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'options':
            for (var line of part.lines) {
              line = line.trim();
              if (line.length == 0) continue;
              switch (line) {
                case 'align-left':
                  equation.options.add(MBL_EquationOption.AlignLeft);
                  break;
                case 'align-center':
                  equation.options.add(MBL_EquationOption.AlignCenter);
                  break;
                case 'align-right':
                  equation.options.add(MBL_EquationOption.AlignRight);
                  break;
                case 'align-equals':
                  // TODO: do NOT store. create LaTeX-code instead!
                  equation.options.add(MBL_EquationOption.AlignEquals);
                  break;
                default:
                  equation.error += 'unknown option "' + line + '"';
              }
            }
            break;
          case 'global':
          case 'text':
            equation.value += part.lines.join('\\\\');
            break;
          default:
            equation.error += 'unexpected part "' + part.name + '"';
            break;
        }
      } else {
        equation.error += 'unexpected sub-block';
      }
    }
    return equation;*/
  }

  MBL_Example _processExample() {
    var example = new MBL_Example();
    return example;
    // TODO
    /*
    example.title = this.title;
    example.label = this.label;
    for (var p of this.parts) {
      if (p instanceof BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            example.items.push(
              this.compiler.parseParagraph(part.lines.join('\n')),
            );
            break;
          default:
            example.error += 'unexpected part "' + part.name + '"';
            break;
        }
      } else {
        // TODO: check if allowed here!!
        example.items.push(p);
      }
    }
    return example;*/
  }

  MBL_Text _processTextAlign(String type) {
    var xxx = new MBL_Text_Text();
    return xxx;
    // TODO
    /*
    var align: MBL_Text_AlignLeft | MBL_Text_AlignCenter | MBL_Text_AlignRight;
    switch (type) {
      case 'LEFT':
        align = new MBL_Text_AlignLeft();
        break;
      case 'CENTER':
        align = new MBL_Text_AlignCenter();
        break;
      case 'RIGHT':
        align = new MBL_Text_AlignRight();
        break;
    }
    for (var p of this.parts) {
      if (p is BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            align.items.push(
              this.compiler.parseParagraph(part.lines.join('\n')),
            );
            break;
        }
      } else {
        // TODO: check if allowed here!!
        align.items.push(p);
      }
    }
    return align;*/
  }

  MBL_Definition _processDefinition(MBL_DefinitionType type) {
    var def = new MBL_Definition(type);
    return def;
    // TODO
    /*def.title = this.title;
    def.label = this.label;
    for (var p of this.parts) {
      if (p is BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            def.items.push(this._compiler.parseParagraph(part.lines.join('\n')));
            break;
          default:
            def.error += 'unexpected part "' + part.name + '"';
            break;
        }
      } else {
        // TODO: check if allowed here!!
        def.items.push(p);
      }
    }
    return def;*/
  }

  MBL_Exercise _processExercise() {
    var exercise = new MBL_Exercise();
    return exercise;
    // TODO
    /*exercise.title = this.title;
    // TODO: must guarantee that no two exercises labels are same in entire course!!
    exercise.label = this.label;
    if (exercise.label.length == 0) {
      exercise.label = 'ex' + this.compiler.createUniqueId();
    }
    for (var p of this.parts) {
      if (p instanceof BlockPart) {
        var part = <BlockPart>p;
        switch (part.name) {
          case 'global':
            if (part.lines.join('\n').trim().length > 0)
              exercise.error =
                'Some of your code is not inside a tag (e.g. "@code" or "@text")';
            break;
          case 'code':
            exercise.code = part.lines.join('\n');
            try {
              for (var i = 0; i < 3; i++) {
                // TODO: configure number of instances!
                // TODO: repeat if same instance is already drawn
                // TODO: must check for endless loops, e.g. happens if search space is restricted!
                var instance = new MBL_Exercise_Instance();
                var variables = SMPL.interpret(exercise.code);
                for (var v of variables) {
                  var ev = new MBL_Exercise_Variable();
                  switch (v.type.base) {
                    case BaseType.BOOL:
                      ev.type = MBL_Exercise_VariableType.Bool;
                      break;
                    case BaseType.INT:
                      ev.type = MBL_Exercise_VariableType.Int;
                      break;
                    case BaseType.REAL:
                      ev.type = MBL_Exercise_VariableType.Real;
                      break;
                    case BaseType.COMPLEX:
                      ev.type = MBL_Exercise_VariableType.Complex;
                      break;
                    case BaseType.TERM:
                      ev.type = MBL_Exercise_VariableType.Term;
                      break;
                    case BaseType.VECTOR:
                      ev.type = MBL_Exercise_VariableType.Vector;
                      break;
                    case BaseType.MATRIX:
                      ev.type = MBL_Exercise_VariableType.Matrix;
                      break;
                    case BaseType.INT_SET:
                      ev.type = MBL_Exercise_VariableType.IntSet;
                      break;
                    case BaseType.REAL_SET:
                      ev.type = MBL_Exercise_VariableType.RealSet;
                      break;
                    case BaseType.COMPLEX_SET:
                      ev.type = MBL_Exercise_VariableType.ComplexSet;
                      break;
                    default:
                      throw Error(
                        'unimplemented: processExercise(..) type ' +
                          v.type.base,
                      );
                  }
                  exercise.variables[v.id] = ev;
                  instance.values[v.id] = v.value.toString();
                }
                exercise.instances.add(instance);
              }
            } catch (e) {
              exercise.error = e.toString();
            }
            break;
          case 'text':
            exercise.text = this._compiler.parseParagraph(
              part._lines.join('\n'),
              exercise,
            );
            break;
          default:
            exercise.error = 'unknown part "' + part.name + '"';
            break;
        }
      } else {
        // TODO: check if allowed here!!
        //TODO: exercise.items.push(p);
      }
    }
    return exercise;*/
  }

  /*void _error(String message) {
    print('' + (this.srcLine + 1).toString() + ': ' + message);
  }*/
}

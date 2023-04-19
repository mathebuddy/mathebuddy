/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

import '../../math-runtime/src/parse.dart' as math_runtime_parse;
import '../../math-runtime/src/term.dart' as math_runtime_term;

import 'block.dart';
import 'exercise.dart';

MbclLevelItem processExercise(Block block) {
  var exercise = MbclLevelItem(MbclLevelItemType.exercise);
  var data = MbclExerciseData(exercise);
  exercise.exerciseData = data;
  exercise.title = block.title;
  // TODO: must guarantee that no two exercises labels are same in entire course!!
  exercise.label = block.label;
  if (exercise.label.isEmpty) {
    exercise.label = 'ex${block.compiler.createUniqueId().toString()}';
  }
  for (var blockItem in block.items) {
    if (blockItem.type == BlockItemType.subBlock) {
      block.processSubblock(exercise, blockItem.subBlock!);
      continue;
    }
    var part = blockItem.part!;
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
        for (var i = 0; i < numberOfInstances; i++) {
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
                var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
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
        exercise.items.addAll(block.compiler.parseParagraph(
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
          var key = tokens[0].trim();
          var value = tokens[1].trim();
          switch (key) {
            case 'order':
              {
                if (value == 'static') {
                  data.staticOrder = true;
                } else {
                  exercise.error += 'Invalid value "${data.staticOrder}"'
                      ' for option "$key';
                }
                break;
              }
            case 'scores':
              {
                if (int.tryParse(value) == null) {
                  exercise.error +=
                      'Option "scores" requires an integer value.';
                } else {
                  data.scores = int.parse(value);
                }
                break;
              }
            case 'show-gap-length':
              {
                if (value == 'true') {
                  data.showGapLength = true;
                } else if (value == 'false') {
                  data.showGapLength = false;
                } else {
                  exercise.error += 'Invalid value "${data.staticOrder}"'
                      ' for option "$key';
                }
                break;
              }
            default:
              {
                exercise.error += 'Unknown option: "$line".';
                break;
              }
          }
        }
        break;
      default:
        if (part.name.startsWith("solution-")) {
          var solutionVariableId = part.name.substring("solution-".length);
          // get corresponding input field data;
          MbclInputFieldData? inputFieldData;
          for (var inputFieldId in data.inputFields.keys) {
            var inputField =
                data.inputFields[inputFieldId] as MbclInputFieldData;
            if (inputField.variableId == solutionVariableId) {
              inputFieldData = inputField;
              break;
            }
          }
          if (inputFieldData == null) {
            exercise.error += 'Invalid "@solution-$solutionVariableId":'
                ' There is no input field.';
          } else {
            for (var line in part.lines) {
              line = line.trim();
              if (line.isEmpty) continue;
              var tokens = line.split(':');
              if (tokens.length != 2) {
                exercise.error += 'Invalid option "$line".';
                continue;
              }
              var key = tokens[0].trim();
              var value = tokens[1].trim();
              switch (key) {
                case 'score':
                  {
                    if (int.tryParse(value) == null) {
                      exercise.error +=
                          'Option "score" requires an integer value.';
                    } else {
                      inputFieldData.score = int.parse(value);
                    }
                    break;
                  }
                case 'choices':
                  {
                    if (int.tryParse(value) == null) {
                      exercise.error +=
                          'Option "choices" requires an integer value.';
                    } else {
                      inputFieldData.choices = int.parse(value);
                      inputFieldData.type = MbclInputFieldType.choices;
                    }
                    break;
                  }
                case 'build-term':
                  {
                    for (var instance in data.instances) {
                      var termStr = instance["@$solutionVariableId"] as String;
                      var parser = math_runtime_parse.Parser();
                      var term = math_runtime_term.Term.createConstInt(0);
                      try {
                        term = parser.parse(termStr);
                        var output = term.generateCorrectAndIncorrectSummands(
                            2); // TODO: constant
                        instance["\$$solutionVariableId.n"] =
                            output.length.toString();
                        for (var i = 0; i < output.length; i++) {
                          var o = output[i];
                          instance["\$$solutionVariableId.$i"] = o.toString();
                        }
                      } catch (e) {
                        exercise.error += "build-term failed";
                      }
                      var bp = 1337;
                    }
                    break;
                  }
                default:
                  {
                    exercise.error += 'Unknown option: "$line".';
                    break;
                  }
              }
            }
          }
        } else {
          exercise.error += 'Unknown part "${part.name}".';
        }
        break;
    }
  }
  return exercise;
}

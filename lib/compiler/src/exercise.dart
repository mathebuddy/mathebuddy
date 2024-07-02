/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_compiler;

import '../../math-runtime/src/operand.dart' as math_operand;

import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/level_item_exercise.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;

import '../../smpl/src/interpreter.dart' as smpl_interpreter;

const maxIterations = 50; // max tries to alter random variables per instance

// TODO: repeat drawing random questions, if same instance is already drawn!!!!!
// TODO: must check for endless loops, e.g. happens if search space is restricted!

// TODO: move exercise related code from block.dart to here

void processExerciseCode(MbclLevelItem exercise) {
  var data = exercise.exerciseData!;
  // stringified instance to check, if same instance has already been drawn.
  List<String> instanceStrings = [];
  // create instances
  var showedMaxIterationError = false;
  for (var i = 0; i < data.numInstances; i++) {
    try {
      var parser = smpl_parser.Parser();
      parser.parse(data.code);
      var ic = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
      var interpreter = smpl_interpreter.Interpreter();
      // run code, until an instance is drawn, that is not yet present.
      Map<String, smpl_interpreter.InterpreterSymbol> symbols = {};
      var symbolsStr = '';
      var k = 0;
      do {
        symbols = interpreter.runProgram(ic);
        symbolsStr = symbols.toString();
        k++;
        if (k > maxIterations) {
          if (showedMaxIterationError == false) {
            exercise.error +=
                ' Failed to generate ${data.numInstances} distinct answers. '
                'Improve randomization, or limit the number of instances '
                '(e.g. INSTANCES=2). ';
            showedMaxIterationError = true;
          }
          break;
        }
      } while (
          data.code.contains("rand") && instanceStrings.contains(symbolsStr));
      instanceStrings.add(symbolsStr);
      //gather variable names and function names
      if (i == 0) {
        for (var symId in symbols.keys) {
          var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
          data.variables.add(symId);
          if (sym.isFunction) data.functionVariables.add(symId);
        }
      }
      // set types
      // TODO: simplify code!!
      for (var symId in symbols.keys) {
        var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
        var setSubType = sym.value.type == math_operand.OperandType.vector &&
            sym.value.items.isNotEmpty; // TODO: matrix, ...
        if (i == 0) {
          // first instance: just set type
          data.smplOperandType[symId] = sym.value.type.name;
          data.smplOperandSubType[symId] =
              setSubType ? sym.value.items[0].type.name : "none";
        } else {
          var currentType = math_operand.OperandType.values
              .byName(data.smplOperandType[symId]!);
          var currentSubType = math_operand.OperandType.values
              .byName(data.smplOperandSubType[symId]!);
          var type = sym.value.type;
          var subType = setSubType
              ? sym.value.items[0].type
              : math_operand.OperandType.none;
          // further instances: check if type is "more mighty" than the
          // type currently set
          if (currentType != type &&
              math_operand.getOperandTypeMightiness(type) >
                  math_operand.getOperandTypeMightiness(currentType)) {
            data.smplOperandType[symId] = type.name;
          }
          if (setSubType &&
              currentSubType != subType &&
              math_operand.getOperandTypeMightiness(subType) >
                  math_operand.getOperandTypeMightiness(currentSubType)) {
            data.smplOperandSubType[symId] = subType.name;
          }
        }
      }
      // fill instances
      Map<String, String> instance = {};
      for (var v in data.variables) {
        var sym = symbols[v] as smpl_interpreter.InterpreterSymbol;
        // pure math
        instance[v] = sym.value.toString();
        instance['@$v'] = sym.term.toString();
        instance['@@$v'] = sym.term.clone().optimize().toString();
        // TeX
        instance['$v.tex'] = sym.value.toTeXString();
        instance['@$v.tex'] = sym.term.toTeXString();
        instance['@@$v.tex'] = sym.term.clone().optimize().toTeXString();
      }
      data.instances.add(instance);
    } catch (e) {
      exercise.error += 'SMPL-Error: $e\n';
      break;
    }
  }
}

String addStaticVariable(
    MbclExerciseData data, math_operand.OperandType type, String value) {
  var varId = '__var__${data.staticVariableCounter}';
  data.staticVariableCounter++;
  data.variables.add(varId);
  data.smplOperandType[varId] = type.name;
  if (data.instances.isEmpty) {
    for (var i = 0; i < data.numInstances; i++) {
      Map<String, String> instance = {};
      data.instances.add(instance);
    }
  }
  for (var i = 0; i < data.numInstances; i++) {
    data.instances[i][varId] = value;
  }
  return varId;
}

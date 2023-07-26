/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../math-runtime/src/operand.dart' as math_operand;

import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

// TODO: move exercise related code from block.dart to here

const numberOfInstances = 5; // TODO!! must be configurable

void processExerciseCode(MbclLevelItem exercise) {
  const numberOfInstances = 5; // TODO!! must be configurable
  var data = exercise.exerciseData!;
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
        // add variables names
        for (var symId in symbols.keys) {
          //var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
          data.variables.add(symId);
        }
      }
      // set types
      for (var symId in symbols.keys) {
        var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
        if (i == 0) {
          // first instance: just set type
          data.smplOperandType[symId] = sym.value.type.name;
        } else {
          var currentType = math_operand.OperandType.values
              .byName(data.smplOperandType[symId]!);
          var type = sym.value.type;
          // further instances: check if type is "more mighty" than the
          // type currently set
          if (currentType != type &&
              math_operand.getOperandTypeMightiness(type) >
                  math_operand.getOperandTypeMightiness(currentType)) {
            data.smplOperandType[symId] = type.name;
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

String addStaticBooleanVariable(MbclExerciseData data, bool value) {
  var varId = '__bool__${data.staticVariableCounter}';
  data.staticVariableCounter++;
  data.variables.add(varId);
  data.smplOperandType[varId] = math_operand.OperandType.boolean.name;
  if (data.instances.isEmpty) {
    for (var i = 0; i < numberOfInstances; i++) {
      Map<String, String> instance = {};
      data.instances.add(instance);
    }
  }
  for (var i = 0; i < numberOfInstances; i++) {
    data.instances[i][varId] = value ? 'true' : 'false';
  }
  return varId;
}

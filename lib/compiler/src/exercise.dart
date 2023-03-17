/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../math-runtime/src/operand.dart';

import '../../mbcl/src/level_item.dart';

// TODO: move exercise related code from block.dart to here

const numberOfInstances = 5; // TODO!! must be configurable

String addStaticBooleanVariable(MbclExerciseData data, bool value) {
  var varId = '__bool__${data.staticVariableCounter}';
  data.staticVariableCounter++;
  data.variables.add(varId);
  data.smplOperandType[varId] = OperandType.boolean.name;
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

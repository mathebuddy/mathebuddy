/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'level_item_exercise.dart';

class MbclInputFieldData {
  // import/export
  MbclInputFieldType type = MbclInputFieldType.none;
  bool isFunction = false;
  String variableId = '';
  String diffVariableId = '';
  int index = -1; // used e.g. for vector element
  int score = 1;
  bool arrange = false;
  bool dynamicRows = false;
  bool dynamicCols = false;
  String forceKeyboardId = "";
  bool choices = false; // data stored in MbclExerciseData.instances
  bool termTokens = false; // data stored in MbclExerciseData.instances
  bool hideLengthOfGap = false;
  bool showAllLettersOfGap = false;

  // temporary
  MbclExerciseData? exerciseData;
  int cursorPos = 0;
  String studentValue = '';
  String expectedValue = '';
  bool correct = true;

  void reset() {
    cursorPos = 0;
    studentValue = "";
  }

  Map<String, dynamic> toJSON() {
    return {
      "type": type.name,
      "isFunction": isFunction,
      "variableId": variableId,
      "diffVariableId": diffVariableId,
      "index": index,
      "score": score,
      "arrange": arrange,
      "dynamicRows": dynamicRows,
      "dynamicCols": dynamicCols,
      "forceKeyboardId": forceKeyboardId,
      "choices": choices,
      "termTokens": termTokens,
      "hideLengthOfGap": hideLengthOfGap,
      "showAllLettersOfGap": showAllLettersOfGap
    };
  }

  fromJSON(Map<String, dynamic> src) {
    type = MbclInputFieldType.values.byName(src["type"]);
    isFunction = src["isFunction"] as bool;
    variableId = src["variableId"] as String;
    diffVariableId = src["diffVariableId"] as String;
    index = src["index"] as int;
    score = src["score"] as int;
    arrange = src["arrange"] as bool;
    dynamicRows = src["dynamicRows"] as bool;
    dynamicCols = src["dynamicCols"] as bool;
    forceKeyboardId = src["forceKeyboardId"] as String;
    choices = src["choices"] as bool;
    termTokens = src["termTokens"] as bool;
    hideLengthOfGap = src["hideLengthOfGap"] as bool;
    showAllLettersOfGap = src["showAllLettersOfGap"] as bool;
  }
}

enum MbclInputFieldType {
  none,
  bool,
  int,
  rational,
  real,
  complexNormal,
  complexPolar,
  complexIntSet,
  intSet,
  intSetNArts,
  vector,
  vectorFlex,
  matrix,
  matrixFlexRows,
  matrixFlexCols,
  matrixFlex,
  term,
  string,
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import '../../math-runtime/src/operand.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';

import 'exercise.dart';
import 'help.dart';

// TODO: update grammar

/// <GRAMMAR>
///   inputElement =
///       "#" ID {"," inputOption}          % ask for variable value
///     | "#" STR {"," inputOption};        % gap question, ask for string
///   inputOption =
///       "DIFF" "=" ID                    % auto-diff solution before check
///     | "SCORE" "=" INT                   % default is 1
///     | "ARRANGE"                         % random vector must be ordered
///     | "ROWS" "=" ("static"|"dynamic")   % default is static
///     | "COLS" "=" ("static"|"dynamic")   % default is static
///     | "KEYBOARD" "=" ID                 % force input keyboard
///     | "CHOICES" "=" INT                 % provides N solutions to select
///                                         %   -1 := no choices
///     | "TOKENS" REAL { "+" STR }         % term-tokens
///     | "HIDE_LENGTH"            % length is shown per default
///     | "SHOW_ALL_LETTERS"       % only required letters are shown per default
/// </GRAMMAR>

MbclLevelItem parseInputElement(
    MbclLevel level, Lexer lexer, int srcRowIdx, MbclLevelItem exercise) {
  lexer.next(); // skip "#"
  var inputField =
      MbclLevelItem(level, MbclLevelItemType.inputField, srcRowIdx);
  var data = MbclInputFieldData();
  inputField.inputFieldData = data;
  inputField.id = 'input${createUniqueId()}';
  var exerciseData = exercise.exerciseData as MbclExerciseData;
  exerciseData.inputFields[inputField.id] = data;
  var isGap = false;
  // reference to a variable from part CODE
  if (lexer.isIdentifier()) {
    data.variableId = lexer.identifier();
  }
  // explicit string -> gap question
  else if (lexer.isString()) {
    isGap = true;
    var gapString = lexer.string();
    data.variableId =
        addStaticVariable(exerciseData, OperandType.string, gapString);
    data.type = MbclInputFieldType.string;
  } else {
    exercise.error += ' No variable for input field given. ';
    return inputField;
  }
  // optional attributes e.g. ",SCORE=", ",DIFF=x", ...
  Map<String, String> attributes = {};
  while (lexer.isTerminal(",")) {
    lexer.next();
    var key = lexer.getToken().token.trim();
    lexer.next();
    var value = "";
    if (lexer.isTerminal("=")) {
      lexer.next();
      value = lexer.getToken().token.trim();
      lexer.next();
      while (lexer.isTerminal("+")) {
        value += "+";
        lexer.next();
        value += lexer.getToken().token.trim(); // TODO: "+" could be within STR
        lexer.next();
      }
    }
    if (value.isEmpty) value = "true";
    attributes[key] = value;
  }
  try {
    // TODO: check semantics!!
    checkAttributes(attributes, [
      "DIFF",
      "SCORE",
      "ARRANGE",
      "ROWS",
      "COLS",
      "KEYBOARD",
      "CHOICES",
      "TOKENS",
      "HIDE_LENGTH",
      "SHOW_ALL_LETTERS",
    ]);
    data.diffVariableId = "";
    if (hasAttribute(attributes, "DIFF")) {
      data.diffVariableId = getAttributeIdentifier(attributes, "DIFF");
    }
    data.score = getAttributeInt(attributes, "SCORE", 1);
    data.arrange = getAttributeBool(attributes, "ARRANGE", false);
    data.dynamicRows = getAttributeString(
            attributes, "ROWS", ["dynamic", "static"], "static") ==
        "dynamic";
    data.dynamicCols = getAttributeString(
            attributes, "COLS", ["dynamic", "static"], "static") ==
        "dynamic";
    data.forceKeyboardId = getAttributeIdentifier(attributes, "KEYBOARD");
    data.numChoices = getAttributeInt(attributes, "CHOICES", -1);
    // TODO: var tokens = ;
    data.hideLengthOfGap = getAttributeBool(attributes, "HIDE_LENGTH", false);
    data.showAllLettersOfGap =
        getAttributeBool(attributes, "SHOW_ALL_LETTERS", false);
  } catch (e) {
    exercise.error += e.toString();
  }
  // TODO: remove old src
  // while (lexer.isTerminal(",")) {
  //   var key = "", value = "";
  //   lexer.next();
  //   key = lexer.getToken().token;
  //   lexer.next();
  //   if (lexer.isTerminal("=")) {
  //     lexer.next();
  //     value = lexer.getToken().token.trim();
  //     lexer.next();
  //   }
  //   switch (key) {
  //     case "SCORE":
  //       {
  //         try {
  //           data.score = int.parse(value);
  //         } catch (e) {
  //           exercise.error += ' Score value must be integral. ';
  //         }
  //         break;
  //       }
  //     case "DIFF":
  //       {
  //         data.diffVariableId = value; // TODO: check, if string is valid
  //         break;
  //       }
  //     default:
  //       {
  //         exercise.error += ' Unknown key $key. ';
  //       }
  //   }
  // }
  // check if variable exists
  if (exerciseData.variables.contains(data.variableId) == false) {
    exercise.error += ' Variable "${data.variableId}" is unknown'
        ' (you may need to declare it with "let"). ';
    return inputField;
  }
  // optional: index (e.g. element of a vector)
  if (lexer.isTerminal("[")) {
    lexer.next();
    if (lexer.isInteger()) {
      data.index = lexer.integer();
    } else {
      exercise.error += ' Index must be a constant integer value. '
          'Current value is ${lexer.getToken().token}. ';
      return inputField;
    }
    if (lexer.isTerminal("]")) {
      lexer.next();
    } else {
      exercise.error += " Indexing must be ended with ']'. ";
      return inputField;
    }
  }
  // ===== gap input =====
  if (isGap) {
    return inputField;
  }
  // ===== term input =====
  else if (exerciseData.functionVariables.contains(data.variableId)) {
    data.type = MbclInputFieldType.term;
    data.isFunction = true;
    return inputField;
  }
  // ===== operand input =====
  else {
    // get type and subtype. The subtype refers to indexed types (e.g. the type
    // is "vector" and the subType "integer".)
    var opType = OperandType.values
        .byName(exerciseData.smplOperandType[data.variableId] as String);
    var opSubType = OperandType.values
        .byName(exerciseData.smplOperandSubType[data.variableId] as String);
    // in case of indexing: the actual type is the subType
    if (data.index >= 0) {
      if (opType != OperandType.vector) {
        // TODO: matrix, ...
        exercise.error += " Indexing not allowed here. ";
        return inputField;
      }
      opType = opSubType;
    }
    // set the input field type, based on the type of the references variable
    switch (opType) {
      case OperandType.int:
        data.type = MbclInputFieldType.int;
        break;
      case OperandType.rational:
        data.type = MbclInputFieldType.rational;
        break;
      case OperandType.real:
      case OperandType.irrational: // TODO!!
        data.type = MbclInputFieldType.real;
        break;
      case OperandType.complex:
        data.type = MbclInputFieldType.complexNormal;
        break;
      case OperandType.matrix:
        data.type = MbclInputFieldType.matrix;
        break;
      case OperandType.set:
        // TODO: intSet, realSet, termSet, complexIntSet, ...
        data.type = MbclInputFieldType.complexIntSet;
        break;
      default:
        exercise.error += ' UNIMPLEMENTED input type ${opType.name}. ';
    }
    return inputField;
  }
}

/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_compiler;

import 'package:slex/slex.dart';

import '../../math-runtime/src/operand.dart';
import '../../math-runtime/src/parse.dart';
import '../../math-runtime/src/term.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/level_item_input_field.dart';

import 'exercise.dart';
import 'help.dart';

// TODO: update grammar

/// <GRAMMAR>
///   inputElement =
///       "#" ID {"," inputOption}          % ask for variable value
///     | "#" STR { !";" "," inputOption};        % gap question, ask for string
///   inputOption =
///       "DIFF" "=" ID                    % auto-diff solution before check
///     | "SCORE" "=" INT                   % default is 1
///     | "ARRANGE"                         % random vector must be ordered
///     | "ROWS" "=" ("static"|"dynamic")   % default is static
///     | "COLS" "=" ("static"|"dynamic")   % default is static
///     | "KEYBOARD" "=" ID                 % force input keyboard
///     | "CHOICES" "=" INT { "+" STR }     % provides N solutions to select
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
  var exerciseData = exercise.exerciseData!;
  exerciseData.inputFields.add(inputField);
  var isGap = false;
  // reference to a variable from part CODE
  if (lexer.isIdentifier()) {
    data.variableId = lexer.identifier();
    // check if variable exists
    if (exerciseData.variables.contains(data.variableId) == false) {
      exercise.error +=
          ' Input field uses unknown variable "${data.variableId}". ';
      return inputField;
    }
  }
  // string -> gap question
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
  // ===== term input =====
  if (exerciseData.functionVariables.contains(data.variableId)) {
    data.type = MbclInputFieldType.term;
    data.isFunction = true;
  }
  // ===== operand input =====
  else if (isGap == false) {
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
  }
  // parse optional attributes e.g. ",SCORE=", ",DIFF=x", ...
  Map<String, String> attributes = {};
  while (lexer.isTerminal(",") && lexer.isTerminal(";") == false) {
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
  // process optional attributes
  try {
    // TODO: check semantics for each attribute (e.g. non-negative score, ...)!!
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
    // DIFF
    data.diffVariableId = "";
    if (hasAttribute(attributes, "DIFF")) {
      data.diffVariableId = getAttributeIdentifier(attributes, "DIFF");
    }
    // SCORES
    data.score = getAttributeInt(attributes, "SCORE", 1);
    // ARRANGE
    data.arrange = getAttributeBool(attributes, "ARRANGE", false);
    // ROWS
    data.dynamicRows = getAttributeString(
            attributes, "ROWS", ["dynamic", "static"], "static") ==
        "dynamic";
    // COLS
    data.dynamicCols = getAttributeString(
            attributes, "COLS", ["dynamic", "static"], "static") ==
        "dynamic";
    // KEYBOARD
    data.forceKeyboardId = getAttributeIdentifier(attributes, "KEYBOARD");
    // CHOICES | TOKENS
    if (attributes.containsKey("CHOICES") || attributes.containsKey("TOKENS")) {
      var parsingChoices = attributes.containsKey("CHOICES");
      var numChoices = 1;
      var termTokensFactor = 1.0;
      List<String> tk = [];
      if (parsingChoices) {
        // -- choices --
        data.choices = true;
        tk = attributes["CHOICES"]!.split("+");
        try {
          numChoices = int.parse(tk[0]); // TODO: check value
        } catch (e) {
          throw Exception(
              "Attribute value of 'CHOICES' must be an integral number. ");
        }
      } else {
        // -- term tokens --
        data.termTokens = true;
        tk = attributes["TOKENS"]!.split("+");
        try {
          termTokensFactor = double.parse(tk[0]); // TODO: check value
        } catch (e) {
          throw Exception(
              "Attribute value of 'TOKENS' must be a floating point number. ");
        }
      }
      for (var i = 0; i < exerciseData.instances.length; i++) {
        var instance = exerciseData.instances[i];
        var expected =
            instance[(data.isFunction ? "@" : "") + data.variableId]!;
        var expectedTerm = Parser().parse(expected);
        if (data.index >= 0 && data.index < expectedTerm.o.length) {
          expectedTerm = expectedTerm.o[data.index];
        }
        if (parsingChoices) {
          // -- choices --
          Set<String> choices = {};
          // add expected solution
          choices.add(expected.trim());
          // check, if predefined terms are valid; and substitute variables
          for (var choice in tk.sublist(1)) {
            try {
              // parse choice
              var term = Parser().parse(choice);
              // for all variables v: substitute the value of v (only applies
              // if it present)
              for (var id in instance.keys) {
                if (choice.contains(id) == false ||
                    id.endsWith(".tex") ||
                    id.startsWith("@") ||
                    id.startsWith("CHOICES") ||
                    id.startsWith("TOKENS")) continue;
                var replacementTerm = Parser().parse(instance[id]!);
                // substitute only if replacement is an operand
                if (replacementTerm.op == '#') {
                  term = term.substituteVariableByTermOrOperand(
                      id, Term.createConstInt(0), replacementTerm.value);
                }
              }
              choices.add(term.toString());
            } catch (e) {
              throw Exception(
                  "Manually added choice '$choice' has an invalid syntax. ");
            }
          }
          for (var j = 0; j < numChoices - 1; j++) {
            var choice = '';
            const maxTries = 25;
            for (var k = 0; k < maxTries; k++) {
              var clone = expectedTerm.clone();
              clone.disturb();
              choice = clone.toString();
              if (choices.contains(choice) == false) {
                choices.add(choice);
                break;
              }
            }
          }
          instance["CHOICES.${inputField.id}"] = choices.toList().join(" # ");
        } else {
          // -- term tokens --
          Set<String> termTokens = tk.sublist(1).toSet();
          var tmp = expectedTerm.tokenizeAndSynthesize(
              removeDuplicates: true, depth: 2, synthFactor: termTokensFactor);
          for (var t in tmp) {
            termTokens.add(t.split("%%%")[0].trim()); // remove TeX part
          }
          instance["TOKENS.${inputField.id}"] = termTokens.toList().join(" # ");
        }
      }
    }
    // GAP
    data.hideLengthOfGap = getAttributeBool(attributes, "HIDE_LENGTH", false);
    data.showAllLettersOfGap =
        getAttributeBool(attributes, "SHOW_ALL_LETTERS", false);
  } catch (e) {
    exercise.error += "Error in an input element: ";
    exercise.error += e.toString();
    if (e.toString().contains("Unknown attribute")) {
      exercise.error +=
          "You may try to end the list of attributes with a semicolon. ";
    }
  }
  return inputField;
}

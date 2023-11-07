/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/style.dart';
import 'package:tex/tex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/math-runtime/src/parse.dart' as term_parser;

import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/level.dart';
import 'package:mathebuddy/help.dart';
import 'package:mathebuddy/keyboard_layouts.dart';

class AppInputField {
  GestureDetector? gestureDetector;

  InlineSpan generateParagraphItemInputField(
    LevelState state,
    MbclLevelItem item, {
    bool bold = false,
    bool italic = false,
    Color color = Colors.black,
    MbclExerciseData? exerciseData,
  }) {
    var inputFieldData = item.inputFieldData as MbclInputFieldData;
    inputFieldData.exerciseData = exerciseData;
    if (exerciseData != null &&
        exerciseData.inputFields.containsKey(item.id) == false) {
      exerciseData.inputFields[item.id] = inputFieldData;
      inputFieldData.studentValue = "";
      var exerciseInstance =
          exerciseData.instances[exerciseData.runInstanceIdx];
      if (inputFieldData.isFunction) {
        inputFieldData.expectedValue =
            exerciseInstance["@${inputFieldData.variableId}"] as String;
      } else {
        inputFieldData.expectedValue =
            exerciseInstance[inputFieldData.variableId] as String;
      }
      if (inputFieldData.index >= 0) {
        var t = term_parser.Parser().parse(inputFieldData.expectedValue);
        if (inputFieldData.index >= t.o.length) {
          print("ERROR: indexing exceeds bound!");
        } else {
          t = t.o[inputFieldData.index];
        }
        inputFieldData.expectedValue = t.toString();
      }
    }
    Widget contents;
    Color feedbackColor = getStyle().getFeedbackColor(exerciseData?.feedback);
    var isActive = state.keyboardState.layout != null &&
        state.keyboardState.inputFieldData == inputFieldData;
    var activeOpacity = 0.25;
    if (inputFieldData.studentValue.isEmpty) {
      contents = RichText(
          text: TextSpan(children: [
        WidgetSpan(
            child: Container(
                decoration: BoxDecoration(
                    color: isActive
                        ? feedbackColor.withOpacity(activeOpacity)
                        : const Color.fromARGB(0, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                child: Icon(
                  //Icons.settings_ethernet,
                  Icons.aspect_ratio,
                  size: 32,
                  color: feedbackColor,
                ))),
      ]));
    } else {
      var tex = TeX();
      tex.scalingFactor = 1.33; //1.17;
      tex.setColor(feedbackColor.red, feedbackColor.green, feedbackColor.blue);

      List<InlineSpan> parts = [];

      var studentValue = inputFieldData.studentValue;
      var studentValueTeX = studentValue;
      var texValid = true;
      try {
        studentValueTeX = convertMath2TeX(studentValue, true);
      } catch (e) {
        texValid = false;
        studentValueTeX = studentValueTeX
            .replaceAll("{", "\\{")
            .replaceAll("}", "\\}")
            .replaceAll("^", "\\wedge");
      }
      var svgData = tex.tex2svg(studentValueTeX, displayStyle: true);
      if (tex.success()) {
        parts.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
                padding: isActive
                    ? EdgeInsets.only(left: 5, right: 5)
                    : EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border: texValid
                        ? null
                        : Border(
                            top: BorderSide(
                                color: getStyle().matheBuddyRed, width: 1.5),
                            bottom: BorderSide(
                                color: getStyle().matheBuddyRed, width: 1.5)),
                    color: isActive
                        ? feedbackColor.withOpacity(activeOpacity)
                        : Colors.white.withOpacity(0.0),
                    borderRadius: texValid
                        ? BorderRadius.all(Radius.circular(4.0))
                        : null),
                child:
                    SvgPicture.string(svgData, width: tex.width.toDouble()))));
      } else {
        parts.add(TextSpan(
            text: tex.error,
            style: TextStyle(color: Colors.red, fontSize: defaultFontSize)));
      }

      contents = RichText(text: TextSpan(children: parts));
    }
    var key = exerciseKey;
    gestureDetector = GestureDetector(
        onTap: () {
          state.activeExercise = exerciseData?.exercise;
          if (key != null) {
            Scrollable.ensureVisible(key.currentContext!,
                duration: Duration(milliseconds: 250));
          }
          state.keyboardState.exerciseData = exerciseData;
          state.keyboardState.inputFieldData = inputFieldData;
          var forceKeyboardId = inputFieldData.forceKeyboardId;
          if (inputFieldData.termTokens) {
            var termTokens = exerciseData!
                .instances[exerciseData.runInstanceIdx]["TOKENS.${item.id}"]!
                .split(" # ");
            if (termTokens.contains("(") == false) termTokens.add("(");
            if (termTokens.contains(")") == false) termTokens.add(")");
            state.keyboardState.layout =
                createChoiceKeyboard(termTokens, hasBackButton: true);
          } else if (inputFieldData.choices) {
            var choices = exerciseData!.instances[exerciseData.runInstanceIdx]
                    ["CHOICES.${item.id}"]!
                .split(" # ");
            state.keyboardState.layout =
                createChoiceKeyboard(choices, hasBackButton: false);
          } else if (forceKeyboardId.isNotEmpty) {
            state.keyboardState.layout = getKeyboardLayout(forceKeyboardId);
          } else {
            switch (inputFieldData.type) {
              case MbclInputFieldType.int:
                state.keyboardState.layout = getKeyboardLayout("integer");
                break;
              case MbclInputFieldType.real:
                state.keyboardState.layout = getKeyboardLayout("real");
                break;
              case MbclInputFieldType.complexNormal:
                state.keyboardState.layout =
                    getKeyboardLayout("complexNormalForm");
                break;
              case MbclInputFieldType.intSet:
                state.keyboardState.layout = getKeyboardLayout("integerSet");
                break;
              case MbclInputFieldType.complexIntSet:
                state.keyboardState.layout =
                    getKeyboardLayout("complexIntegerSet");
                break;
              case MbclInputFieldType.term:
                var t =
                    term_parser.Parser().parse(inputFieldData.expectedValue);
                var vars = t.getVariableIDs().toList();
                vars.sort();
                switch (vars.length) {
                  case 1:
                    state.keyboardState.layout =
                        getKeyboardLayout("termX", varX: vars[0]);
                    break;
                  case 2:
                    state.keyboardState.layout = getKeyboardLayout("termXY",
                        varX: vars[0], varY: vars[1]);
                    break;
                  case 3:
                    state.keyboardState.layout = getKeyboardLayout("termXYZ",
                        varX: vars[0], varY: vars[1], varZ: vars[2]);
                    break;
                  default:
                    state.keyboardState.layout = getKeyboardLayout("termX");
                    break;
                }
                break;
              case MbclInputFieldType.string:
                // gap question
                var expected = inputFieldData.expectedValue.toUpperCase();
                if (inputFieldData.showAllLettersOfGap) {
                  state.keyboardState.layout = getKeyboardLayout("alpha");
                  state.keyboardState.layout!.setGapKeyboard(true);
                } else {
                  Set<String> letters = {};
                  for (var i = 0; i < expected.length; i++) {
                    var ch = expected[i];
                    letters.add(ch);
                  }
                  state.keyboardState.layout =
                      createChoiceKeyboard(letters.toList());
                }
                if (inputFieldData.hideLengthOfGap == false) {
                  state.keyboardState.layout!
                      .setLengthHint(inputFieldData.expectedValue.length);
                }
                break;
              default:
                print("WARNING: generateParagraphItem():"
                    "keyboard layout for input field type"
                    " ${inputFieldData.type.name} not yet implemented");
                state.keyboardState.layout = getKeyboardLayout("termX");
            }
          }
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
        },
        child: contents);
    var scores = exerciseData!.scores;
    var showInfo = scores != 1;
    var info = Opacity(
        opacity: 0.4,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
                padding: EdgeInsets.all(2),
                child: Text(" \u2211 $scores ",
                    style: TextStyle(color: Colors.white)))));
    if (debugMode && showInfo) {
      return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Column(children: [gestureDetector!, info]));
    } else {
      return WidgetSpan(
          alignment: PlaceholderAlignment.middle, child: gestureDetector!);
    }
  }
}

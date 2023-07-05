/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:tex/tex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'screen.dart';
import 'main.dart';
import 'color.dart';
import 'help.dart';
import 'keyboard_layouts.dart';

InlineSpan generateParagraphItemInputField(
    CoursePageState state, MbclLevelItem item,
    {bold = false,
    italic = false,
    color = Colors.black,
    MbclExerciseData? exerciseData}) {
  var inputFieldData = item.inputFieldData as MbclInputFieldData;
  inputFieldData.exerciseData = exerciseData;
  if (exerciseData != null &&
      exerciseData.inputFields.containsKey(item.id) == false) {
    exerciseData.inputFields[item.id] = inputFieldData;
    inputFieldData.studentValue = "";
    var exerciseInstance = exerciseData.instances[exerciseData.runInstanceIdx];
    inputFieldData.expectedValue =
        exerciseInstance[inputFieldData.variableId] as String;
  }
  Widget contents;
  Color feedbackColor = getFeedbackColor(exerciseData?.feedback);
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
                      : Colors.white,
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
      studentValueTeX =
          studentValueTeX.replaceAll("{", "\\{").replaceAll("}", "\\}");
    }
    var svgData = tex.tex2svg(studentValueTeX, displayStyle: true);
    if (tex.error.isEmpty) {
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
                          top: BorderSide(color: matheBuddyRed, width: 1.5),
                          bottom: BorderSide(color: matheBuddyRed, width: 1.5)),
                  color: isActive
                      ? feedbackColor.withOpacity(activeOpacity)
                      : Colors.white,
                  borderRadius:
                      texValid ? BorderRadius.all(Radius.circular(4.0)) : null),
              child: SvgPicture.string(svgData, width: tex.width.toDouble()))));
    } else {
      parts.add(TextSpan(
          text: tex.error,
          style: TextStyle(color: Colors.red, fontSize: defaultFontSize)));
    }

    contents = RichText(text: TextSpan(children: parts));
  }
  var key = exerciseKey;
  return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
          onTap: () {
            state.activeExercise = exerciseData?.exercise;
            if (key != null) {
              Scrollable.ensureVisible(key.currentContext!,
                  duration: Duration(milliseconds: 250));
            }
            /*if (state.keyboardState.layout != null) {
                    state.keyboardState.layout = null;
                  } else {*/
            state.keyboardState.exerciseData = exerciseData;
            state.keyboardState.inputFieldData = inputFieldData;
            var forceKeyboardId = inputFieldData.exerciseData!.forceKeyboardId;
            if (forceKeyboardId.isNotEmpty) {
              switch (forceKeyboardId) {
                case "powerRoot":
                  {
                    state.keyboardState.layout = keyboardLayoutPowerRoot;
                    break;
                  }
                default: // TODO: ERROR!!!!!!!
              }
            } else {
              switch (inputFieldData.type) {
                case MbclInputFieldType.int:
                  state.keyboardState.layout = keyboardLayoutInteger;
                  break;
                case MbclInputFieldType.real:
                  state.keyboardState.layout = keyboardLayoutReal;
                  break;
                case MbclInputFieldType.complexNormal:
                  state.keyboardState.layout = keyboardLayoutComplexNormalForm;
                  break;
                case MbclInputFieldType.intSet:
                  state.keyboardState.layout = keyboardLayoutIntegerSet;
                  break;
                case MbclInputFieldType.complexIntSet:
                  state.keyboardState.layout = keyboardLayoutComplexIntegerSet;
                  break;
                /*case MbclInputFieldType.choices:
                      //inputFieldData.choices
                      break;*/
                default:
                  print("WARNING: generateParagraphItem():"
                      "keyboard layout for input field type"
                      " ${inputFieldData.type.name} not yet implemented");
                  state.keyboardState.layout = keyboardLayoutTerm;
              }
            }
            //}
            // ignore: invalid_use_of_protected_member
            state.setState(() {});
          },
          child: contents));
}

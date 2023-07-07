/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'main.dart';
import 'level.dart';
import 'help.dart';
import 'color.dart';

Widget generateSingleMultiChoice(
    LevelState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  // exerciseData is non-null in a multiple choice context
  exerciseData as MbclExerciseData;
  //
  int n = item.items.length;
  if (exerciseData.indexOrdering.isEmpty) {
    exerciseData.indexOrdering = List<int>.generate(n, (i) => i);
    if (exerciseData.staticOrder == false) {
      shuffleIntegerList(exerciseData.indexOrdering);
    }
  }
  // generate answers
  List<Widget> mcOptions = [];
  for (var i = 0; i < item.items.length; i++) {
    var inputField = item.items[exerciseData.indexOrdering[i]];
    var inputFieldData = inputField.inputFieldData as MbclInputFieldData;
    if (exerciseData.inputFields.containsKey(inputField.id) == false) {
      exerciseData.inputFields[inputField.id] = inputFieldData;
      inputFieldData.studentValue = "false";
      var exerciseInstance =
          exerciseData.instances[exerciseData.runInstanceIdx];
      inputFieldData.expectedValue =
          exerciseInstance[inputFieldData.variableId] as String;
    }
    var feedbackColor = getFeedbackColor(exerciseData.feedback);
    var iconId = 0;
    if (inputFieldData.studentValue == "false") {
      if (item.type == MbclLevelItemType.singleChoice) {
        iconId = 0xe504; // Icons.radio_button_unchecked
      } else {
        iconId = 0xe158; // Icons.check_box_outline_blank
      }
    } else {
      if (item.type == MbclLevelItemType.singleChoice) {
        iconId = 0xe503; // Icons.radio_button_checked
      } else {
        iconId = 0xEF46; // Icons.check_box_outlined
      }
    }
    var icon = Icon(
      IconData(iconId, fontFamily: 'MaterialIcons'),
      color: feedbackColor,
      size: 36,
    );
    var correct = inputFieldData.expectedValue == "true";
    var button = Column(children: [
      Padding(
          padding:
              EdgeInsets.only(left: 8.0, right: 2.0, top: 0.0, bottom: 0.0),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: debugMode && correct
                      ? feedbackColor.withOpacity(0.25)
                      : Colors.white),
              child: icon)),
    ]);
    var text = generateLevelItem(state, level, inputField.items[0],
        exerciseData: exerciseData);
    if (exerciseData.horizontalSingleMultipleChoiceAlignment == false) {
      text = Flexible(child: text);
    }
    mcOptions.add(GestureDetector(
        onTap: () {
          if (item.type == MbclLevelItemType.multipleChoice) {
            // multiple choice: swap clicked answer
            if (inputFieldData.studentValue == "true") {
              inputFieldData.studentValue = "false";
            } else {
              inputFieldData.studentValue = "true";
            }
          } else {
            // single choice: mark clicked answer as true and mark all
            // other answers as false
            for (var subitem in item.items) {
              var ifd = subitem.inputFieldData as MbclInputFieldData;
              ifd.studentValue = ifd == inputFieldData ? "true" : "false";
            }
          }
          exerciseData.feedback = MbclExerciseFeedback.unchecked;
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
        },
        child: exerciseData.horizontalSingleMultipleChoiceAlignment
            ? Row(children: [button, text])
            : Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Row(children: [button, text]))));
    //child: Padding(
    //    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
    //    child: Row(children: [button, text]))));
    //child: Row(children: [button, text])));
  }
  if (exerciseData.horizontalSingleMultipleChoiceAlignment) {
    return Container(
        margin: EdgeInsets.only(top: 5, bottom: 25),
        child: Row(children: mcOptions));
  } else {
    return Column(children: mcOptions);
  }
}

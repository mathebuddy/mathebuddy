/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/db_exercise.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/level_item.dart';

void evaluateExercise(
    State state, MbclLevel level, MbclExerciseData exerciseData) {
  print("----- evaluating exercise -----");
  keyboardState.layout = null;
  exerciseData.evaluate();
  level.calcProgress();
  level.chapter.saveUserData();
}

// TODO: must report error, if "exerciseData.numInstances" == 0!!
Widget generateExercise(State state, MbclLevel level, MbclLevelItem item,
    {bool generateInputFields = true,
    double borderRadius = 0.0,
    double borderWidth = 1.75}) {
  exerciseKey = GlobalKey();
  var exerciseData = item.exerciseData!;
  exerciseData.generateInputFields = generateInputFields;
  List<Widget> list = [];
  if (debugMode && exerciseData.requiredExercises.isNotEmpty) {
    var text = 'DEBUG INFO: This exercise depends on [';
    for (var req in exerciseData.requiredExercises) {
      text += req.label;
      if (req != exerciseData.requiredExercises.last) {
        text += ',';
      }
    }
    text += ']';
    list.add(Text(
      text,
      style: TextStyle(color: Colors.grey),
    ));
  }
  if (level.disableBlockTitles) {
    list.add(Text(
      ' ',
      key: exerciseKey,
    ));
  } else {
    var title = Wrap(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 5.0, top: 10.0),
          key: exerciseKey,
          child: Row(children: [
            Text(' '),
            Icon(Icons.play_circle_outlined, size: 35.0),
            Text(' '),
            // TODO: wrap does not work:
            Flexible(
                child: Text(item.title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
          ]))
    ]);
    list.add(title);
  }
  if (debugMode) {
    // show random instances, scores, time
    var text = "\u2684 ${exerciseData.numInstances}"
        "   \u2211 ${exerciseData.scores}";
    if (exerciseData.time >= 0) {
      text += "   \u231b${exerciseData.time}";
    }
    list.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Opacity(
          opacity: 0.8,
          child: Padding(
              padding: EdgeInsets.only(right: 4),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(" $text ",
                          style: TextStyle(color: Colors.white))))))
    ]));
  }
  for (var i = 0; i < item.items.length; i++) {
    var subItem = item.items[i];
    list.add(Wrap(children: [
      generateLevelItem(state, level, subItem,
          paragraphPaddingLeft: 10.0,
          paragraphPaddingTop: i == 0 ? 5.0 : 10.0,
          exerciseData: item.exerciseData)
    ]));
  }

  Color feedbackColor = getStyle().getFeedbackColor(exerciseData.feedback);
  Widget feedbackText = Text('');
  var isCorrect = exerciseData.feedback == MbclExerciseFeedback.correct;
  switch (exerciseData.feedback) {
    case MbclExerciseFeedback.unchecked:
      feedbackText = Text('?',
          style: TextStyle(
              color: feedbackColor,
              fontSize: getStyle().exerciseEvalButtonFontSize));
      break;
    case MbclExerciseFeedback.correct:
      feedbackText = Icon(Icons.check,
          color: feedbackColor, size: getStyle().exerciseEvalButtonFontSize);
      break;
    case MbclExerciseFeedback.incorrect:
      feedbackText = Icon(Icons.clear,
          color: feedbackColor, size: getStyle().exerciseEvalButtonFontSize);
      break;
  }

  // button row: validation button + new random exercise button (if correct)
  var validateButton = GestureDetector(
    onTap: () {
      evaluateExercise(state, level, exerciseData);
      renderFeedbackOverlay(
          state, exerciseData.feedback == MbclExerciseFeedback.correct);
    },
    child: Container(
      width: getStyle().exerciseEvalButtonWidth,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.0),
          border: isCorrect
              ? null
              : Border.all(
                  width: getStyle().exerciseEvalButtonBorderWidth,
                  color: feedbackColor,
                  style: BorderStyle.solid),
          borderRadius: isCorrect
              ? null
              : BorderRadius.all(
                  Radius.circular(getStyle().exerciseEvalButtonBorderRadius))),
      child: Center(child: feedbackText),
    ),
  );

  var retryButton = GestureDetector(
      onTap: () {
        // force to get a new instance
        exerciseData.reset();
        level.calcProgress();
        // ignore: invalid_use_of_protected_member
        state.setState(() {});
      },
      child: Container(
        width: 75,
        decoration: BoxDecoration(
            border: Border.all(
                width: 2.5, color: feedbackColor, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            )),
        child: debugMode
            ? Opacity(
                opacity: 0.8,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: 28,
                    child: Center(
                        child: Text(
                      "idx ${exerciseData.runInstanceIdx}",
                      style: TextStyle(color: Colors.white),
                    ))))
            : Center(
                child: Icon(
                Icons.autorenew,
                color: feedbackColor,
              )),
      ));

  List<Widget> buttons = [];
  if (level.isEvent == false) {
    buttons.add(validateButton);
    buttons.add(Text('   '));
    if (debugMode ||
        (exerciseData.disableRetry == false &&
            exerciseData.feedback == MbclExerciseFeedback.correct &&
            exerciseData.numInstances > 1)) {
      buttons.add(retryButton);
    }
  }

  list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons));

  if (debugMode && exerciseData.instances.isNotEmpty) {
    // show variable values
    var text = exerciseData.getVariableValuesAsString();
    if (text.isNotEmpty) {
      list.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Flexible(
            child: Opacity(
                opacity: 0.8,
                child: Padding(
                    padding: EdgeInsets.only(left: 4, top: 12, right: 4),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(" $text ",
                                style: TextStyle(color: Colors.white)))))))
      ]));
    }
  }

  return Container(
      decoration: BoxDecoration(
        color: exerciseData.feedback == MbclExerciseFeedback.unchecked
            ? Colors.white
            : feedbackColor.withOpacity(0.08),
        border: borderWidth > 0
            ? Border(
                top: BorderSide(color: feedbackColor, width: borderWidth),
                bottom: BorderSide(color: feedbackColor, width: borderWidth),
              )
            : null,
      ),
      padding: EdgeInsets.only(bottom: 10.0),
      margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: list));
}

void renderFeedbackOverlay(State state, bool success) {
  // show visual feedback as overlay
  //if (debugMode == false) {
  var overlayEntry = OverlayEntry(builder: (context) {
    var color = success ? Style().matheBuddyGreen : Style().matheBuddyRed;
    var text = getFeedbackText(success);
    var icon = getFeedbackIcon(success);
    return Container(
        alignment: Alignment.center,
        width: 200,
        height: 200,
        child: Opacity(
            opacity: 0.75,
            child: DefaultTextStyle(
                style: TextStyle(fontSize: 64, color: color),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.fromString(icon),
                      size: 80,
                      color: color,
                    ),
                    Center(
                        child: Text(
                      text,
                    ))
                  ],
                ))));
  });
  Overlay.of(levelBuildContext!).insert(overlayEntry);
  // ignore: invalid_use_of_protected_member
  state.setState(() {});
  Future.delayed(const Duration(milliseconds: 500), () {
    overlayEntry.remove();
    // ignore: invalid_use_of_protected_member
    state.setState(() {});
  });
  //}
}

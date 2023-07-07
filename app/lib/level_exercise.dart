/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'package:mathebuddy/math-runtime/src/parse.dart' as term_parser;

import 'color.dart';
import 'main.dart';
import 'screen.dart';
import 'level.dart';

Widget generateExercise(LevelState state, MbclLevel level, MbclLevelItem item) {
  // TODO: must report error, if "exerciseData.instances.length" == 0!!
  exerciseKey = GlobalKey();
  var exerciseData = item.exerciseData as MbclExerciseData;
  if (exerciseData.runInstanceIdx < 0) {
    exerciseData.runInstanceIdx =
        Random().nextInt(exerciseData.instances.length);
  }
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
    list.add(Container(
        child: Text(
      text,
      style: TextStyle(color: Colors.grey),
    )));
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
            Text(' '), // TODO: use padding instead of Text(' ')
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
  for (var i = 0; i < item.items.length; i++) {
    var subItem = item.items[i];
    list.add(Wrap(children: [
      generateLevelItem(state, level, subItem,
          paragraphPaddingLeft: 10.0,
          paragraphPaddingTop: i == 0 ? 5.0 : 10.0,
          exerciseData: item.exerciseData)
    ]));
  }

  Color feedbackColor = getFeedbackColor(exerciseData.feedback);
  Widget feedbackText = Text('');
  var isCorrect = exerciseData.feedback == MbclExerciseFeedback.correct;
  switch (exerciseData.feedback) {
    case MbclExerciseFeedback.unchecked:
      feedbackText =
          Text('?', style: TextStyle(color: feedbackColor, fontSize: 20));
      break;
    case MbclExerciseFeedback.correct:
      feedbackText = Icon(Icons.check, color: feedbackColor, size: 24);
      break;
    case MbclExerciseFeedback.incorrect:
      feedbackText = Icon(Icons.clear, color: feedbackColor, size: 24);
      break;
  }

  // button row: validation button + new random exercise button (if correct)
  var validateButton = GestureDetector(
    onTap: () {
      print("----- evaluating exercise -----");
      state.keyboardState.layout = null;
      // check exercise: TODO must implement in e.g. new file exercise.dart
      var allCorrect = true;
      for (var inputFieldId in exerciseData.inputFields.keys) {
        var inputField =
            exerciseData.inputFields[inputFieldId] as MbclInputFieldData;

        var ok = false;
        try {
          var studentTerm = term_parser.Parser().parse(inputField.studentValue);
          var expectedTerm =
              term_parser.Parser().parse(inputField.expectedValue);
          print("comparing $studentTerm to $expectedTerm");
          ok = expectedTerm.compareNumerically(studentTerm);
        } catch (e) {
          // TODO: give GUI feedback, that term is not well formed, ...
          print("evaluating answer failed: $e");
          ok = false;
        }
        if (ok) {
          print("answer OK");
        } else {
          allCorrect = false;
          print("answer wrong: expected ${inputField.expectedValue},"
              " got ${inputField.studentValue}");
        }
      }
      if (allCorrect) {
        print("... all answers are correct!");
        exerciseData.feedback = MbclExerciseFeedback.correct;
      } else {
        print("... at least one answer is incorrect!");
        exerciseData.feedback = MbclExerciseFeedback.incorrect;
      }
      level.calcProgress();
      print("----- end of exercise evaluation -----");
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
    },
    child: Container(
      width: 75, //double.infinity,
      //padding: EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
          border: isCorrect
              ? null
              : Border.all(
                  width: 2.5, color: feedbackColor, style: BorderStyle.solid),
          borderRadius: isCorrect
              ? null
              : BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
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
        width: 75, //double.infinity,
        //padding: EdgeInsets.only(left: 15, right: 5),
        decoration: BoxDecoration(
            border: Border.all(
                width: 2.5, color: feedbackColor, style: BorderStyle.solid),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20))),
        child: Center(
            child: Icon(
          Icons.autorenew,
          color: feedbackColor,
        )),
      ));

  List<Widget> buttons = [];
  if (level.isEvent == false) {
    buttons.add(validateButton);
    buttons.add(Text('   '));
    if (exerciseData.disableRetry == false &&
        exerciseData.feedback == MbclExerciseFeedback.correct &&
        exerciseData.instances.length > 1) {
      buttons.add(retryButton);
    }
  }

  list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons));
  var opacity = 1.0;
  // TODO: improve + reactivate this
  /*if (state.activeExercise != null) {
          opacity = item == state.activeExercise ? 1.0 : 0.3;
        }*/
  return Opacity(
      opacity: opacity,
      child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3))
          ]),
          padding: EdgeInsets.only(bottom: 10.0),
          margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: list)));
}

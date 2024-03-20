/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the level widget.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/audio.dart';
import 'package:mathebuddy/event.dart';
import 'package:mathebuddy/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/widget_event_painter.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:tex/tex.dart';

class EventWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclLevel level;
  final EventData eventData;

  EventWidget(this.course, this.level, this.eventData, {Key? key})
      : super(key: key) {
    course.saveUserData();
  }

  @override
  State<EventWidget> createState() => EventState();
}

class EventState extends State<EventWidget> {
  int currentPart = 0;
  GlobalKey? levelTitleKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.eventData.stop();
    super.dispose();
    print("!! event dispose !!");
  }

  @override
  Widget build(BuildContext context) {
    levelBuildContext = context;
    List<Widget> page = [];
    scrollController = ScrollController();
    var level = widget.level;

    // debug: show level path
    if (debugMode && level.fileId.isNotEmpty) {
      var path = "${level.chapter.fileId}/${level.fileId}.mbl";
      page.add(generateLevelPath(path));
    }

    // list errors
    if (widget.level.error.isNotEmpty) {
      page.add(generateErrorWidget(widget.level.error));
    }

    // pseudo title (for scrolling controls)
    levelTitleKey = GlobalKey();
    var levelTitle = Column(children: [
      Container(
        key: levelTitleKey,
        margin: EdgeInsets.only(top: 20.0),
        child: Text(''),
      )
    ]);
    page.add(levelTitle);

    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxContentsWidth) {
      screenWidth = maxContentsWidth;
    }

    // score-line
    page.add(Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Container(
            alignment: Alignment.center,
            child: CustomPaint(
                size: Size(screenWidth, 50),
                painter: EventPainter(20, true, widget.eventData.score)))));

    // remaining time
    var timePercentage =
        widget.eventData.timeRemaining / widget.eventData.timeTotal;
    page.add(Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Container(
            alignment: Alignment.center,
            child: CustomPaint(
                size: Size(screenWidth, 50),
                painter: EventPainter(8, false, timePercentage)))));

    // jokers
    List<Widget> jokerTexts = [
      Text("50:50", style: TextStyle(color: Colors.white, fontSize: 24)),
      Icon(MdiIcons.fromString("clock-outline"), size: 36, color: Colors.white),
      Text("", style: TextStyle(color: Colors.white)),
    ];

    List<Widget> buttons = [];
    var buttonWidth = screenWidth / 3 - 5;
    var buttonHeight = 45.0;
    for (var i = 0; i < jokerTexts.length; i++) {
      var buttonText = jokerTexts[i];
      var jokerAvailable = i == 0 && widget.eventData.jokerAvailable5050 ||
          i == 1 && widget.eventData.jokerAvailableTimePlus;
      if (widget.eventData.eventState == EventDataState.init) {
        jokerAvailable = false;
      }
      buttons.add(Positioned(
          left: i * buttonWidth + 5,
          top: 5,
          child: SizedBox(
              width: buttonWidth - 3,
              height: buttonHeight - 3,
              child: GestureDetector(
                  onTap: () {
                    if (i == 0) {
                      if (widget.eventData.jokerAvailable5050) {
                        widget.eventData.applyJoker(EventDataJoker.joker5050);
                      }
                    } else if (i == 1) {
                      if (widget.eventData.jokerAvailableTimePlus) {
                        widget.eventData
                            .applyJoker(EventDataJoker.jokerTimePlus);
                      }
                    }
                    setState(() {});
                  },
                  child: Opacity(
                    opacity: jokerAvailable ? 1.0 : 0.5,
                    child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Style().matheBuddyRed.withOpacity(0.9),
                                Style().matheBuddyRed.withOpacity(0.95)
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        alignment: Alignment.center,
                        child: buttonText),
                  )))));
    }
    page.add(Container(
        //color: Colors.pink,
        child: SizedBox(
            width: screenWidth, height: 50, child: Stack(children: buttons))));

    // exercise or game over
    if (widget.eventData.eventState == EventDataState.init) {
      var infoDE = [
        "Dies ist ein Event-Level. Es kommt beim Lösen der Aufgaben auf die Zeit an.",
        "Der obere Balken zeigt den Highscore. Löst Du eine Aufgabe richtig, so erhöht sich dieser Balken. Andernfalls verringert er sich. High Risk / High Impact: Je schneller Du die Lösung auswählst, umso größer ist die Auswirkung auf Deinen Highscore.",
        "Der zweite Balken zeigt die verbleibende Zeit an.",
        "Dir stehen einige Joker zur Verfügung. Diese kannst Du per Button anwenden."
      ];
      var infoEN = [
        "This is an event level. Time is of the essence when solving the tasks.",
        "The upper bar shows the high score. If you solve a task correctly, this bar increases. Otherwise it decreases. High Risk / High Impact: The faster you select the solution, the greater the impact on your high score.",
        "The second bar shows the remaining time.",
        "You have several jokers at your disposal. You can use these with the button."
      ];
      var info = language == "de" ? infoDE : infoEN;

      for (var text in info) {
        page.add(Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: RichText(
                text: TextSpan(
                    text: text,
                    style: TextStyle(fontSize: 18, color: Colors.white)))));
      }
      var w = 100;
      var h = 50;
      var startButton = Positioned(
          left: screenWidth / 2 - w / 2,
          top: 20,
          child: SizedBox(
              width: w - 3,
              height: h - 3,
              child: GestureDetector(
                onTap: () {
                  widget.eventData.start(this);
                  setState(() {});
                },
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Style().matheBuddyGreen.withOpacity(0.9),
                            Style().matheBuddyGreen.withOpacity(0.95)
                          ]),
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    alignment: Alignment.center,
                    child: Text("Start",
                        style: TextStyle(color: Colors.white, fontSize: 24))),
              )));
      page.add(Container(
          //color: Colors.pink,
          child: SizedBox(
              width: screenWidth,
              height: 75,
              child: Stack(children: [startButton]))));
    } else if (widget.eventData.eventState == EventDataState.gameOver) {
      page.add(Center(
          child: Text("GAME\nOVER",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: getStyle().matheBuddyRed,
                  fontSize: 64,
                  fontWeight: FontWeight.bold))));
    } else if (widget.eventData.eventState == EventDataState.success) {
      page.add(Center(
          child: Text("WELL\nDONE",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: getStyle().matheBuddyGreen,
                  fontSize: 64,
                  fontWeight: FontWeight.bold))));
    } else {
      // add current exercise
      var exercise = widget.eventData.activeExercise;
      if (exercise != null &&
          exercise.exerciseData!.feedback == MbclExerciseFeedback.correct) {
        exercise.exerciseData!.feedback = MbclExerciseFeedback.unchecked;
      }
      if (exercise != null) {
        page.add(generateExercise(this, level, exercise,
            borderWidth: 0,
            generateInputFields: false,
            eventColorScheme: true));

        var exerciseData = exercise.exerciseData!;

        List<MbclLevelItem> choicesElements = [];
        int correctAnswerIdx = 0;

        var choices = exerciseData.getChoicesOfFirstInputField();
        if (choices.length == 4) {
          // choices answer
          for (var choice in choices) {
            var span = MbclLevelItem(level, MbclLevelItemType.span, -1);
            choicesElements.add(span);
            var text = MbclLevelItem(level, MbclLevelItemType.text, -1, choice);
            span.items.add(text);
          }
        } else {
          // single choice answer
          var answers = exerciseData.getSingleChoiceAnswers();
          var idx = 0;
          for (var answer in answers) {
            choicesElements.add(answer.items[0]); // add span
            answer.inputFieldData!.studentValue = "false";
            var v = answer.inputFieldData!.variableId;
            var correct = exerciseData.activeInstance[v]!;
            if (correct == "true") correctAnswerIdx = idx;
            idx++;
          }
          // print("CORRECT IDX");
          // print(correctAnswerIdx);
          // print("active instance");
          // print(exerciseData.activeInstance);
        }

        if (choicesElements.length == 4) {
          var buttonWidth = screenWidth / 2 - 5;
          var buttonHeight = 65.0;

          List<Widget> buttons = [];
          for (var i = 0; i < 4; i++) {
            var idx = widget.eventData.answerOrder[i];

            var opacity = 1.0;
            if (widget.eventData.jokerActive5050) {
              if (idx == 1 || idx == 2) {
                opacity = 0.2;
              }
            }
            // generate text widget
            var tex = TeX();
            tex.scalingFactor = 1.33; //1.17;
            tex.setColor(0, 0, 0);

            var optionText = choicesElements[idx];
            Widget buttonText = generateLevelItem(this, level, optionText,
                exerciseData: exerciseData);

            // generate button
            var column = i % 2;
            var row = (i / 2).floor();
            buttons.add(Positioned(
                left: column * buttonWidth + 3,
                top: row * buttonHeight + 3,
                child: SizedBox(
                    width: buttonWidth - 6,
                    height: buttonHeight - 6,
                    child: GestureDetector(
                        onTap: () {
                          var correct = idx == correctAnswerIdx;
                          exerciseData.feedback = correct
                              ? MbclExerciseFeedback.correct
                              : MbclExerciseFeedback.incorrect;
                          if (correct) {
                            widget.eventData.correctAnswers++;
                          } else {
                            widget.eventData.incorrectAnswers++;
                          }
                          widget.eventData.updateScore(correct);
                          renderFeedbackOverlay(this, correct,
                              textOpacity: 1.0, backgroundOpacity: 0.7);
                          widget.eventData.switchExercise(correct);
                          exerciseData.feedback =
                              MbclExerciseFeedback.unchecked;
                          setState(() {});
                          if (!level.course.muteAudio) {
                            appAudio.play(correct
                                ? AppAudioId.passedExercise
                                : AppAudioId.failedExercise);
                          }
                        },
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                              decoration: BoxDecoration(
                                color: debugMode && idx == correctAnswerIdx
                                    ? getStyle().matheBuddyGreen
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              alignment: Alignment.center,
                              child: buttonText),
                        )))));
          }
          page.add(SizedBox(
              width: screenWidth,
              height: 300,
              child: Stack(children: buttons)));
        } else {
          page.add(Text(
            "error: event level requires CHOICES=4",
            style: TextStyle(fontSize: 32, color: Colors.red),
          ));
        }
      }
    }

    // generate document
    scrollView = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        controller: scrollController,
        padding: EdgeInsets.only(right: 2.0),
        child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(left: 3.0, right: 3.0),
            child: Container(
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: page))));
    //Widget? navBar;
    List<Widget> levelPartIcons = [];
    if (!debugMode && level.numParts != 0) {
      levelPartIcons = generateLevelPartIcons(this, level);
    }
    // var body = Column(children: [
    //   Container(
    //       margin: EdgeInsets.only(top: 0),
    //       child: Column(children: navBar == null ? [] : [navBar])),
    //   Expanded(child: scrollView!)
    // ]);
    var body = scrollView!;

    // var bottomArea =
    //     generateLevelBottomNavigationBar(this, level, levelTitleKey!, context);

    // page.add(bottomArea);

    return Scaffold(
      appBar: buildAppBar(
          true, levelPartIcons, false, this, context, widget.course),
      body: body,
      backgroundColor: Colors.black,
      //bottomSheet: bottomArea,
    );
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the level widget.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/event.dart';
import 'package:mathebuddy/widget_event_painter.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/level_item.dart';
import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';

import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/unit.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:tex/tex.dart';

class EventWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclChapter chapter;
  final MbclUnit? unit;
  final MbclLevel level;
  final EventData eventData;

  EventWidget(this.course, this.chapter, this.unit, this.level, this.eventData,
      {Key? key})
      : super(key: key) {
    course.lastVisitedChapter = chapter;
    chapter.lastVisitedUnit = unit;
    chapter.lastVisitedLevel = level;
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
    level.calcProgress();

    if (widget.eventData.eventState == EventDataState.init) {
      widget.eventData.start(this);
    }

    // debug: show level path
    if (debugMode && level.fileId.isNotEmpty) {
      var path = "${widget.chapter.fileId}/${level.fileId}.mbl";
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
    List<String> jokerTexts = ["50:50", "time+", "blub"];
    List<Widget> buttons = [];
    var buttonWidth = screenWidth / 3 - 5;
    var buttonHeight = 45.0;
    for (var i = 0; i < 3; i++) {
      var buttonText =
          Text(jokerTexts[i], style: TextStyle(color: Colors.white));
      var jokerAvailable = i == 0 && widget.eventData.jokerAvailable5050 ||
          i == 1 && widget.eventData.jokerAvailableTimePlus;
      buttons.add(Positioned(
          left: i * buttonWidth + 5,
          top: 5,
          child: SizedBox(
              width: buttonWidth - 3,
              height: buttonHeight - 3,
              child: GestureDetector(
                  onTap: () {
                    if (i == 0) {
                      widget.eventData.applyJoker(EventDataJoker.joker5050);
                    } else if (i == 1) {
                      widget.eventData.applyJoker(EventDataJoker.jokerTimePlus);
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
    if (widget.eventData.eventState == EventDataState.gameOver) {
      page.add(Center(
          child: Text("GAME\nOVER",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: getStyle().matheBuddyRed,
                  fontSize: 64,
                  fontWeight: FontWeight.bold))));
    } else {
      // add current exercise
      var exercise = widget.eventData.getCurrentExercise();
      if (exercise != null &&
          exercise.exerciseData!.feedback == MbclExerciseFeedback.correct) {
        exercise.exerciseData!.feedback = MbclExerciseFeedback.unchecked;
      }
      if (exercise != null) {
        page.add(generateExercise(this, level, exercise,
            borderWidth: 0, generateInputFields: false));

        var exerciseData = exercise.exerciseData!;
        var choices = exerciseData.getChoicesOfFirstInputField();

        if (choices.length == 4) {
          var inputField = exerciseData.inputFields[0];
          var inputFieldData = inputField.inputFieldData!;

          var buttonWidth = screenWidth / 2 - 5;
          var buttonHeight = 80.0;

          List<Widget> buttons = [];
          for (var i = 0; i < 4; i++) {
            var idx = widget.eventData.randomOrder[i];
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
            var optionText = choices[idx];
            var svgData = tex.tex2svg(optionText, displayStyle: true);
            Widget buttonText = Text("TeX-Error",
                style: TextStyle(color: Colors.red, fontSize: 32));
            if (tex.success()) {
              buttonText =
                  SvgPicture.string(svgData, width: tex.width.toDouble());
            }
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
                          inputFieldData.studentValue = optionText;
                          exerciseData.evaluate();
                          var correct = exerciseData.feedback ==
                              MbclExerciseFeedback.correct;
                          widget.eventData.updateScore(correct);
                          if (correct) {
                            widget.eventData.correctAnswers++;
                          } else {
                            widget.eventData.incorrectAnswers++;
                          }
                          renderFeedbackOverlay(this, correct);
                          widget.eventData.switchExercise();
                          exerciseData.feedback =
                              MbclExerciseFeedback.unchecked;
                          setState(() {});
                        },
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 75, 75, 75),
                                    width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3.0,
                                      spreadRadius: 2.0,
                                      offset: Offset(1, 1),
                                      color: const Color.fromARGB(
                                          255, 200, 200, 200))
                                ],
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
    Widget? navBar;
    if (!debugMode && level.numParts != 0) {
      navBar = generateLevelTopNavigationBar(this, level);
    }
    var body = Column(children: [
      Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(children: navBar == null ? [] : [navBar])),
      Expanded(child: scrollView!)
    ]);

    var bottomArea =
        generateLevelBottomNavigationBar(this, level, levelTitleKey!);

    return Scaffold(
      appBar: buildAppBar(true, this, widget.chapter),
      body: body,
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}

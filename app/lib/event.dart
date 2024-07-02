/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

enum EventDataState {
  init,
  running,
  gameOver,
  success,
}

enum EventDataJoker { joker5050, jokerTimePlus }

class EventData {
  EventDataState eventState = EventDataState.init;

  MbclLevel level;
  List<MbclLevelItem> allExercises = [];
  int allExercisesScore = 0;

  // pipeline = all exercises at start; first is popped and wrongly answered
  // are pushed back again
  //List<MbclLevelItem> exercisePipeline = [];
  MbclLevelItem? activeExercise;
  int activeExerciseIdx = 0;

  //int highScore = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  DateTime startTimeEvent = DateTime.now();
  DateTime startTimeCurrentExercise = DateTime.now();

  double scoreNEW = 0.0; // TODO: rename to score

  Timer? timer;

  double timeTotal = 10.0; // set via TIME=XX in MBL
  double timeRemaining = 0.0;

  bool jokerAvailable5050 = true;
  bool jokerAvailableTimePlus = true;

  bool jokerActive5050 = false;

  List<int> answerOrder = [0, 1, 2, 3];

  EventData(this.level) {
    activeExerciseIdx = 0;
    allExercisesScore = 0;
    answerOrder.shuffle();
    for (var item in level.items) {
      if (item.type == MbclLevelItemType.exercise) {
        activeExercise ??= item;
        allExercises.add(item);
        allExercisesScore += item.exerciseData!.score;
        //exercisePipeline.add(item);
      }
    }
    // if (exercisePipeline.isNotEmpty) {
    //   exercisePipeline.removeLast(); // first exercise is already active
    // }
  }

  applyJoker(EventDataJoker joker) {
    switch (joker) {
      case EventDataJoker.joker5050:
        {
          jokerAvailable5050 = false;
          jokerActive5050 = true;
          print("applied 50:50 joker");
          break;
        }
      case EventDataJoker.jokerTimePlus:
        {
          jokerAvailableTimePlus = false;
          timeRemaining += 15;
          if (timeRemaining > timeTotal) {
            timeRemaining = timeTotal;
          }
          break;
        }
      default:
      // TODO
    }
  }

  start(State state) {
    print("--- starting event timer ---");

    timeTotal = activeExercise!.exerciseData!.time.toDouble();

    timeRemaining = timeTotal;
    eventState = EventDataState.running;
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      timeRemaining -= 0.5;
      if (timeRemaining <= 0) {
        timer!.cancel();

        eventState = EventDataState.gameOver;
        stop();

        // TODO score -= 0.2;
        // checkGameOver();
        // renderFeedbackOverlay(state, false);
        // switchExercise(false);
        //eventState = EventDataState.gameOver;
      }
      print("event tick ${DateTime.now().toString()}");
      print("remaining time $timeRemaining");
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
    });
  }

  stop() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  /// Returns the percentage in range [0,1], based on the current score
  double getPercentage() {
    var p = scoreNEW / allExercisesScore;
    return p / 2 + 0.5;
  }

  void updateScore(bool correct) {
    var percentageTime = timeRemaining / timeTotal;
    double factor = 1.0;
    if (percentageTime.abs() < 1e-6) {
      factor = 0.25;
    } else if (percentageTime <= 1 / 3) {
      factor = 0.50;
    } else if (percentageTime <= 2 / 3) {
      factor = 0.75;
    }
    double delta = factor * activeExercise!.exerciseData!.score.toDouble();
    if (correct == false) {
      delta = -delta;
    }
    scoreNEW += delta;
    //checkGameOver();
  }

  //void checkGameOver() {
  // TODO
  // if (score < 0) {
  //   eventState = EventDataState.gameOver;
  //   stop();
  // }
  //}

  void switchExercise(bool correct) {
    jokerActive5050 = false;

    // if (correct == false && activeExercise != null) {
    //   exercisePipeline.add(activeExercise!);
    // }

    // if (exercisePipeline.isEmpty) {
    //   if (score < 0.5) {
    //     exercisePipeline.addAll(allExercises);
    //   } else {
    //     eventState = EventDataState.success;
    //     level.progress = 1.0;
    //     level.chapter.saveUserData();
    //     level.chapter.course.saveUserData();
    //     stop();
    //   }
    // } else {
    //   activeExercise = exercisePipeline.removeAt(0);
    // }

    // TODO: check end!!!!!
    if (activeExerciseIdx < allExercises.length - 1) {
      activeExerciseIdx++;
      activeExercise = allExercises[activeExerciseIdx];
    } else {
      stop();
      if (scoreNEW + 1e-6 >= 0) {
        eventState = EventDataState.success;
        level.progress = 1.0;
        level.chapter.saveUserData();
        level.chapter.course.saveUserData();
      } else {
        eventState = EventDataState.gameOver;
      }
    }

    if (activeExercise != null) {
      // prepare for next run
      activeExercise!.exerciseData!.runInstanceIdx = -1;
      activeExercise!.exerciseData!.nextInstance();
      print(
          "----- run instances idx ${activeExercise!.exerciseData!.runInstanceIdx} -----");
    }
    answerOrder.shuffle();
    timeTotal = activeExercise!.exerciseData!.time.toDouble();
    timeRemaining = timeTotal;
    // TODO: randomize order??
    //currentExerciseIdx = (currentExerciseIdx + 1) % allExercises.length;
    //print(">>> exercise index is now $currentExerciseIdx");
  }

  // MbclLevelItem? getCurrentExercise() {
  //   if (currentExerciseIdx >= allExercises.length) return null;
  //   return allExercises[currentExerciseIdx];
  // }
}

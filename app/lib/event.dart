/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

// TODO: MOVE THIS FILE TO APP!!! THIS IS NOT MBCL

enum EventDataState {
  init,
  running,
  gameOver,
  success,
}

enum EventDataJoker { joker5050, jokerTimePlus }

class EventData {
  EventDataState eventState = EventDataState.init;

  List<MbclLevelItem> exercises = [];
  int currentExerciseIdx = 0;
  //int highScore = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  DateTime startTimeEvent = DateTime.now();
  DateTime startTimeCurrentExercise = DateTime.now();

  double score = 0.5;

  Timer? timer;

  double timeTotal = 10.0;
  double timeRemaining = 0.0;

  bool jokerAvailable5050 = true;
  bool jokerAvailableTimePlus = true;

  bool jokerActive5050 = false;

  List<int> randomOrder = [0, 1, 2, 3];

  EventData(MbclLevel level) {
    randomOrder.shuffle();
    for (var item in level.items) {
      if (item.type == MbclLevelItemType.exercise) {
        exercises.add(item);
      }
    }
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
    timeRemaining = timeTotal;
    eventState = EventDataState.running;
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      timeRemaining -= 0.5;
      if (timeRemaining <= 0) {
        score -= 0.2;
        checkGameOver();
        renderFeedbackOverlay(state, false);
        switchExercise();
      }
      print("event tick ${DateTime.now().toString()}");
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
    });
  }

  stop() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  void updateScore(bool correct) {
    var delta = 0.2 * timeRemaining / timeTotal;
    score += correct ? delta : -delta;
    if (score > 1) {
      score = 1;
    }
    checkGameOver();
  }

  void checkGameOver() {
    if (score < 0) {
      eventState = EventDataState.gameOver;
      stop();
    }
  }

  void switchExercise() {
    jokerActive5050 = false;
    var currentExercise = getCurrentExercise();
    if (currentExercise != null) {
      // prepare for next run
      currentExercise.exerciseData!.runInstanceIdx = -1;
      currentExercise.exerciseData!.nextInstance();
      print(
          "----- run instances idx ${currentExercise.exerciseData!.runInstanceIdx} -----");
    }
    randomOrder.shuffle();
    timeRemaining = timeTotal;
    // TODO: randomize order??
    currentExerciseIdx = (currentExerciseIdx + 1) % exercises.length;
    print(">>> exercise index is now $currentExerciseIdx");
  }

  MbclLevelItem? getCurrentExercise() {
    if (currentExerciseIdx >= exercises.length) return null;
    return exercises[currentExerciseIdx];
  }
}

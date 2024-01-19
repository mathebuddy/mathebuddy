/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'dart:async';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/widget_level.dart';

// TODO: MOVE THIS FILE TO APP!!! THIS IS NOT MBCL

class EventData {
  LevelState levelState;

  List<MbclLevelItem> exercises = [];
  int currentExerciseIdx = 0;
  int highScore = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  DateTime startTimeEvent = DateTime.now();
  DateTime startTimeCurrentExercise = DateTime.now();

  Timer? timer;
  bool running = false;

  int counter = 0;

  EventData(MbclLevel level, this.levelState) {
    for (var item in level.items) {
      if (item.type == MbclLevelItemType.exercise) {
        exercises.add(item);
      }
    }
  }

  start() {
    counter = 5; // TODO
    running = true;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      counter--;
      if (counter <= 0) {
        end();
      }
      print("update ${DateTime.now().toString()}");
      // ignore: invalid_use_of_protected_member
      levelState.setState(() {});
    });
  }

  end() {
    running = false;
    if (timer != null) {
      timer!.cancel();
    }
  }

  void switchExercise() {
    // TODO: randomize order??
    currentExerciseIdx = (currentExerciseIdx + 1) % exercises.length;
    print(">>> exercise index is now $currentExerciseIdx");
  }

  MbclLevelItem? getCurrentExercise() {
    if (currentExerciseIdx >= exercises.length) return null;
    return exercises[currentExerciseIdx];
  }
}

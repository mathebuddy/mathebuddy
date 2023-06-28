/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'dart:async';

import 'level.dart';
import 'level_item.dart';

class MbclEventData {
  List<MbclLevelItem> exercises = [];
  int currentExerciseIdx = 0;
  int highScore = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  DateTime startTimeEvent = DateTime.now();
  DateTime startTimeCurrentExercise = DateTime.now();

  MbclEventData(MbclLevel level) {
    for (var item in level.items) {
      if (item.type == MbclLevelItemType.exercise) {
        exercises.add(item);
      }
    }
    Timer timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      print("update ${DateTime.now().toString()}");
    });
    // TODO!!! must cancel timer at end
  }

  MbclLevelItem? getCurrentExercise() {
    if (currentExerciseIdx >= exercises.length) return null;
    return exercises[currentExerciseIdx];
  }
}

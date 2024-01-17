/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/chapter.dart';
import '../../mbcl/src/level_item.dart';

import 'level.dart';

void postProcessChapter(MbclChapter chapter) {
  List<MbclLevelItem> exercises = [];
  for (var i = 0; i < chapter.levels.length; i++) {
    var level = chapter.levels[i];
    postProcessLevel(level);
    // gather exercises
    var levelExercises = level.getExercises();
    exercises.addAll(levelExercises);
  }
  // check, if all exercises have distinct labels. If not, generate error
  Set<String> exerciseLabels = {};
  for (var ex in exercises) {
    if (exerciseLabels.contains(ex.label)) {
      chapter.error += ' Exercise label "${ex.label}" is given twice or more. ';
    }
    exerciseLabels.add(ex.label);
  }
}

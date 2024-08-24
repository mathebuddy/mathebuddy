/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'chapter.dart';
import 'course.dart';
import 'level.dart';

class MbclUnit {
  final MbclCourse course;
  final MbclChapter chapter;

  MbclUnit(this.course, this.chapter);

  // import/export
  String id = '';
  String title = '';
  String iconData = '';
  List<MbclLevel> levels = [];
  List<double> levelPosX = [];
  List<double> levelPosY = [];

  // temporary
  List<String> levelFileIDs = [];
  double progress = 0.0;

  void calcProgress() {
    progress = 0.0;
    for (var level in levels) {
      level.calcProgress();
      progress += level.progress;
    }
    progress /= levels.length;
  }

  bool isLocked() {
    for (var level in levels) {
      if (level.isLocked() == false) {
        return false;
      }
    }
    return true;
  }

  void resetProgress() {
    for (var level in levels) {
      level.resetProgress();
    }
    progress = 0.0;
    //calcProgress();
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "title": title,
      "iconData": iconData,
      "levels": levels.map((level) => level.fileId).toList(),
      "levelPosX": levelPosX,
      "levelPosY": levelPosY,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    id = src["id"];
    title = src["title"];
    iconData = src["iconData"];
    levels = [];
    int n = src["levels"].length;
    for (var i = 0; i < n; i++) {
      levelFileIDs.add(src["levels"][i]);
    }
    levelPosX = [];
    n = src["levelPosX"].length;
    for (var i = 0; i < n; i++) {
      levelPosX.add(src["levelPosX"][i]);
    }
    n = src["levelPosY"].length;
    for (var i = 0; i < n; i++) {
      levelPosY.add(src["levelPosY"][i]);
    }
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'dart:convert';

import 'course.dart';
import 'level.dart';
import 'unit.dart';

class MbclChapter {
  final MbclCourse course;

  MbclChapter(this.course);

  /// all references go go [fileId]; [label] is only used for searching
  String fileId = '';
  String error = "";
  String title = '';
  String label = '';
  String author = '';
  String iconData = '';
  int posX = -1;
  int posY = -1;
  List<MbclChapter> requires = [];
  List<String> requiresTmp = []; // only used while compiling
  List<MbclUnit> units = [];
  List<MbclLevel> levels = [];

  // temporary
  MbclUnit? lastVisitedUnit;
  MbclLevel? lastVisitedLevel;
  double progress = 0.0;

  void calcProgress() {
    progress = 0.0;
    for (var level in levels) {
      level.calcProgress();
      progress += level.progress;
    }
    progress /= levels.length;
  }

  void resetProgress() {
    for (var level in levels) {
      level.resetProgress();
      progress += level.progress;
    }
    calcProgress();
  }

  double getEventsPercentage() {
    var numTotal = 0.0;
    var numPassed = 0.0;
    for (var level in levels) {
      if (level.isEvent == false) continue;
      numTotal++;
      if (level.progress > 0.99999) {
        numPassed++;
      }
    }
    return numPassed / numTotal;
  }

  double getVisitedLevelPercentage() {
    var v = 0.0;
    for (var level in levels) {
      if (level.visited) {
        v++;
      }
    }
    return v / levels.length.toDouble();
  }

  String gatherErrors() {
    var err = error.isEmpty ? "" : "$error\n";
    for (var level in levels) {
      err += level.gatherErrors();
    }
    if (err.isNotEmpty) {
      err = "@CHAPTER $fileId:\n$err";
    }
    return err;
  }

  MbclLevel? getLevelByLabel(String label) {
    for (var level in levels) {
      if (level.label == label) return level;
    }
    return null;
  }

  MbclLevel? getLevelByFileID(String fileID) {
    for (var level in levels) {
      if (level.fileId == fileID) return level;
    }
    return null;
  }

  MbclUnit? getUnitById(String id) {
    for (var unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  Future<bool> loadUserData() async {
    //print("loading chapter user data ($fileId)");
    if (course.checkFileIO() == false) return false;
    var path = _getFilePath();
    try {
      var chapterStringified = await course.persistence!.readFile(path);
      var chapterJson = jsonDecode(chapterStringified);
      progressFromJSON(chapterJson);
    } catch (e) {
      print("could not load user data for chapter $path");
    }
    return true;
  }

  bool saveUserData() {
    //print("saving chapter user data ($fileId)");
    if (course.checkFileIO() == false) return false;
    calcProgress();
    var chapterJson = progressToJSON();
    var chapterStringified = JsonEncoder.withIndent("  ").convert(chapterJson);
    var path = _getFilePath();
    course.persistence!.writeFile(path, chapterStringified);
    return true;
  }

  String _getFilePath() {
    return "${course.courseId}_$fileId.json";
  }

  Map<String, dynamic> progressToJSON() {
    Map<String, dynamic> levelData = {};
    for (var level in levels) {
      if (level.visited == false) continue;
      levelData[level.fileId] = level.progressToJSON();
    }
    return {"levels": levelData};
  }

  progressFromJSON(Map<String, dynamic> src) {
    var levelData = src["levels"];
    for (var level in levels) {
      if (levelData.containsKey(level.fileId)) {
        level.progressFromJSON(levelData[level.fileId]!);
      }
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      "fileId": fileId,
      "error": error,
      "title": title,
      "label": label,
      "author": author,
      "iconData": iconData,
      "posX": posX,
      "posY": posY,
      "requires": requires.map((req) => req.fileId).toList(),
      "units": units.map((unit) => unit.toJSON()).toList(),
      "levels": levels.map((level) => level.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    fileId = src["fileId"];
    error = src["error"];
    title = src["title"];
    label = src["label"];
    author = src["author"];
    iconData = src["iconData"];
    posX = src["posX"];
    posY = src["posY"];
    // levels
    levels = [];
    int n = src["levels"].length;
    for (var i = 0; i < n; i++) {
      var level = MbclLevel(course, this);
      level.fromJSON(src["levels"][i]);
      levels.add(level);
    }
    // reconstruct required levels
    for (var level in levels) {
      for (var requiresId in level.requiresTmp) {
        level.requires.add(getLevelByFileID(requiresId)!);
      }
    }
    // units
    units = [];
    n = src["units"].length;
    for (var i = 0; i < n; i++) {
      var unit = MbclUnit(course, this);
      unit.fromJSON(src["units"][i]);
      units.add(unit);
      // reconstruct levels
      for (var levelFileId in unit.levelFileIDs) {
        unit.levels.add(getLevelByFileID(levelFileId)!);
      }
    }
    // requires
    requires = [];
    n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      requiresTmp.add(src["requires"][i]);
    }
  }
}

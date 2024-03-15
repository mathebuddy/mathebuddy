/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'chapter.dart';
import 'course.dart';
import 'level_item.dart';
import 'level_item_exercise.dart';

class MbclLevel {
  final MbclCourse course;
  final MbclChapter chapter;

  MbclLevel(this.course, this.chapter);

  // import/export
  String fileId =
      ''; // all references go here; label is only used for searching
  String error = '';
  String title = '';
  String label = '';

  //double posX = -1; // used in level overview
  //double posY = -1; // used in level overview
  String iconData = '';
  int numParts = 0;
  List<String> partIconIDs = [];
  List<MbclLevel> requires = [];
  List<MbclLevelItem> items = [];
  bool isEvent = false;
  bool disableBlockTitles = false;

  // temporary
  int currentPart = 0;
  List<String> requiresTmp = [];
  bool visited = false;
  double screenPosX = 0.0; // used in level overview
  double screenPosY = 0.0; // used in level overview
  double progress = 0.0; // percentage of correct exercises [0,1]

  bool isDebugLevel = false; // e.g. true, if all levels are consolidated

  String gatherErrors() {
    var err = error.isEmpty ? "" : "$error\n";
    for (var item in items) {
      var e = item.gatherErrors();
      if (e.isNotEmpty) {
        err += "  [Line ${item.srcLine}] $e";
      }
    }
    if (err.isNotEmpty) {
      err = "@LEVEL $fileId:\n$err";
    }
    return err;
  }

  MbclLevelItem? getExerciseByLabel(String label) {
    for (var item in items) {
      if (item.type == MbclLevelItemType.exercise && item.label == label) {
        return item;
      }
    }
    return null;
  }

  List<MbclLevelItem> getExercises() {
    List<MbclLevelItem> res = [];
    for (var item in items) {
      if (item.type == MbclLevelItemType.exercise) {
        res.add(item);
      }
    }
    return res;
  }

  void resetProgress() {
    visited = false;
    if (isEvent == false) {
      // event progress is managed manually!
      progress = 0.0;
    }
    for (var item in items) {
      if (item.type == MbclLevelItemType.exercise) {
        var data = item.exerciseData!;
        data.reset();
      }
    }
    chapter.saveUserData();
  }

  void calcProgress() {
    if (isEvent) {
      // event progress is managed manually!
      return;
    }
    // TODO: this is yet inaccurate; scores are not weighted / ...
    double score = 0;
    double maxScore = 0;
    for (var item in items) {
      if (item.type == MbclLevelItemType.exercise) {
        var data = item.exerciseData!;
        // TODO: must store max store in data
        var exerciseScore =
            data.feedback == MbclExerciseFeedback.correct ? 1.0 : 0.0;
        if (exerciseScore > data.maxReachedScore) {
          data.maxReachedScore = exerciseScore;
        }
        score += data.maxReachedScore;
        maxScore += 1.0;
      }
    }
    if (maxScore < 1e-12) {
      progress = 0.0;
    } else {
      progress = score / maxScore;
    }
  }

  bool isLocked() {
    if (requires.isEmpty) {
      return false;
    }
    for (var req in requires) {
      if (req.progress < 0.8) {
        // TODO: constant!!
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> progressToJSON() {
    var exercisesData = {};
    for (var item in items) {
      switch (item.type) {
        case MbclLevelItemType.exercise:
          if (item.exerciseData!.feedback != MbclExerciseFeedback.unchecked) {
            exercisesData[item.label] = item.exerciseData!.progressToJSON();
          }
          break;
        default:
          break;
      }
    }
    return {
      "visited": visited,
      "progress": progress,
      "exercises": exercisesData
    };
  }

  progressFromJSON(Map<String, dynamic> src) {
    if (src.containsKey("visited")) {
      visited = src["visited"];
    }
    if (src.containsKey("progress")) {
      progress = src["progress"];
    }
    if (src.containsKey("exercises")) {
      for (var item in items) {
        switch (item.type) {
          case MbclLevelItemType.exercise:
            if (src["exercises"]!.containsKey(item.label)) {
              item.exerciseData!.progressFromJSON(src["exercises"][item.label]);
            }
            break;
          default:
            break;
        }
      }
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      "fileId": fileId,
      "error": error,
      "title": title,
      "label": label,
      //"posX": posX,
      //"posY": posY,
      "iconData": iconData,
      "numParts": numParts,
      "partIconIDs": partIconIDs.map((e) => e).toList(),
      "requires": requires.map((req) => req.fileId).toList(),
      "items": items.map((item) => item.toJSON()).toList(),
      "isEvent": isEvent,
      "disableBlockTitles": disableBlockTitles,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    fileId = src["fileId"];
    error = src["error"];
    title = src["title"];
    label = src["label"];
    //posX = src["posX"];
    //posY = src["posY"];
    iconData = src.containsKey("iconData") ? src["iconData"] : "";
    numParts = src.containsKey("numParts") ? src["numParts"] : 1;
    // icon ids
    partIconIDs = [];
    int n = src["partIconIDs"].length;
    for (var i = 0; i < n; i++) {
      partIconIDs.add(src["partIconIDs"][i]);
    }
    // requires
    requires = [];
    n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      requiresTmp.add(src["requires"][i]);
    }
    // items
    items = [];
    n = src["items"].length;
    for (var i = 0; i < n; i++) {
      var item = MbclLevelItem(this, MbclLevelItemType.error, -1);
      item.fromJSON(src["items"][i]);
      items.add(item);
    }
    // event
    isEvent = src["isEvent"];
    disableBlockTitles = src["disableBlockTitles"];
  }
}

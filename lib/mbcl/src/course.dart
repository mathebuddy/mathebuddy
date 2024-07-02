/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'dart:convert';
import 'dart:math';

import 'award.dart';
import 'chapter.dart';
import 'chat.dart';
import 'level.dart';
import 'level_item.dart';
import 'level_item_exercise.dart';
import 'persistence.dart';

enum MbclCourseDebug {
  no,
  chapter,
  level,
}

class MbclCourse {
  MbclCourseDebug debug = MbclCourseDebug.no;
  String courseId = '';
  String error = '';
  String title = '';
  String author = '';
  int mbclVersion = 1;
  int dateModified = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  List<MbclChapter> chapters = [];
  late MbclChat chat;
  MbclLevel? help;

  // persisted data
  MbclChapter? lastVisitedChapter;
  MbclAwards awards = MbclAwards();
  bool unlockAll = false;
  bool muteAudio = false;
  List<DateTime> daysPlayed = [];

  // not saved
  MbclPersistence? persistence;
  double progress = 0.0;

  MbclCourse() {
    chat = MbclChat(this);
  }

  MbclLevelItem? suggestExercise(List<MbclLevelItem> exclusionList) {
    for (var chapter in chapters) {
      for (var level in chapter.levels) {
        if (level.visited == false || level.isEvent) continue;
        for (var exercise in level.getExercises()) {
          var data = exercise.exerciseData!;
          if (data.feedback == MbclExerciseFeedback.incorrect ||
              data.feedback == MbclExerciseFeedback.unchecked) {
            if (exclusionList.contains(exercise) == false) {
              return exercise;
            }
          }
        }
      }
    }
    return null;
  }

  MbclLevel? suggestGame() {
    List<MbclLevel> candidates = [];
    for (var chapter in chapters) {
      for (var level in chapter.levels) {
        if (level.visited == false) continue;
        if (level.isEvent) {
          candidates.add(level);
        }
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    var idx = Random().nextInt(candidates.length);
    return candidates[idx];
  }

  setPersistence(MbclPersistence p) {
    persistence = p;
  }

  void calcProgress() {
    progress = 0.0;
    for (var chapter in chapters) {
      chapter.calcProgress();
      progress += chapter.progress;
    }
    progress /= chapters.length;
    updateAwards();
  }

  updateAwards() {
    // played X days in a row
    // (a) add current day, if now yet present
    var now = DateTime.now();
    var dayInDatabase = daysPlayed.isNotEmpty &&
        daysPlayed.last.year == now.year &&
        daysPlayed.last.month == now.month &&
        daysPlayed.last.day == now.day;
    if (dayInDatabase == false) {
      daysPlayed.add(now);
    }
    // (b) get the sorted list of days played as days since epoch
    var daysPlayedSinceEpoch = daysPlayed
        .map((x) => (x.millisecondsSinceEpoch / 1000 / 60 / 60 / 24).floor())
        .toList();
    daysPlayedSinceEpoch.sort();
    var maxRow = 0;
    for (var i = 0; i < daysPlayedSinceEpoch.length; i++) {
      for (var j = i + 1; j < daysPlayedSinceEpoch.length; j++) {
        if ((daysPlayedSinceEpoch[j] - daysPlayedSinceEpoch[j - 1]) != 1) break;
        maxRow = max(maxRow, j - i + 1);
      }
    }
    // (c) conditionally enable awards
    if (maxRow >= 3) {
      awards.enableAwardConditionally(MbclAwardType.played3daysInRow);
      if (maxRow >= 5) {
        awards.enableAwardConditionally(MbclAwardType.played5daysInRow);
        if (maxRow >= 5) {
          awards.enableAwardConditionally(MbclAwardType.played10daysInRow);
        }
      }
    }
    // passed first level / game / unit / chapter
    for (var chapter in chapters) {
      for (var level in chapter.levels) {
        if (level.progress > 0.8) {
          awards.enableAwardConditionally(MbclAwardType.passedFirstLevel);
          if (level.isEvent) {
            awards.enableAwardConditionally(MbclAwardType.passedFirstGame);
          }
        }
      }
      for (var unit in chapter.units) {
        if (unit.progress > 0.99) {
          awards.enableAwardConditionally(MbclAwardType.passedFirstUnit);
        }
      }
      if (chapter.progress > 0.99) {
        awards.enableAwardConditionally(MbclAwardType.passedFirstChapter);
      }
    }
  }

  String gatherErrors() {
    var err = error.isEmpty ? "" : "$error\n";
    for (var chapter in chapters) {
      err += chapter.gatherErrors();
    }
    if (err.isNotEmpty) {
      err = "@COURSE $courseId:\n$err";
    }
    return err;
  }

  MbclChapter? getChapterByLabel(String label) {
    for (var i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (chapter.label == label) return chapter;
    }
    return null;
  }

  MbclChapter? getChapterByFileID(String fileID) {
    for (var i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (chapter.fileId == fileID) return chapter;
    }
    return null;
  }

  Future<bool> loadUserData() async {
    //print("loading course user data");
    if (checkFileIO() == false) return false;
    var path = _getFilePath();
    try {
      var dataStringified = await persistence!.readFile(path);
      var dataJson = jsonDecode(dataStringified);
      progressFromJSON(dataJson);
    } catch (e) {
      print("could not load global user data (OK for first run)");
    }
    return true;
  }

  bool saveUserData() {
    calcProgress();
    //print("saving course user data");
    if (checkFileIO() == false) return false;
    var data = progressToJSON();
    var dataStringified = JsonEncoder.withIndent("  ").convert(data);
    var path = _getFilePath();
    persistence!.writeFile(path, dataStringified);
    return true;
  }

  String _getFilePath() {
    return "${courseId}_globals.json";
  }

  bool checkFileIO() {
    if (persistence == null) {
      print("WARNING: failed to save course.");
      return false;
    }
    if (courseId.isEmpty) {
      print("WARNING: can only save files while in course.");
      return false;
    }
    return true;
  }

  Map<String, dynamic> progressToJSON() {
    Map<String, dynamic> data = {};
    if (lastVisitedChapter != null) {
      data["last_visited_chapter"] = lastVisitedChapter!.fileId;
      if (lastVisitedChapter!.lastVisitedUnit != null) {
        data["last_visited_unit"] = lastVisitedChapter!.lastVisitedUnit!.id;
      }
      if (lastVisitedChapter!.lastVisitedLevel != null) {
        data["last_visited_level"] =
            lastVisitedChapter!.lastVisitedLevel!.fileId;
      }
    }
    data["awards"] = awards.toJSON();
    data["unlock_all"] = unlockAll;
    data["mute_audio"] = muteAudio;
    data["days_played"] =
        daysPlayed.map((e) => e.millisecondsSinceEpoch).toList();
    return data;
  }

  progressFromJSON(Map<String, dynamic> src) {
    if (src.containsKey("last_visited_chapter")) {
      var id = src["last_visited_chapter"];
      lastVisitedChapter = getChapterByFileID(id);
      if (lastVisitedChapter != null && src.containsKey("last_visited_unit")) {
        var id = src["last_visited_unit"];
        var unit = lastVisitedChapter!.getUnitById(id);
        lastVisitedChapter!.lastVisitedUnit = unit;
        if (unit != null && src.containsKey("last_visited_level")) {
          var id = src["last_visited_level"];
          var level = lastVisitedChapter!.getLevelByFileID(id);
          lastVisitedChapter!.lastVisitedLevel = level;
        }
      }
    }
    if (src.containsKey("awards")) {
      awards = MbclAwards();
      awards.fromJSON(src["awards"]);
    }
    if (src.containsKey("unlock_all")) {
      unlockAll = src["unlock_all"];
    }
    if (src.containsKey("mute_audio")) {
      muteAudio = src["mute_audio"];
    }
    if (src.containsKey("days_played")) {
      daysPlayed = [];
      var n = src["days_played"].length;
      for (var i = 0; i < n; i++) {
        daysPlayed
            .add(DateTime.fromMillisecondsSinceEpoch(src["days_played"][i]));
      }
    }
    calcProgress();
  }

  Map<String, Object> toJSON() {
    return {
      "courseId": courseId,
      "debug": debug.name,
      "error": error,
      "title": title,
      "author": author,
      "mbclVersion": mbclVersion,
      "dateModified": dateModified,
      "chapters": chapters.map((chapter) => chapter.toJSON()).toList(),
      "chat": chat.toJSON(),
      "help": help == null ? {} : help!.toJSON(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    courseId = src["courseId"];
    debug = MbclCourseDebug.values.byName(src["debug"]);
    error = src["error"];
    title = src["title"];
    author = src["author"];
    mbclVersion = src["mbclVersion"];
    dateModified = src["dateModified"];
    chapters = [];
    int n = src["chapters"].length;
    for (var i = 0; i < n; i++) {
      var chapter = MbclChapter(this);
      chapter.fromJSON(src["chapters"][i]);
      chapters.add(chapter);
    }
    // reconstruct requires attributes of chapters
    for (var ch in chapters) {
      for (var req in ch.requiresTmp) {
        ch.requires.add(getChapterByFileID(req)!);
      }
    }
    chat = MbclChat(this);
    chat.fromJSON(src["chat"]);
    if (src["help"].containsKey('fileId')) {
      var pseudoChapter = MbclChapter(this);
      help = MbclLevel(this, pseudoChapter);
      help!.fromJSON(src["help"]);
    }
  }
}

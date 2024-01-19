/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'dart:convert';

import 'chapter.dart';
import 'chat.dart';
import 'level_item.dart';
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

  // temporary
  MbclChapter? lastVisitedChapter;

  // not saved
  MbclPersistence? persistence;
  double progress = 0.0;

  MbclCourse() {
    chat = MbclChat(this);
  }

  MbclLevelItem? getSuggestedExercise() {
    // TODO!! now simple returning first one
    if (chapters.isEmpty) return null;
    var chapter = chapters[0];
    if (chapter.levels.isEmpty) return null;
    var level = chapter.levels[0];
    var exercises = level.getExercises();
    if (exercises.isEmpty) return null;
    return exercises[0];
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
  }

  String gatherErrors() {
    var err = error.isEmpty ? "" : "$error\n";
    for (var chapter in chapters) {
      err += chapter.gatherErrors();
    }
    if (err.isNotEmpty) {
      err = "@COURSE:\n$err";
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
    if (checkFileIO() == false) return false;
    var path = _getFilePath();
    try {
      var dataStringified = await persistence!.readFile(path);
      var dataJson = jsonDecode(dataStringified);
      progressFromJSON(dataJson);
    } catch (e) {
      print("could not load global user data (OK for first run)");
    }
    calcProgress();
    return true;
  }

  bool saveUserData() {
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
      "chat": chat.toJSON()
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
  }
}

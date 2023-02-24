/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'chapter.dart';

enum MbclCourseDebug {
  no,
  chapter,
  level,
}

class MbclCourse {
  MbclCourseDebug debug = MbclCourseDebug.no;
  String title = '';
  String author = '';
  int mbclVersion = 1;
  int dateModified = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  List<MbclChapter> chapters = [];

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

  Map<String, Object> toJSON() {
    return {
      "debug": debug.name,
      "title": title,
      "author": author,
      "mbclVersion": mbclVersion,
      "dateModified": dateModified,
      "chapters": chapters.map((chapter) => chapter.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    debug = MbclCourseDebug.values.byName(src["debug"]);
    title = src["title"];
    author = src["author"];
    mbclVersion = src["mbclVersion"];
    dateModified = src["dateModified"];
    chapters = [];
    int n = src["chapters"].length;
    for (var i = 0; i < n; i++) {
      var chapter = MbclChapter();
      chapter.fromJSON(src["chapters"][i]);
      chapters.add(chapter);
    }
  }
}

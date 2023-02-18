/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataChapter.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- COURSE --------

enum MBL_Course_Debug {
  No,
  Chapter,
  Level,
}

class MBL_Course {
  MBL_Course_Debug debug = MBL_Course_Debug.No;
  String title = '';
  String author = '';
  int mbcl_version = 1;
  int date_modified = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  List<MBL_Chapter> chapters = [];

  MBL_Chapter? getChapterByLabel(String label) {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      if (chapter.label == label) return chapter;
    }
    return null;
  }

  MBL_Chapter? getChapterByFileID(String fileID) {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      if (chapter.file_id == fileID) return chapter;
    }
    return null;
  }

  void postProcess() {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      chapter.postProcess();
    }
  }

  Map<String, Object> toJSON() {
    return {
      "debug": this.debug,
      "title": this.title,
      "author": this.author,
      "mbcl_version": this.mbcl_version,
      "date_modified": this.date_modified,
      "chapters": this.chapters.map((chapter) => chapter.toJSON()),
    };
  }
}

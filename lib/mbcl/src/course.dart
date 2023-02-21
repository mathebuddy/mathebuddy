/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html (TODO: update link!)

import 'chapter.dart';

enum MBCL_Course_Debug {
  No,
  Chapter,
  Level,
}

abstract class MBCL_Course__ABSTRACT {
  MBCL_Course_Debug debug = MBCL_Course_Debug.No;
  String title = '';
  String author = '';
  int mbcl_version = 1;
  int date_modified = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  List<MBCL_Chapter__ABSTRACT> chapters = [];

  void postProcess();

  MBCL_Chapter__ABSTRACT? getChapterByLabel(String label) {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      if (chapter.label == label) return chapter;
    }
    return null;
  }

  MBCL_Chapter__ABSTRACT? getChapterByFileID(String fileID) {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      if (chapter.file_id == fileID) return chapter;
    }
    return null;
  }

  Map<String, Object> toJSON() {
    return {
      "debug": this.debug.name,
      "title": this.title,
      "author": this.author,
      "mbclVersion": this.mbcl_version,
      "dateModified": this.date_modified,
      "chapters": this.chapters.map((chapter) => chapter.toJSON()),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
  }
}

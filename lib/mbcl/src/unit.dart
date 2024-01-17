/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

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

  // temporary
  List<String> levelFileIDs = [];

  void resetProgress() {
    for (var level in levels) {
      level.resetProgress();
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "title": title,
      "iconData": iconData,
      "levels": levels.map((level) => level.fileId).toList(),
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
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/course.dart';

import 'chapter.dart';
import 'level.dart';

void postProcessCourse(MbclCourse course) {
  for (var i = 0; i < course.chapters.length; i++) {
    var chapter = course.chapters[i];
    postProcessChapter(chapter);
  }
  if (course.help != null) {
    postProcessLevel(course.help!);
  }
}

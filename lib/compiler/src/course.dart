/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/course.dart';

class MBCL_Course extends MBCL_Course__ABSTRACT {
  @override
  void postProcess() {
    for (var i = 0; i < this.chapters.length; i++) {
      var chapter = this.chapters[i];
      chapter.postProcess();
    }
  }
}

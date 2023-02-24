/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/chapter.dart';

import 'level.dart';

void postProcessChapter(MBCL_Chapter chapter) {
  for (var i = 0; i < chapter.levels.length; i++) {
    var level = chapter.levels[i];
    postProcessLevel(level);
  }
}

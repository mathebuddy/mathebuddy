/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';

abstract class MBCL_Unit__ABSTRACT {
  String title = '';
  List<MBCL_Level__ABSTRACT> levels = [];

  Map<String, dynamic> toJSON() {
    return {
      "title": this.title,
      "levels": this.levels.map((level) => level.fileId).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
  }
}

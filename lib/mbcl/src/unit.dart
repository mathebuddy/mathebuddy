/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';

class MBCL_Unit {
  String title = '';
  List<MBCL_Level> levels = [];

  Map<String, dynamic> toJSON() {
    return {
      "title": this.title,
      "levels": this.levels.map((level) => level.fileId).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.title = src["title"];
    this.levels = [];
    int n = src["levels"].length;
    for (var i = 0; i < n; i++) {
      var level = new MBCL_Level();
      level.fromJSON(src["levels"][i]);
      this.levels.add(level);
    }
  }
}

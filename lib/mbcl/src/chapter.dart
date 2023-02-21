/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html (TODO: update link!)

import 'level.dart';
import 'unit.dart';

abstract class MBCL_Chapter__ABSTRACT {
  String file_id =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  String author = '';
  int pos_x = -1;
  int pos_y = -1;
  List<MBCL_Chapter__ABSTRACT> requires = [];
  List<String> requires_tmp = []; // only used while compiling
  List<MBCL_Unit__ABSTRACT> units = [];
  List<MBCL_Level__ABSTRACT> levels = [];

  void postProcess();

  MBCL_Level__ABSTRACT? getLevelByLabel(String label) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.label == label) return level;
    }
    return null;
  }

  MBCL_Level__ABSTRACT? getLevelByFileID(String fileID) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.file_id == fileID) return level;
    }
    return null;
  }

  Map<String, dynamic> toJSON() {
    return {
      "fileId": this.file_id,
      "title": this.title,
      "label": this.label,
      "author": this.author,
      "posX": this.pos_x,
      "posY": this.pos_y,
      "requires": this.requires.map((req) => req.file_id).toList(),
      "units": this.units.map((unit) => unit.toJSON()).toList(),
      "levels": this.levels.map((level) => level.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
  }
}

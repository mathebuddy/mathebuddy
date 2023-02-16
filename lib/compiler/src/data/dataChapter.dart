/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataLevel.dart';
import 'dataUnit.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- CHAPTER --------

class MBL_Chapter {
  String file_id =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  String author = '';
  int pos_x = -1;
  int pos_y = -1;
  List<MBL_Chapter> requires = [];
  List<String> requires_tmp = []; // only used while compiling
  List<MBL_Unit> units = [];
  List<MBL_Level> levels = [];

  MBL_Level? getLevelByLabel(String label) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.label == label) return level;
    }
    return null;
  }

  MBL_Level? getLevelByFileID(String fileID) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.file_id == fileID) return level;
    }
    return null;
  }

  void postProcess() {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      level.postProcess();
    }
  }

  Map<Object, Object> toJSON() {
    return {
      file_id: this.file_id,
      title: this.title,
      author: this.author,
      label: this.label,
      pos_x: this.pos_x,
      pos_y: this.pos_y,
      requires: this.requires.map((req) => req.file_id),
      units: this.units.map((unit) => unit.toJSON()),
      levels: this.levels.map((level) => level.toJSON()),
    };
  }
}

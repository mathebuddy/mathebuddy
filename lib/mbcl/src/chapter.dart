/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';
import 'unit.dart';

class MBCL_Chapter {
  String fileId =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  String author = '';
  int posX = -1;
  int posY = -1;
  List<MBCL_Chapter> requires = [];
  List<String> requires_tmp = []; // only used while compiling
  List<MBCL_Unit> units = [];
  List<MBCL_Level> levels = [];

  MBCL_Level? getLevelByLabel(String label) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.label == label) return level;
    }
    return null;
  }

  MBCL_Level? getLevelByFileID(String fileID) {
    for (var i = 0; i < this.levels.length; i++) {
      var level = this.levels[i];
      if (level.fileId == fileID) return level;
    }
    return null;
  }

  Map<String, dynamic> toJSON() {
    return {
      "fileId": this.fileId,
      "title": this.title,
      "label": this.label,
      "author": this.author,
      "posX": this.posX,
      "posY": this.posY,
      "requires": this.requires.map((req) => req.fileId).toList(),
      "units": this.units.map((unit) => unit.toJSON()).toList(),
      "levels": this.levels.map((level) => level.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.fileId = src["fileId"];
    this.title = src["title"];
    this.label = src["label"];
    this.author = src["author"];
    this.posX = src["posX"];
    this.posY = src["posY"];
    // units
    this.units = [];
    int n = src["units"].length;
    for (var i = 0; i < n; i++) {
      var unit = new MBCL_Unit();
      unit.fromJSON(src["units"][i]);
      this.units.add(unit);
    }
    // levels
    this.levels = [];
    n = src["levels"].length;
    for (var i = 0; i < n; i++) {
      var level = new MBCL_Level();
      level.fromJSON(src["levels"][i]);
      this.levels.add(level);
    }
    // requires
    this.requires = [];
    n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      this.requires_tmp.add(src["requires"][i]);
      // TODO: this.requires!!!
    }
  }
}

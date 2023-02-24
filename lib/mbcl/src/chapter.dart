/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';
import 'unit.dart';

class MbclChapter {
  String fileId =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  String author = '';
  int posX = -1;
  int posY = -1;
  List<MbclChapter> requires = [];
  List<String> requiresTmp = []; // only used while compiling
  List<MbclUnit> units = [];
  List<MbclLevel> levels = [];

  MbclLevel? getLevelByLabel(String label) {
    for (var i = 0; i < levels.length; i++) {
      var level = levels[i];
      if (level.label == label) return level;
    }
    return null;
  }

  MbclLevel? getLevelByFileID(String fileID) {
    for (var i = 0; i < levels.length; i++) {
      var level = levels[i];
      if (level.fileId == fileID) return level;
    }
    return null;
  }

  Map<String, dynamic> toJSON() {
    return {
      "fileId": fileId,
      "title": title,
      "label": label,
      "author": author,
      "posX": posX,
      "posY": posY,
      "requires": requires.map((req) => req.fileId).toList(),
      "units": units.map((unit) => unit.toJSON()).toList(),
      "levels": levels.map((level) => level.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    fileId = src["fileId"];
    title = src["title"];
    label = src["label"];
    author = src["author"];
    posX = src["posX"];
    posY = src["posY"];
    // units
    units = [];
    int n = src["units"].length;
    for (var i = 0; i < n; i++) {
      var unit = MbclUnit();
      unit.fromJSON(src["units"][i]);
      units.add(unit);
    }
    // levels
    levels = [];
    n = src["levels"].length;
    for (var i = 0; i < n; i++) {
      var level = MbclLevel();
      level.fromJSON(src["levels"][i]);
      levels.add(level);
    }
    // requires
    requires = [];
    n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      requiresTmp.add(src["requires"][i]);
      // TODO: requires!!!
    }
  }
}

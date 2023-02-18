/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- LEVEL --------

class MBL_Level {
  String file_id =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  int pos_x = -1;
  int pos_y = -1;
  List<MBL_Level> requires = [];
  List<String> requires_tmp = []; // only used while compiling
  List<MBL_LevelItem> items = [];

  void postProcess() {
    for (var i = 0; i < this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
  }

  Map<String, Object> toJSON() {
    return {
      "file_id": this.file_id,
      "title": this.title,
      "label": this.label,
      "pos_x": this.pos_x,
      "pos_y": this.pos_y,
      "requires": this.requires.map((req) => req.file_id),
      "items": this.items.map((item) => item.toJSON()),
    };
  }
}

enum MBL_LevelItemType {
  Definition,
  Equation,
  Error,
  Example,
  Exercise,
  Figure,
  NewPage,
  Section,
  SubSection,
  Table,
  Text
}

abstract class MBL_LevelItem {
  MBL_LevelItemType type; // = MBL_LevelItemType.Error;
  String title = '';
  String label = '';
  String error = '';

  MBL_LevelItem(this.type);

  void postProcess();

  Map<String, Object> toJSON();
}

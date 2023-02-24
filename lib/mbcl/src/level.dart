/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level_item.dart';

class MBCL_Level {
  String fileId =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  int posX = -1;
  int posY = -1;
  List<MBCL_Level> requires = [];
  List<String> requires_tmp = []; // only used while compiling
  List<MBCL_LevelItem> items = [];

  Map<String, dynamic> toJSON() {
    return {
      "fileId": this.fileId,
      "title": this.title,
      "label": this.label,
      "posX": this.posX,
      "posY": this.posY,
      "requires": this.requires.map((req) => req.fileId).toList(),
      "items": this.items.map((item) => item.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.fileId = src["fileId"];
    this.title = src["title"];
    this.label = src["label"];
    this.posX = src["posX"];
    this.posY = src["posY"];
    // requires
    this.requires = [];
    int n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      this.requires_tmp.add(src["requires"][i]);
      // TODO: this.requires!!!
    }
    // items
    this.items = [];
    n = src["items"].length;
    for (var i = 0; i < n; i++) {
      var item = new MBCL_LevelItem(MBCL_LevelItemType.Error);
      item.fromJSON(src["items"][i]);
      this.items.add(item);
    }
  }
}

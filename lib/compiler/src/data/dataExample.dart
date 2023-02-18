/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataLevel.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- EXAMPLE --------

class MBL_Example extends MBL_LevelItem {
  List<MBL_LevelItem> items = [];

  MBL_Example() : super(MBL_LevelItemType.Example);

  void postProcess() {
    for (var i = 0; i < this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
  }

  Map<String, Object> toJSON() {
    return {
      "type": this.type,
      "title": this.title,
      "label": this.label,
      "error": this.error,
      "items": this.items.map((item) => item.toJSON()),
    };
  }
}

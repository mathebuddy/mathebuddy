/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'level_item.dart';

class MbclFigureData {
  MbclLevelItem figure;
  String filePath = '';
  String code = '';
  String data = '';
  int widthPercentage = 100;
  List<MbclLevelItem> caption = [];

  bool zoomed = false;

  MbclFigureData(this.figure);

  Map<String, dynamic> toJSON() {
    return {
      "filePath": filePath,
      "code": code,
      "data": data,
      "widthPercentage": widthPercentage,
      "caption": caption.map((e) => e.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    filePath = src["filePath"];
    code = src["code"];
    data = src["data"];
    widthPercentage = src["widthPercentage"];
    int n = src["caption"].length;
    for (var i = 0; i < n; i++) {
      var cap = MbclLevelItem(figure.level, MbclLevelItemType.error, -1);
      cap.fromJSON(src["caption"][i]);
      caption.add(cap);
    }
  }
}

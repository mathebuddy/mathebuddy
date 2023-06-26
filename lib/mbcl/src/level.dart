/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level_item.dart';

class MbclLevel {
  // import/export
  String fileId =
      ''; // all references go here; label is only used for searching
  String title = '';
  String label = '';
  int posX = -1;
  int posY = -1;
  String iconData = '';
  int numParts = 0;
  List<String> partIconIDs = [];
  List<MbclLevel> requires = [];
  List<MbclLevelItem> items = [];

  // temporary
  List<String> requiresTmp = [];

  Map<String, dynamic> toJSON() {
    return {
      "fileId": fileId,
      "title": title,
      "label": label,
      "posX": posX,
      "posY": posY,
      "iconData": iconData,
      "numParts": numParts,
      "partIconIDs": partIconIDs.map((e) => e).toList(),
      "requires": requires.map((req) => req.fileId).toList(),
      "items": items.map((item) => item.toJSON()).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    fileId = src["fileId"];
    title = src["title"];
    label = src["label"];
    posX = src["posX"];
    posY = src["posY"];
    iconData = src.containsKey("iconData") ? src["iconData"] : "";
    numParts = src.containsKey("numParts") ? src["numParts"] : 1;
    // icon ids
    partIconIDs = [];
    int n = src["partIconIDs"].length;
    for (var i = 0; i < n; i++) {
      partIconIDs.add(src["partIconIDs"][i]);
    }
    // requires
    requires = [];
    n = src["requires"].length;
    for (var i = 0; i < n; i++) {
      requiresTmp.add(src["requires"][i]);
    }
    // items
    items = [];
    n = src["items"].length;
    for (var i = 0; i < n; i++) {
      var item = MbclLevelItem(MbclLevelItemType.error, -1);
      item.fromJSON(src["items"][i]);
      items.add(item);
    }
  }
}

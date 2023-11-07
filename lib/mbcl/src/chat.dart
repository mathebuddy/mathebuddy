/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';
import 'level_item.dart';

class MbclChat {
  Map<String, MbclChatDefinition> definitions = {};

  MbclChatDefinition? getDefinition(String label) {
    // TODO: search for similar labels
    label = label.toLowerCase();
    if (definitions.containsKey(label)) {
      return definitions[label];
    }
    return null;
  }

  Map<String, Object> toJSON() {
    return {
      "definitions":
          definitions.map((key, value) => MapEntry(key, value.toJSON()))
    };
  }

  fromJSON(Map<String, dynamic> src) {
    definitions = {};
    for (var key in src["definitions"].keys) {
      definitions[key] = MbclChatDefinition.fromJSON(src["definitions"][key]);
    }
  }
}

class MbclChatDefinition {
  String label;
  String levelPath;
  MbclLevelItem data;

  MbclChatDefinition(this.label, this.levelPath, this.data);

  Map<String, Object> toJSON() {
    return {"label": label, "levelPath": levelPath, "data": data.toJSON()};
  }

  static fromJSON(Map<String, dynamic> src) {
    var level = MbclLevel(); // TODO
    var levelItem = MbclLevelItem(level, MbclLevelItemType.error, -1);
    levelItem.fromJSON(src["data"]);
    return MbclChatDefinition(src["label"], src["levelPath"], levelItem);
  }
}

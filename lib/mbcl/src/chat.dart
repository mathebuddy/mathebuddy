/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'chapter.dart';
import 'course.dart';
import 'level.dart';
import 'level_item.dart';

class MbclChat {
  MbclCourse course;
  late MbclChapter pseudoChapter;
  late MbclLevel pseudoLevel;
  Map<String, MbclChatDefinition> definitions = {};

  MbclChat(this.course) {
    pseudoChapter = MbclChapter(course);
    pseudoLevel = MbclLevel(course, pseudoChapter);
  }

  List<String> getSimilarKeywords(String label) {
    if (label.length < 3) return [];
    List<String> result = [];
    for (var definition in definitions.entries) {
      var key = definition.key;
      // TODO: does not work for SIMILAR writings
      if (key.contains(label)) {
        result.add(key);
      }
    }
    return result;
  }

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
      definitions[key] =
          MbclChatDefinition.fromJSON(src["definitions"][key], pseudoLevel);
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

  static fromJSON(Map<String, dynamic> src, MbclLevel pseudoLevel) {
    var levelItem = MbclLevelItem(pseudoLevel, MbclLevelItemType.text, -1);
    levelItem.fromJSON(src["data"]);
    return MbclChatDefinition(src["label"], src["levelPath"], levelItem);
  }
}

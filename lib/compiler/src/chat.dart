/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/course.dart';
import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/chat.dart';

class ChatInformationRetrieval {
  MbclChat run(MbclCourse course) {
    var chatData = MbclChat(course);
    for (var chapter in course.chapters) {
      for (var level in chapter.levels) {
        for (var item in level.items) {
          /// TODO: include other def* types
          if (item.type == MbclLevelItemType.defDefinition) {
            if (item.chatKeys.isNotEmpty) {
              var chatKeys = item.chatKeys.split(",");
              for (var chatKey in chatKeys) {
                chatKey = chatKey.trim().toLowerCase();
                // TODO (low prio): high memory consumption in case of many keys
                // TODO (low prio): better save data only once
                var levelPath = "${chapter.fileId}/${level.fileId}";
                var pseudoLevel = MbclLevel(course, chapter);
                var paragraph = extractParagraph(item, pseudoLevel);
                var cd = MbclChatDefinition(chatKey, levelPath, paragraph);
                chatData.definitions[chatKey] = cd;
              }
            }
          }
        }
      }
    }
    return chatData;
  }

  MbclLevelItem extractParagraph(MbclLevelItem item, MbclLevel level) {
    MbclLevelItem p = MbclLevelItem(level, MbclLevelItemType.paragraph, -1);
    for (var subItem in item.items) {
      switch (subItem.type) {
        case MbclLevelItemType.paragraph:
          p.items.addAll(subItem.items);
          break;
        case MbclLevelItemType.equation:
          var data = subItem.equationData!;
          p.items.add(data.math!);
          break;
        case MbclLevelItemType.itemize:
        case MbclLevelItemType.enumerate:
          var i = 0;
          for (var bullet in subItem.items) {
            var label = "";
            if (subItem.type == MbclLevelItemType.itemize) {
              label += String.fromCharCode("a".codeUnitAt(0) + i);
              label = " ($label) ";
            } else {
              label += String.fromCharCode("1".codeUnitAt(0) + i);
              label = " $label. ";
            }
            p.items
                .add(MbclLevelItem(level, MbclLevelItemType.text, -1, label));
            p.items.addAll(bullet.items);
            i++;
          }
          p.items.add(MbclLevelItem(level, MbclLevelItemType.text, -1, " // "));
          break;
        default:
        // TODO
      }
    }
    return p;
  }
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/course.dart';
import '../../mbcl/src/level_item.dart';

class ReferenceSolver {
  MbclCourse course;
  Map<String, MbclLevelItem> labels = {};

  ReferenceSolver(this.course);

  run() {
    // (a) gather all labels
    labels = {};
    for (var chapter in course.chapters) {
      for (var level in chapter.levels) {
        for (var item in level.items) {
          gatherLabels(item);
        }
      }
    }
    // (b) set reference texts
    for (var chapter in course.chapters) {
      for (var level in chapter.levels) {
        for (var item in level.items) {
          processReferences(item);
        }
      }
    }
  }

  gatherLabels(MbclLevelItem item) {
    for (var item in item.items) {
      gatherLabels(item);
    }
    if (item.type != MbclLevelItemType.reference) {
      if (item.label.isNotEmpty) {
        labels[item.label] = item;
      }
    }
  }

  processReferences(MbclLevelItem item) {
    for (var item in item.items) {
      processReferences(item);
    }
    if (item.type == MbclLevelItemType.reference) {
      var referencedItem = labels[item.label];
      if (referencedItem == null) {
        item.error = "unknown Label";
      } else {
        switch (referencedItem.type) {
          case MbclLevelItemType.section:
          case MbclLevelItemType.subSection:
            item.text = referencedItem.text;
            break;
          case MbclLevelItemType.equation:
            item.text = "Eq. (${referencedItem.id})";
            break;
          default:
            item.error = "reference type unimplemented";
            break;
        }
      }
    }
  }
}

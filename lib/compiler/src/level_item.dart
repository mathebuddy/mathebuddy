/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/level_item.dart';

void postProcessLevelItem(MbclLevelItem levelItem) {
  for (var i = 0; i < levelItem.items.length; i++) {
    var item = levelItem.items[i];
    postProcessLevelItem(item);
  }
  switch (levelItem.type) {
    case MbclLevelItemType.alignCenter:
    case MbclLevelItemType.alignLeft:
    case MbclLevelItemType.alignRight:
    case MbclLevelItemType.boldText:
    case MbclLevelItemType.color:
    case MbclLevelItemType.enumerate:
    case MbclLevelItemType.enumerateAlpha:
    case MbclLevelItemType.inlineMath:
    case MbclLevelItemType.italicText:
    case MbclLevelItemType.itemize:
    case MbclLevelItemType.paragraph:
    case MbclLevelItemType.span:
      aggregateText(levelItem.items);
      if (levelItem.type == MbclLevelItemType.paragraph) {
        aggregateMultipleChoice(levelItem.items);
        aggregateSingleChoice(levelItem.items);
      }
      break;
    default:
      break;
  }
}

void aggregateText(List<MbclLevelItem> items) {
  // remove unnecessary line feeds
  while (items.length > 0 && items[0].type == MbclLevelItemType.lineFeed) {
    items.removeAt(0);
  }
  while (items.length > 0 &&
      items[items.length - 1].type == MbclLevelItemType.lineFeed) {
    items.removeLast();
  }
  // concatenate consecutive text items
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MbclLevelItemType.text &&
        items[i].type == MbclLevelItemType.text) {
      var text = items[i].text;
      if ('.,:!?'.contains(text) == false) {
        text = ' ' + text;
      }
      items[i - 1].text += text;
      // TODO: next line is an ugly hack for TeX..
      items[i - 1].text = items[i - 1].text.replaceAll("\\ ", '\\');
      items.removeAt(i);
      i--;
    }
  }
}

void aggregateMultipleChoice(List<MbclLevelItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MbclLevelItemType.multipleChoice &&
        items[i].type == MbclLevelItemType.multipleChoice) {
      var u = items[i - 1];
      var v = items[i];
      u.items.addAll(v.items);
      items.removeAt(i);
      i--;
    }
  }
}

void aggregateSingleChoice(List<MbclLevelItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MbclLevelItemType.singleChoice &&
        items[i].type == MbclLevelItemType.singleChoice) {
      var u = items[i - 1];
      var v = items[i];
      u.items.addAll(v.items);
      items.removeAt(i);
      i--;
    }
  }
}

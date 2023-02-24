/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/level_item.dart';

void postProcessLevelItem(MBCL_LevelItem levelItem) {
  for (var i = 0; i < levelItem.items.length; i++) {
    var item = levelItem.items[i];
    postProcessLevelItem(item);
  }
  switch (levelItem.type) {
    case MBCL_LevelItemType.AlignCenter:
    case MBCL_LevelItemType.AlignLeft:
    case MBCL_LevelItemType.AlignRight:
    case MBCL_LevelItemType.BoldText:
    case MBCL_LevelItemType.Color:
    case MBCL_LevelItemType.Enumerate:
    case MBCL_LevelItemType.EnumerateAlpha:
    case MBCL_LevelItemType.InlineMath:
    case MBCL_LevelItemType.ItalicText:
    case MBCL_LevelItemType.Itemize:
    case MBCL_LevelItemType.Paragraph:
    case MBCL_LevelItemType.Span:
      aggregateText(levelItem.items);
      if (levelItem.type == MBCL_LevelItemType.Paragraph) {
        aggregateMultipleChoice(levelItem.items);
        aggregateSingleChoice(levelItem.items);
      }
      break;
    default:
      break;
  }
}

void aggregateText(List<MBCL_LevelItem> items) {
  // remove unnecessary line feeds
  while (items.length > 0 && items[0].type == MBCL_LevelItemType.LineFeed) {
    items.removeAt(0);
  }
  while (items.length > 0 &&
      items[items.length - 1].type == MBCL_LevelItemType.LineFeed) {
    items.removeLast();
  }
  // concatenate consecutive text items
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MBCL_LevelItemType.Text &&
        items[i].type == MBCL_LevelItemType.Text) {
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

void aggregateMultipleChoice(List<MBCL_LevelItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MBCL_LevelItemType.MultipleChoice &&
        items[i].type == MBCL_LevelItemType.MultipleChoice) {
      var u = items[i - 1];
      var v = items[i];
      u.items.addAll(v.items);
      items.removeAt(i);
      i--;
    }
  }
}

void aggregateSingleChoice(List<MBCL_LevelItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (i > 0 &&
        items[i - 1].type == MBCL_LevelItemType.SingleChoice &&
        items[i].type == MBCL_LevelItemType.SingleChoice) {
      var u = items[i - 1];
      var v = items[i];
      u.items.addAll(v.items);
      items.removeAt(i);
      i--;
    }
  }
}

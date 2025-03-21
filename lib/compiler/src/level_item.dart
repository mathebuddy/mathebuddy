/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_compiler;

import '../../mbcl/src/level_item.dart';

void postProcessLevelItem(MbclLevelItem levelItem) {
  for (var i = 0; i < levelItem.items.length; i++) {
    var item = levelItem.items[i];
    postProcessLevelItem(item);
  }
  aggregateText(levelItem.items);
  aggregateMultipleChoice(levelItem.items);
  aggregateSingleChoice(levelItem.items);
  removeEmptyParagraphs(levelItem.items);
  // remove spaces
  for (var item in levelItem.items) {
    if (item.type == MbclLevelItemType.text) {
      item.text = item.text.replaceAll("\n ", "\n");
    }
  }
  // equation data
  if (levelItem.equationData != null) {
    var data = levelItem.equationData!;
    if (data.math != null) {
      postProcessLevelItem(data.math!);
    }
  }
  // figure data
  if (levelItem.figureData != null) {
    var data = levelItem.figureData!;
    for (var captionItem in data.caption) {
      postProcessLevelItem(captionItem);
    }
  }
  // table data
  if (levelItem.tableData != null) {
    var data = levelItem.tableData!;
    // TODO: data.caption
    for (var column in data.head.columns) {
      postProcessLevelItem(column);
    }
    for (var row in data.rows) {
      for (var column in row.columns) {
        postProcessLevelItem(column);
      }
    }
  }
}

void removeEmptyParagraphs(List<MbclLevelItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (items[i].type == MbclLevelItemType.paragraph) {
      if (items[i].items.isEmpty) {
        items.removeAt(i);
        i--;
      }
    }
  }
}

void aggregateText(List<MbclLevelItem> items) {
  // remove unnecessary line feeds
  while (items.isNotEmpty && items[0].type == MbclLevelItemType.lineFeed) {
    items.removeAt(0);
  }
  while (items.isNotEmpty &&
      items[items.length - 1].type == MbclLevelItemType.lineFeed) {
    items.removeLast();
  }
  // concatenate consecutive text items
  // !!!!! TODO: ACTIVATE AGAIN !!!!!
  // for (var i = 0; i < items.length; i++) {
  //   if (i > 0 &&
  //       items[i - 1].type == MbclLevelItemType.text &&
  //       items[i].type == MbclLevelItemType.text) {
  //     var text = items[i].text;
  //     if ('.,:!?)]'.contains(text) == false) {
  //       text = ' $text';
  //     }
  //     items[i - 1].text += text;
  //     // next line is an ugly hack for TeX..
  //     items[i - 1].text = items[i - 1].text.replaceAll("\\ ", '\\');
  //     // next lines provide an ugly hack for opening parentheses
  //     items[i - 1].text = items[i - 1].text.replaceAll("( ", "(");
  //     items[i - 1].text = items[i - 1].text.replaceAll("[ ", "[");
  //     items.removeAt(i);
  //     i--;
  //   }
  // }
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

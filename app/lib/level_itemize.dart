/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'level.dart';

Widget generateItemize(LevelState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  List<Row> rows = [];
  for (var i = 0; i < item.items.length; i++) {
    var subItem = item.items[i];
    Widget leading = Padding(
        padding: EdgeInsets.only(left: 8, top: 14.5),
        child: Icon(
          Icons.fiber_manual_record,
          size: 8,
        ));
    if (item.type == MbclLevelItemType.enumerate) {
      leading = Padding(
          padding: EdgeInsets.only(top: 4.0, left: 7.0),
          child: Text("${i + 1}."));
    } else if (item.type == MbclLevelItemType.enumerateAlpha) {
      leading = Padding(
          padding: EdgeInsets.only(top: 4.0, left: 7.0),
          child: Text("${String.fromCharCode("a".codeUnitAt(0) + i)})"));
    }
    var content =
        generateLevelItem(state, level, subItem, exerciseData: exerciseData);
    var row = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [SizedBox(width: 30, child: leading)]),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  child: content)),
        ]);
    rows.add(row);
  }
  return Column(children: rows);
}

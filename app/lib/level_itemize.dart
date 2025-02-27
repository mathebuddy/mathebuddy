/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'package:mathebuddy/level_item.dart';

Widget generateItemize(State state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData, Color textColor = Colors.black}) {
  List<Row> rows = [];
  for (var i = 0; i < item.items.length; i++) {
    var subItem = item.items[i];
    Widget leading = Padding(
        padding: EdgeInsets.only(left: 8, top: 14.5),
        child: Icon(
          Icons.fiber_manual_record,
          size: 8,
          color: textColor,
        ));
    if (item.type == MbclLevelItemType.enumerate) {
      leading = Padding(
        padding: EdgeInsets.only(top: 4.0, left: 7.0),
        child: Text(
          "${i + 1}.",
          style: TextStyle(color: textColor),
        ),
      );
    } else if (item.type == MbclLevelItemType.enumerateAlpha) {
      leading = Padding(
          padding: EdgeInsets.only(top: 4.0, left: 7.0),
          child: Text("${String.fromCharCode("a".codeUnitAt(0) + i)})",
              style: TextStyle(color: textColor)));
    }
    var content = generateLevelItem(state, level, subItem,
        exerciseData: exerciseData, textColor: textColor);
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

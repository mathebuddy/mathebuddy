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

import 'package:mathebuddy/level_paragraph.dart';

Widget generateEquation(State state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  var data = item.equationData!;
  var eq = generateParagraphItem(state, data.math!, exerciseData: exerciseData);
  var equationWidget = RichText(text: TextSpan(children: [eq]));
  var eqNumber = data.number;
  var eqNumberWidget = Text(eqNumber >= 0 ? '($eqNumber)' : '');
  Widget content;
  if (item.equationData!.leftAligned) {
    content = equationWidget;
  } else {
    content = Center(child: equationWidget);
  }
  return ListTile(
    title: content,
    trailing: eqNumberWidget,
  );
}

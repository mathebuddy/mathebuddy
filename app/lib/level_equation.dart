/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'main.dart';
import 'level_paragraph_item.dart';

Widget generateEquation(
    CoursePageState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  var data = item.equationData!;
  var eq = generateParagraphItem(state, data.math!, exerciseData: exerciseData);
  var equationWidget = RichText(text: TextSpan(children: [eq]));
  var eqNumber = data.number;
  var eqNumberWidget = Text(eqNumber >= 0 ? '($eqNumber)' : '');
  return ListTile(
    title: Center(child: equationWidget),
    trailing: eqNumberWidget,
  );
}

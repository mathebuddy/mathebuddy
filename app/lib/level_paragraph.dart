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

Widget generateParagraph(
    CoursePageState state, MbclLevel level, MbclLevelItem item,
    {paragraphPaddingLeft = 3.0,
    paragraphPaddingRight = 3.0,
    paragraphPaddingTop = 10.0,
    paragraphPaddingBottom = 5.0,
    MbclExerciseData? exerciseData}) {
  List<InlineSpan> list = [];
  for (var subItem in item.items) {
    list.add(generateParagraphItem(state, subItem, exerciseData: exerciseData));
  }
  var richText = RichText(
    text: TextSpan(children: list),
  );
  return Padding(
    padding: EdgeInsets.only(
        left: paragraphPaddingLeft,
        right: paragraphPaddingRight,
        top: paragraphPaddingTop,
        bottom: paragraphPaddingBottom),
    child: richText,
  );
}

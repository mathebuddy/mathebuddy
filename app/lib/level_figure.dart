/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'main.dart';
import 'level.dart';
import 'screen.dart';

Widget generateFigure(
    CoursePageState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  List<Widget> rows = [];
  var figureData = item.figureData as MbclFigureData;
  // image
  var width = 100;
  for (var option in figureData.options) {
    switch (option) {
      case MbclFigureOption.width100:
        width = 100;
        break;
      case MbclFigureOption.width75:
        width = 75;
        break;
      case MbclFigureOption.width66:
        width = 66;
        break;
      case MbclFigureOption.width50:
        width = 50;
        break;
      case MbclFigureOption.width33:
        width = 33;
        break;
      case MbclFigureOption.width25:
        width = 25;
        break;
    }
  }
  if (figureData.data.startsWith('<svg') ||
      figureData.data.startsWith('<?xml')) {
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.string(
        figureData.data,
        width: screenWidth * width / 100.0 - 15.0,
      )
    ]));
  }
  // caption
  if (figureData.caption.isNotEmpty) {
    Widget caption = generateLevelItem(state, level, figureData.caption[0]);
    rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [caption]));
  }
  // create column widget
  return Column(children: rows);
}

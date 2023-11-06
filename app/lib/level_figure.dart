/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'package:mathebuddy/level.dart';

Widget generateFigure(LevelState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  List<Widget> rows = [];
  var figureData = item.figureData as MbclFigureData;
  // image
  var width = figureData.widthPercentage;
  var screenWidth = MediaQuery.of(state.context).size.width;
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

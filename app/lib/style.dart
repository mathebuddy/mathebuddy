/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

class Style {
  Color matheBuddyRed = Color.fromARGB(0xFF, 0xAA, 0x32, 0x2C);
  Color matheBuddyYellow = Colors.amber.shade700;
  Color matheBuddyGreen = Colors.green.shade700;
  // appbar
  Color appbarBackgroundColor = Colors.black87;
  Color appbarDebugButtonColor = Colors.white;
  double appbarDebugButtonFontSize = 12;
  double appbarDebugButtonBorderSize = 1;
  Color appbarIconActiveColor = Colors.white;
  Color appbarIconInactiveColor = const Color.fromARGB(221, 102, 102, 102);
  // course
  Color courseTitleFontColor = Colors.black;
  double courseTitleFontSize = 36;
  FontWeight courseTitleFontWeight = FontWeight.w300;
  Color courseAuthorFontColor = Colors.black;
  double courseAuthorFontSize = 18;
  FontWeight courseAuthorFontWeight = FontWeight.w200;
  Color courseSubTitleFontColor = Colors.black;
  double courseSubTitleFontSize = 24;
  FontWeight courseSubTitleFontWeight = FontWeight.w200;
  List<Color> courseColors = [
    Colors.blueAccent,
    Colors.purple,
    Colors.green,
    Colors.red
  ];
  // chapter
  Color chapterTitleFontColor = Colors.black;
  double chapterTitleFontSize = 28;
  // unit
  Color unitTitleFontColor = Colors.black;
  double unitTitleFontSize = 28;
  Color unitOverviewFontColor = Colors.white;
  double unitOverviewFontSize = 20;
  // level
  double levelTitleFontSize = 28;
  Color levelTitleColor = Colors.black;
  FontWeight levelTitleFontWeight = FontWeight.w600;
  // section
  double sectionFontSize = 28;
  Color sectionColor = Colors.black54;
  FontWeight sectionFontWidth = FontWeight.w600;
  // sub-section
  double subSectionFontSize = 22;
  Color subSectionColor = Colors.black54;
  FontWeight subSectionFontWidth = FontWeight.w600;
  // exercises
  double exerciseEvalButtonWidth = 75;
  double exerciseEvalButtonBorderWidth = 2.5;
  double exerciseEvalButtonBorderRadius = 20;
  double exerciseEvalButtonFontSize = 24;
  double multiChoiceButtonSize = 35;

  Color getFeedbackColor(MbclExerciseFeedback? feedback) {
    if (feedback == null) return matheBuddyYellow;
    switch (feedback) {
      case MbclExerciseFeedback.unchecked:
        //return matheBuddyYellow;
        return matheBuddyRed;
      //return Colors.black;
      case MbclExerciseFeedback.correct:
        return matheBuddyGreen;
      case MbclExerciseFeedback.incorrect:
        return matheBuddyRed;
    }
  }
}

// used for hot flutter reload, s.t. style can be
// designed while running the up

var _style = Style();
Style getStyle() {
  return _style;
}

void refreshStyle() {
  _style = Style();
}

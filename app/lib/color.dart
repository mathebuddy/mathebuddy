/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

var matheBuddyRed = Color.fromARGB(0xFF, 0xAA, 0x32, 0x2C);
var matheBuddyYellow = Colors.amber.shade700;
var matheBuddyGreen = Colors.green.shade700;

Color getFeedbackColor(MbclExerciseFeedback? feedback) {
  if (feedback == null) return matheBuddyYellow;
  switch (feedback) {
    case MbclExerciseFeedback.unchecked:
      //return matheBuddyYellow;
      return matheBuddyRed;
    case MbclExerciseFeedback.correct:
      return matheBuddyGreen;
    case MbclExerciseFeedback.incorrect:
      return matheBuddyRed;
  }
}

MaterialColor buildMaterialColor(Color color) {
  // method code taken from:
  // https://medium.com/@nickysong/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

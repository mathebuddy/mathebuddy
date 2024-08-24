/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:mathebuddy/math-runtime/src/parse.dart';
import 'package:platform_detector/platform_detector.dart';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/widget_load.dart';
import 'package:mathebuddy/color.dart';

var showDebugReleaseSwitch = true;
var debugMode = true;
var language = 'de'; // 'en';

BuildContext? levelBuildContext;

var selectedCourseIdFromBundle = "";
Map<String, MbclCourse> courses = {};
var bundleName = 'assets/bundle-debug.json';
var websiteDevMode = false;

void main() {
  if (html.window.location.href.contains("mathebuddy.github.io/alpha/") ||
      isMobile()) {
    bundleName = 'assets/bundle-alpha.json';
    language = 'de';
    showDebugReleaseSwitch = false;
    debugMode = false;
  }
  if (html.window.location.href.contains("mathebuddy.github.io/mathebuddy/") ||
      html.window.location.href.contains("http://localhost:8314/")) {
    websiteDevMode = true;
    bundleName = 'assets/bundle-websim.json';
  } else if (html.window.location.href
      .contains("mathebuddy.github.io/smoke/")) {
    bundleName = 'assets/bundle-smoke.json';
    language = 'de';
    debugMode = false;
  }
  runApp(MaterialApp(
      title: 'MatheBuddy',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.black, textTheme: ButtonTextTheme.primary)),
      // theme: ThemeData(
      //     buttonTheme: ButtonThemeData(
      //         buttonColor: Colors.black, textTheme: ButtonTextTheme.primary),
      //     primarySwatch: buildMaterialColor(Color(0xFFFFFFFF)),
      //     bottomSheetTheme: BottomSheetThemeData(
      //         backgroundColor: Colors.black.withOpacity(0.0))),
      home: LoadWidget(),
      debugShowCheckedModeBanner: false));
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/home.dart';

var showDebugReleaseSwitch = true;
var debugMode = true;
var language = 'en';

var selectedCourseIdFromBundle = "";
Map<String, MbclCourse> courses = {};
var bundleName = 'assets/bundle-debug.json';
var websiteDevMode = false;

void main() {
  if (html.window.location.href.contains("mathebuddy.github.io/alpha/") ||
      html.window.location.href.contains("mathebuddy.github.io/bochum/")) {
    showDebugReleaseSwitch = false;
    debugMode = false;
  }
  if (html.window.location.href.contains("mathebuddy.github.io/mathebuddy/") ||
      html.window.location.href.contains("http://localhost:8314/")) {
    websiteDevMode = true;
    bundleName = 'assets/bundle-websim.json';
  } else if (html.window.location.href
      .contains("mathebuddy.github.io/alpha/")) {
    bundleName = 'assets/bundle-alpha.json';
    language = 'de';
  } else if (html.window.location.href
      .contains("mathebuddy.github.io/smoke/")) {
    bundleName = 'assets/bundle-smoke.json';
    language = 'de';
  } else if (html.window.location.href
      .contains("mathebuddy.github.io/bochum/")) {
    bundleName = 'assets/bundle-bochum.json';
    language = 'de';
  }
  runApp(MaterialApp(
      title: 'mathe:buddy',
      theme: ThemeData(
        primarySwatch: buildMaterialColor(Color(0xFFFFFFFF)),
      ),
      home: const HomeWidget(),
      debugShowCheckedModeBanner: false));
}

void loadCourseBundle(BuildContext context, State state) async {
  var bundleDataStr =
      await DefaultAssetBundle.of(context).loadString(bundleName, cache: false);
  var bundleDataJson = jsonDecode(bundleDataStr);
  courses = {};
  if (bundleName.contains('bundle-debug.json') ||
      bundleName.contains('bundle-websim.json')) {
    courses['DEBUG'] = MbclCourse();
  }
  bundleDataJson.forEach((key, value) {
    if (key != '__type') {
      var course = MbclCourse();
      course.fromJSON(value);
      courses[key] = course;
    }
  });
  print('list of courses: ${courses.keys}');
  // ignore: invalid_use_of_protected_member
  state.setState(() {});
}

bool loadDebugCourse() {
  if (html.document.getElementById('course-data-span') != null &&
      ((html.document.getElementById('course-data-span') as html.SpanElement)
              .innerHtml as String)
          .isNotEmpty) {
    var courseDataStr =
        html.document.getElementById('course-data-span')?.innerHtml as String;
    courseDataStr = courseDataStr.replaceAll('&lt;', '<');
    courseDataStr = courseDataStr.replaceAll('&gt;', '>');
    courseDataStr = courseDataStr.replaceAll('&quot;', '"');
    courseDataStr = courseDataStr.replaceAll('&#039;', '\'');
    courseDataStr = courseDataStr.replaceAll('&amp;', '&');
    var course = MbclCourse();
    course.fromJSON(jsonDecode(courseDataStr));
    courses['DEBUG'] = course;
    return true;
  }
  return false;
}

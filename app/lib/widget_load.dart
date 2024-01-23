/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the debug menu widget that contains the list of
/// courses.

import 'dart:convert';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/widget_debug_menu.dart';
import 'package:universal_html/html.dart' as html;

import 'package:mathebuddy/io.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/style.dart';
import 'package:flutter/material.dart';

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/widget_course.dart';

//late Persistence persistence;

class LoadWidget extends StatefulWidget {
  const LoadWidget({super.key});

  @override
  State<LoadWidget> createState() => LoadState();
}

class LoadState extends State<LoadWidget> {
  MbclCourse? course;
  AppPersistence persistence = AppPersistence();

  LoadState();

  @override
  void initState() {
    super.initState();
    loadCourseBundle(context, this);
  }

  @override
  Widget build(BuildContext context) {
    refreshStyle();

    if (courses.keys.isNotEmpty) {
      if (courses.keys.length == 1 &&
          courses[courses.keys.first]!.debug == MbclCourseDebug.no) {
        // if the bundle contains exactly one course, then directly switch to it.
        selectedCourseIdFromBundle = courses.keys.first;
        course = courses[courses.keys.first]!;
        course!.persistence = persistence;
        Future.microtask(() => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CourseWidget(course!))));
      } else {
        // otherwise, show the debug menu
        Future.microtask(() => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DebugMenuWidget())));
      }
    }

    return Scaffold(
      appBar: buildAppBar(false, false, this, context, null),
      body: Text(''),
      backgroundColor: Colors.white,
    );
  }
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

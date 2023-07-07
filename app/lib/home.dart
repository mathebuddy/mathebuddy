/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the home screen widget that contains the list of
/// courses.

import 'dart:convert';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:mathebuddy/chapter.dart';
import 'package:mathebuddy/level.dart';

import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/unit.dart';

import 'main.dart';
import 'appbar.dart';
import 'course.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> {
  Map<String, MbclCourse> courses = {};
  var bundleName = 'assets/bundle-complex.json'; // TODO

  HomeState() {
    if (html.window.location.href
        .contains("mathebuddy.github.io/mathebuddy/")) {
      bundleName = 'assets/bundle-test.json';
    }
  }

  @override
  void initState() {
    super.initState();
    loadCourseBundle();
  }

  @override
  Widget build(BuildContext context) {
    // create course list
    List<TableRow> tableRows = [];
    for (var courseKey in courses.keys) {
      tableRows.add(TableRow(children: [
        TableCell(
            child: GestureDetector(
                onTap: () {
                  // open course (or first chapter/unit/level in case
                  // there is only one chapter/unit/level)
                  var route = MaterialPageRoute(builder: (context) {
                    var course = courses[courseKey]!;
                    if (course.chapters.length == 1) {
                      var chapter = course.chapters[0];
                      if (chapter.units.length == 1) {
                        var unit = chapter.units[0];
                        if (unit.levels.length == 1) {
                          var level = unit.levels[0];
                          return LevelWidget(level);
                        } else {
                          return UnitWidget(unit);
                        }
                      } else {
                        return ChapterWidget(chapter);
                      }
                    } else {
                      return CourseWidget(course);
                    }
                  });
                  Navigator.push(context, route)
                      .then((value) => setState(() {}));
                },
                child: Container(
                    margin: EdgeInsets.all(2.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                        color: courseKey == 'DEBUG'
                            ? Color.fromARGB(255, 255, 210, 210)
                            : Colors.white,
                        border: Border.all(
                            width: 2.0, color: Color.fromARGB(255, 81, 81, 81)),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Center(child: Text(courseKey))))),
      ]));
      if (debugMode == false) {
        // TODO
        break;
      }
    }
    var listOfCourses = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );
    var logo = Column(children: [Image.asset('assets/img/logo-large-en.png')]);
    var contents = Column(children: [logo, listOfCourses]);
    var body =
        SingleChildScrollView(padding: EdgeInsets.all(5), child: contents);
    return Scaffold(
      appBar: buildAppBar(this, false),
      body: body,
      backgroundColor: Colors.white,
    );
  }

  void loadCourseBundle() async {
    var bundleDataStr = await DefaultAssetBundle.of(context)
        .loadString(bundleName, cache: false);
    var bundleDataJson = jsonDecode(bundleDataStr);
    courses = {};
    if (bundleName.contains('bundle-test.json')) {
      var course = tryToLoadDebugCourse();
      if (course != null) {
        courses['DEBUG'] = course;
      } else {
        var course = MbclCourse();
        courses['DEBUG'] = course;
        var chapter = MbclChapter();
        chapter.title = "DEBUG-COURSE ONLY AVAILABLE...";
        course.chapters.add(chapter);
        chapter = MbclChapter();
        chapter.title = "...ON MATHE:BUDDY WEBSITE";
        course.chapters.add(chapter);
      }
    }
    bundleDataJson.forEach((key, value) {
      if (key != '__type') {
        var course = MbclCourse();
        course.fromJSON(value);
        courses[key] = course;
      }
    });
    //print('list of courses: ${courses.keys}');
    setState(() {});
  }

  MbclCourse? tryToLoadDebugCourse() {
    if (html.document.getElementById('course-data-span') == null) {
      print('!!!!!!!!!!!!!!!!!!! SPAN IS >NOT< AVAILABLE !!!!!');
    } else {
      print('!!!!!!!!!!!!!!!!!!! SPAN AVAILABLE');
      print(((html.document.getElementById('course-data-span')
              as html.SpanElement)
          .innerHtml as String));
    }

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
      return course;
    }
    return null;
  }
}

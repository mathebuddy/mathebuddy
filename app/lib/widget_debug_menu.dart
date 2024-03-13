/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the debug menu widget that contains the list of
/// courses.

import 'package:mathebuddy/event.dart';
import 'package:mathebuddy/io.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';
import 'package:flutter/material.dart';
import 'package:mathebuddy/widget_chapter.dart';
import 'package:mathebuddy/widget_event.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:mathebuddy/widget_load.dart';

import 'package:mathebuddy/widget_unit.dart';

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/widget_course.dart';

class DebugMenuWidget extends StatefulWidget {
  const DebugMenuWidget({super.key});

  @override
  State<DebugMenuWidget> createState() => DebugMenuState();
}

class DebugMenuState extends State<DebugMenuWidget> {
  MbclCourse? course;
  AppPersistence persistence = AppPersistence();

  DebugMenuState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshStyle();
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
                    if (courseKey == 'DEBUG') {
                      loadDebugCourse();
                    }
                    course = courses[courseKey]!;
                    course!.persistence = persistence;
                    selectedCourseIdFromBundle = courseKey;
                    if (course!.chapters.length == 1) {
                      var chapter = course!.chapters[0];
                      if (chapter.units.length == 1) {
                        var unit = chapter.units[0];
                        if (unit.levels.length == 1) {
                          var level = unit.levels[0];
                          if (level.isEvent) {
                            return EventWidget(
                                course!, level, EventData(level));
                          } else {
                            return LevelWidget(course!, chapter, unit, level);
                          }
                        } else {
                          return UnitWidget(course!, chapter, unit);
                        }
                      } else {
                        return ChapterWidget(course!, chapter);
                      }
                    } else {
                      return CourseWidget(course!);
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
    }
    var listOfCourses = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );
    var logoImg = Image.asset('assets/img/logo-large-$language.png');
    var logo = Column(children: [logoImg]);

    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text("Debug Menu",
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));

    var contents = Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: maxContentsWidth),
            child: Column(children: [logo, title, listOfCourses])));
    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: contents);
    return Scaffold(
      appBar: buildAppBar(true, false, this, context, null),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

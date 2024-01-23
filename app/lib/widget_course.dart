/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the course widget that contains the list of chapters.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/widget_awards.dart';
import 'package:mathebuddy/widget_chat.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/widget_chapter.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_help.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:mathebuddy/widget_progress.dart';
import 'package:mathebuddy/widget_unit.dart';

class CourseWidget extends StatefulWidget {
  final MbclCourse course;

  const CourseWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<CourseWidget> createState() {
    return CourseState();
  }
}

class CourseState extends State<CourseWidget> {
  @override
  void initState() {
    super.initState();
    widget.course.loadUserData().then((value) {
      setState(() {});
    }); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    //widget.course.calcProgress();

    // // author
    // Widget author = Padding(
    //     padding: EdgeInsets.only(top: 8.0, left: 10, right: 10, bottom: 0),
    //     child: Text(widget.course.author,
    //         style: TextStyle(
    //             color: getStyle().courseAuthorFontColor,
    //             fontSize: getStyle().courseAuthorFontSize,
    //             fontWeight: getStyle().courseAuthorFontWeight)));
    // // title
    // Widget title = Padding(
    //     padding: EdgeInsets.only(top: 0.0, left: 10, right: 10, bottom: 0),
    //     child: Center(
    //         child: Text(widget.course.title,
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //                 color: getStyle().courseTitleFontColor,
    //                 fontSize: getStyle().courseTitleFontSize,
    //                 fontWeight: getStyle().courseTitleFontWeight))));
    // // chapters
    // Widget titleChapters = Padding(
    //     padding: EdgeInsets.only(top: 0.0, left: 10, right: 10, bottom: 0),
    //     child: Center(
    //         child: Text(language == "en" ? "Chapters" : "Kapitel",
    //             style: TextStyle(
    //               color: getStyle().courseSubTitleFontColor,
    //               fontSize: getStyle().courseSubTitleFontSize,
    //               fontWeight: getStyle().courseSubTitleFontWeight,
    //             ))));
    List<TableRow> tableRows = [];
    List<TableCell> tableCells = [];

    for (var i = 0; i < widget.course.chapters.length; i++) {
      var chapter = widget.course.chapters[i];
      var color = Style().matheBuddyRed;
      var cellColor = Colors.white;
      if (chapter.progress > 0) {
        color = Style().matheBuddyYellow;
        //cellColor = Colors.black;
      }
      if ((chapter.progress - 1.0).abs() < 1e-6) {
        color = Style().matheBuddyGreen;
      }
      Widget icon = Text("");
      if (chapter.iconData.isNotEmpty) {
        icon = SvgPicture.string(chapter.iconData, color: cellColor);
      }
      icon = SizedBox(height: 75, child: icon);
      Widget content = Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(children: [
            icon,
            Wrap(children: [
              Text(chapter.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: cellColor,
                      fontWeight: FontWeight.w400))
            ])
          ]));
      tableCells.add(TableCell(
        //verticalAlignment: (i % 2) == 1
        //    ? TableCellVerticalAlignment.fill
        //    : TableCellVerticalAlignment.top,
        child: GestureDetector(
            onTap: () {
              var route = MaterialPageRoute(builder: (context) {
                return ChapterWidget(widget.course, chapter);
              });
              Navigator.push(context, route).then((value) {
                setState(() {});
              });
            },
            child: Container(
                height: 150, // TODO: 1 vs 2 rows of text
                margin: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    //color: getStyle().matheBuddyRed,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.9),
                          color.withOpacity(0.95)
                        ]),
                    borderRadius: BorderRadius.circular(7.0)),
                child: Center(child: content))),
      ));
    }
    if ((tableCells.length % 2) != 0) {
      tableCells.add(TableCell(child: Text("")));
    }
    var numRows = (tableCells.length / 2).ceil();
    for (var i = 0; i < numRows; i++) {
      List<TableCell> columns = [];
      for (var j = 0; j < 2; j++) {
        columns.add(tableCells[i * 2 + j]);
      }
      tableRows.add(TableRow(children: columns));
    }
    var chapterTable = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );

    // ----- control shortcuts
    var controlShortcuts = buildShortcutsTable([
      {
        "icon": "play-outline", //
        "color": Style().matheBuddyRed,
        "text-en": "Continue", //
        "text-de": "Weiter", //
        "action": () {
          if (widget.course.lastVisitedChapter != null) {
            var chapter = widget.course.lastVisitedChapter!;
            var route = MaterialPageRoute(builder: (context) {
              return ChapterWidget(widget.course, chapter);
            });
            Navigator.push(context, route).then((value) {
              setState(() {});
            });
            if (chapter.lastVisitedUnit != null) {
              var unit = chapter.lastVisitedUnit!;
              var route = MaterialPageRoute(builder: (context) {
                return UnitWidget(widget.course, chapter, unit);
              });
              Navigator.push(context, route).then((value) {
                setState(() {});
              });
              if (chapter.lastVisitedLevel != null) {
                var level = chapter.lastVisitedLevel!;
                var route = MaterialPageRoute(builder: (context) {
                  return LevelWidget(widget.course, chapter, unit, level);
                });
                Navigator.push(context, route).then((value) {
                  setState(() {});
                });
              }
            }
          }
        },
        "enabled": true,
      },
      {
        "icon": "chat-question-outline", //
        "color": Style().matheBuddyRed,
        "text-en": "Interactive", //
        "text-de": "Interaktiv", //
        "action": () {
          var route = MaterialPageRoute(builder: (context) {
            return ChatWidget(widget.course);
          });
          Navigator.push(context, route).then((value) => setState(() {}));
        },
        "enabled": true,
      },
      {
        "icon": "controller-classic", //
        "color": Style().matheBuddyRed,
        "text-en": "Play", //
        "text-de": "Spielen",
        "action": () {},
        "enabled": false,
      },
    ]);

    // ----- control shortcuts
    var progressShortcuts = buildShortcutsTable([
      {
        "icon": "medal", //
        "color": Style().matheBuddyRed,
        "text-en": "Awards", //
        "text-de": "Awards", //
        "action": () {
          var route = MaterialPageRoute(builder: (context) {
            return AwardsWidget(widget.course);
          });
          Navigator.push(context, route).then((value) {
            setState(() {});
          });
        },
        "enabled": true,
      },
      {
        "icon": "chart-line", //
        "color": Style().matheBuddyRed,
        "text-en": "Progress", //
        "text-de": "Fortschritt", //
        "action": () {
          var route = MaterialPageRoute(builder: (context) {
            return ProgressWidget(widget.course);
          });
          Navigator.push(context, route).then((value) {
            setState(() {});
          });
        },
        "enabled": true,
      },
      {
        "icon": "help-circle-outline", //
        "color": Style().matheBuddyRed,
        "text-en": "Help", //
        "text-de": "Hilfe", //
        "action": () {
          var route = MaterialPageRoute(builder: (context) {
            return HelpWidget(widget.course);
          });
          Navigator.push(context, route).then((value) {
            setState(() {});
          });
        },
        "enabled": true,
      },
    ]);

    // awards
    // Widget titleAwards = Padding(
    //     padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 10),
    //     child: Center(
    //         child: Text("Awards",
    //             style: TextStyle(
    //               color: getStyle().courseSubTitleFontColor,
    //               fontSize: getStyle().courseSubTitleFontSize,
    //               fontWeight: getStyle().courseSubTitleFontWeight,
    //             ))));

    // var gotAward = getStyle().matheBuddyGreen;
    // var goForAward = Colors.grey;
    // var awards = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    //   Container(
    //       decoration: BoxDecoration(
    //           border: Border(bottom: BorderSide(color: gotAward, width: 5))),
    //       child: Icon(
    //         MdiIcons.fromString("medal"),
    //         size: 80,
    //         color: gotAward,
    //       )),
    //   Icon(
    //     MdiIcons.fromString("trophy-award"),
    //     size: 80,
    //     color: goForAward,
    //   ),
    //   Icon(
    //     MdiIcons.fromString("run-fast"),
    //     size: 80,
    //     color: goForAward,
    //   )
    // ]);

    // indicators
    // var text = language == 'en' ? "Progress" : "Fortschritt";
    // Widget titleProgress = Padding(
    //     padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
    //     child: Center(
    //         child: Text(text,
    //             style: TextStyle(
    //               color: getStyle().courseSubTitleFontColor,
    //               fontSize: getStyle().courseSubTitleFontSize,
    //               fontWeight: getStyle().courseSubTitleFontWeight,
    //             ))));
    // List<Color> progressColors = [
    //   getStyle().matheBuddyRed,
    //   getStyle().matheBuddyGreen,
    //   getStyle().matheBuddyYellow
    // ];
    // List<double> progressBarPercentages = [0.66, 1.0, 0.75];
    // List<Widget> progressBars = [];
    // for (var i = 0; i < progressBarPercentages.length; i++) {
    //   progressBars.add(SizedBox(
    //       width: 50,
    //       height: 50,
    //       child: CircularProgressIndicator(
    //           strokeWidth: 15,
    //           value: progressBarPercentages[i],
    //           color: progressColors[i])));
    //   progressBars.add(Container(width: 20));
    // }
    // var progress = Row(
    //     mainAxisAlignment: MainAxisAlignment.center, children: progressBars);

    Widget logo = Opacity(
        opacity: 0.85,
        //child: Image.asset('assets/img/logo-large-$language.png')
        child: Image.asset('assets/img/logo-large-no-text.png'));

    // Widget bottomLogos = Container(
    //     constraints: BoxConstraints(maxWidth: 400),
    //     decoration: BoxDecoration(color: Colors.white),
    //     child: Opacity(
    //         opacity: 0.85,
    //         child: Image.asset('assets/img/logo-institutes.png')));

    // all
    Widget contents = Column(children: [
      logo,
      controlShortcuts,
      progressShortcuts,
      //Container(
      //  height: 0,
      //),
      //Container(
      //  height: 25,
      //),
      //title,
      //author,
      // Container(
      //   height: 20,
      // ),
      //titleChapters,
      // Container(
      //   height: 0,
      // ),
      chapterTable,
      //titleAwards,
      // awards,
      // Container(
      //   height: 10,
      // ),
      // titleProgress,
      // progress,
      // Container(
      //   height: 40,
      // ),
      //logo,
      Opacity(
          opacity: 0.85,
          child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Image.asset('assets/img/logo-institutes.png')))
    ]);

    contents = Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: maxContentsWidth),
            child: contents));

    if (widget.course.error.isNotEmpty) {
      contents = generateErrorWidget(widget.course.error);
    }

    Widget body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: contents);

    return Scaffold(
      appBar: buildAppBar(false, false, this, context, widget.course),
      body: body,
      backgroundColor: Colors.white,
      //bottomSheet: bottomLogos,
    );
  }

  Table buildShortcutsTable(shortCutsData) {
    List<TableCell> shortcutChildren = [];
    for (var data in shortCutsData) {
      var color =
          Colors.white.withOpacity((data["enabled"] as bool) ? 1 : 0.33);
      shortcutChildren.add(TableCell(
          child: GestureDetector(
              onTap: () {
                if (data.containsKey("action")) {
                  (data["action"] as Function)();
                }
              },
              child: Container(
                margin: EdgeInsets.all(2.0),
                padding: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (data["color"] as Color),
                          (data["color"] as Color).withOpacity(0.9)
                        ]),
                    borderRadius: BorderRadius.circular(7.0)),
                child: Column(children: [
                  Icon(
                    MdiIcons.fromString(data["icon"] as String),
                    size: 70,
                    color: color,
                  ),
                  Text(
                    language == "en"
                        ? data["text-en"] as String
                        : data["text-de"] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: color),
                  )
                ]),
              ))));
    }
    return Table(children: [TableRow(children: shortcutChildren)]);
  }
}

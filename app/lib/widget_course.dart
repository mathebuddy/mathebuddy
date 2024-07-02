/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

/// This file implements the course widget that contains the list of chapters.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/event.dart';
import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/unit.dart';
import 'package:mathebuddy/widget_awards.dart';
import 'package:mathebuddy/widget_chat.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/widget_chapter.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_event.dart';
import 'package:mathebuddy/widget_legal.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:mathebuddy/widget_progress.dart';
import 'package:mathebuddy/widget_unit.dart';

class CourseWidget extends StatefulWidget {
  final MbclCourse course;

  const CourseWidget(this.course, {super.key});

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
      for (var chapter in widget.course.chapters) {
        chapter.loadUserData().then((value) {
          setState(() {});
        });
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.course.calcProgress();

    List<TableRow> tableRows = [];
    List<TableCell> tableCells = [];

    for (var i = 0; i < widget.course.chapters.length; i++) {
      var chapter = widget.course.chapters[i];
      Color color = Style().matheBuddyRed;
      var cellColor = Colors.white;
      if (chapter.progress > 0) {
        color = Style().matheBuddyYellow;
      }
      if ((chapter.progress - 1.0).abs() < 1e-6) {
        color = Style().matheBuddyGreen;
      }
      Widget icon = Text("");
      if (chapter.iconData.isNotEmpty) {
        icon = SvgPicture.string(chapter.iconData, color: cellColor);
      }
      icon = SizedBox(height: 55, child: icon);
      var title = chapter.title;
      //title = title.replaceAll(" ", "\n");
      var percentage = " ${(chapter.progress * 100).round()} % ";
      Widget content = Container(
          alignment: Alignment.center,
          child: Padding(
              padding: EdgeInsets.all(5.0),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  percentage,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 221, 211, 211)),
                ),
                Center(child: icon),
                Center(
                    child: Wrap(alignment: WrapAlignment.center, children: [
                  Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: cellColor,
                          fontWeight: FontWeight.w400))
                ]))
              ])));
      tableCells.add(TableCell(
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
                margin: EdgeInsets.all(2.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    //color: getStyle().matheBuddyRed,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.9),
                          color.withOpacity(0.95)
                        ]),
                    borderRadius: BorderRadius.circular(getStyle().tileRadius)),
                child: Center(child: content))),
      ));
    }
    const columnsPerRow = 2;
    while ((tableCells.length % columnsPerRow) != 0) {
      tableCells.add(TableCell(child: Text("")));
    }
    var numRows = (tableCells.length / columnsPerRow).ceil();
    for (var i = 0; i < numRows; i++) {
      List<TableCell> columns = [];
      for (var j = 0; j < columnsPerRow; j++) {
        columns.add(tableCells[i * columnsPerRow + j]);
      }
      tableRows.add(TableRow(children: columns));
    }
    var chapterTable = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
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
        "enabled": widget.course.lastVisitedChapter != null,
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
        "action": () {
          // open event level
          var level = widget.course.suggestGame();
          if (level == null) {
            // TODO: message!!
          } else {
            var route = MaterialPageRoute(builder: (context) {
              return EventWidget(widget.course, level, EventData(level));
            });
            Navigator.push(context, route).then((value) {
              setState(() {});
            });
          }
        },
        "enabled": widget.course.suggestGame() != null,
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
          if (widget.course.help != null) {
            var level = widget.course.help!;
            var route = MaterialPageRoute(builder: (context) {
              var pseudoChapter = MbclChapter(widget.course);
              var pseudoUnit = MbclUnit(widget.course, pseudoChapter);
              return LevelWidget(
                  widget.course, pseudoChapter, pseudoUnit, level);
            });
            Navigator.push(context, route).then((value) {
              setState(() {});
            });
          }
          // var route = MaterialPageRoute(builder: (context) {
          //   return HelpWidget(widget.course);
          // });
          // Navigator.push(context, route).then((value) {
          //   setState(() {});
          // });
        },
        "enabled": true,
      },
    ]);

    Widget logo = Opacity(
        opacity: 0.85, child: Image.asset('assets/img/logo-large-no-text.png'));

    // all
    Widget contents = Column(children: [
      logo,
      controlShortcuts,
      progressShortcuts,
      Container(
        height: 0,
      ),
      chapterTable,
      Container(
        height: 20,
      ),
    ]);

    var bottomColor = Color.fromARGB(35, 230, 230, 230);
    var bottomLogos = GestureDetector(
        onTap: () {
          var route = MaterialPageRoute(builder: (context) {
            return LegalWidget(widget.course);
          });
          Navigator.push(context, route).then((value) {
            setState(() {});
          });
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 1.25,
                        color: getStyle()
                            .appbarBackgroundColor
                            .withOpacity(0.33))),
                color: bottomColor),
            child: Opacity(
                opacity: 0.85,
                child: Container(
                    constraints: BoxConstraints(
                        maxWidth: maxContentsWidth, maxHeight: 80),
                    child: Image.asset('assets/img/logo-institutes.png')))));

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
      appBar: buildAppBar(false, [], false, this, context, widget.course),
      body: Stack(children: [
        Opacity(
            opacity: 0.035,
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/img/background.jpg"),
                        fit: BoxFit.cover)))),
        body
      ]),
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomLogos,
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
                padding: EdgeInsets.only(bottom: 12, top: 7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (data["color"] as Color),
                          (data["color"] as Color).withOpacity(0.9)
                        ]),
                    borderRadius: BorderRadius.circular(getStyle().tileRadius)),
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

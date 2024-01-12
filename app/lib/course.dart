/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the course widget that contains the list of chapters.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/chat.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/chapter.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

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
    //TODO: e.g. widget.course;
  }

  @override
  Widget build(BuildContext context) {
    // logo
    Widget logo = Container(
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
                top: BorderSide(color: getStyle().matheBuddyRed, width: 1.0))),
        child: Image.asset('assets/img/logo-large-$language.png'));
    // author
    Widget author = Padding(
        padding: EdgeInsets.only(top: 8.0, left: 10, right: 10, bottom: 0),
        child: Text(widget.course.author,
            style: TextStyle(
                color: getStyle().courseAuthorFontColor,
                fontSize: getStyle().courseAuthorFontSize,
                fontWeight: getStyle().courseAuthorFontWeight)));
    // title
    Widget title = Padding(
        padding: EdgeInsets.only(top: 5.0, left: 10, right: 10, bottom: 12),
        child: Center(
            child: Text(widget.course.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));

    // chapters
    Widget titleChapters = Padding(
        padding: EdgeInsets.only(top: 5.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text(language == "en" ? "Chapters" : "Kapitel",
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize))));
    List<TableRow> tableRows = [];
    List<TableCell> tableCells = [];
    var cellColor = Colors.white;
    for (var i = 0; i < widget.course.chapters.length; i++) {
      var chapter = widget.course.chapters[i];
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
              Navigator.push(context, route).then((value) => setState(() {}));
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
                          getStyle().matheBuddyRed,
                          getStyle().matheBuddyRed.withOpacity(0.9)
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

    var shortCutColor = Colors.white; // getStyle().matheBuddyRed;
    var shortCutsData = [
      {
        "icon": "play-outline", //
        "text-en": "Continue", //
        "text-de": "Weiter", //
        "action": () {},
        "enabled": false,
      },
      {
        "icon": "chat-question-outline", //
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
        "text-en": "Play", //
        "text-de": "Spielen",
        "action": () {},
        "enabled": false,
      },
    ];
    List<TableCell> shortcutChildren = [];
    for (var data in shortCutsData) {
      var color =
          shortCutColor.withOpacity((data["enabled"] as bool) ? 1 : 0.33);
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
                          getStyle().matheBuddyRed,
                          getStyle().matheBuddyRed.withOpacity(0.9)
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

    var shortcuts = Table(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [TableRow(children: shortcutChildren)]);

    // awards
    Widget titleAwards = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 10),
        child: Center(
            child: Text("Awards",
                style: TextStyle(
                  color: getStyle().courseSubTitleFontColor,
                  fontSize: getStyle().courseSubTitleFontSize,
                  fontWeight: getStyle().courseSubTitleFontWeight,
                ))));

    var gotAward = getStyle().matheBuddyGreen;
    var goForAward = Colors.grey;
    var awards = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: gotAward, width: 5))),
          child: Icon(
            MdiIcons.fromString("medal"),
            size: 80,
            color: gotAward,
          )),
      Icon(
        MdiIcons.fromString("trophy-award"),
        size: 80,
        color: goForAward,
      ),
      Icon(
        MdiIcons.fromString("run-fast"),
        size: 80,
        color: goForAward,
      )
    ]);

    // indicators
    var text = language == 'en' ? "Progress" : "Fortschritt";
    Widget titleProgress = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text(text,
                style: TextStyle(
                  color: getStyle().courseSubTitleFontColor,
                  fontSize: getStyle().courseSubTitleFontSize,
                  fontWeight: getStyle().courseSubTitleFontWeight,
                ))));
    List<Color> progressColors = [
      getStyle().matheBuddyRed,
      getStyle().matheBuddyGreen,
      getStyle().matheBuddyYellow
    ];
    List<double> progressBarPercentages = [0.66, 1.0, 0.75];
    List<Widget> progressBars = [];
    for (var i = 0; i < progressBarPercentages.length; i++) {
      progressBars.add(SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
              strokeWidth: 15,
              value: progressBarPercentages[i],
              color: progressColors[i])));
      progressBars.add(Container(width: 20));
    }
    var progress = Row(
        mainAxisAlignment: MainAxisAlignment.center, children: progressBars);

    // all
    Widget contents = Column(children: [
      Container(
        height: 5,
      ),
      //preTitle,
      author,
      title,
      shortcuts,
      Container(
        height: 1,
      ),
      //titleChapters,
      chapterTable,
      titleAwards,
      awards,
      Container(
        height: 10,
      ),
      titleProgress,
      progress,
      Container(
        height: 40,
      ),
      logo,
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

    // body = Center(
    //     child: Container(
    //         constraints: BoxConstraints(maxWidth: maxContentsWidth),
    //         child: body));

    return Scaffold(
      appBar: buildAppBar(this, null),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

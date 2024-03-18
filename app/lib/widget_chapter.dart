/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the chapter widget that contains the list of units.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';

import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_unit.dart';
import 'package:mathebuddy/error.dart';

class ChapterWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclChapter chapter;

  ChapterWidget(this.course, this.chapter, {Key? key}) : super(key: key) {
    course.saveUserData();
  }

  @override
  State<ChapterWidget> createState() {
    return ChapterState();
  }
}

class ChapterState extends State<ChapterWidget> {
  @override
  void initState() {
    super.initState();
    widget.chapter.loadUserData(); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    // title
    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text(widget.chapter.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));

    // units
    List<TableRow> tableRows = [];
    List<TableCell> tableCells = [];
    var cellColor = Colors.white;
    for (var i = 0; i < widget.chapter.units.length; i++) {
      var unit = widget.chapter.units[i];

      unit.calcProgress();
      var color = Style().matheBuddyRed;
      if (unit.progress > 0) {
        color = Style().matheBuddyYellow;
      }
      if ((unit.progress - 1).abs() < 1e-6) {
        color = Style().matheBuddyGreen;
      }

      var locked = unit.isLocked();
      var lockSize = 28.0;
      var lockedIcon = Icon(Icons.lock,
          size: lockSize, color: Colors.white.withOpacity(0.75));

      Widget icon = Text("");
      if (unit.iconData.isNotEmpty) {
        icon = SvgPicture.string(unit.iconData, color: cellColor);
      }
      icon = SizedBox(height: 75, child: icon);

      var progress = unit.progress;
      var percentage = "${(progress * 100).round()} %";

      Widget content = Opacity(
          opacity: locked ? 0.5 : 1,
          child: Container(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        locked
                            ? Container(
                                alignment: Alignment.topLeft, child: lockedIcon)
                            : Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  textAlign: TextAlign.start,
                                  percentage,
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 221, 211, 211)),
                                )),
                        Center(child: icon),
                        Center(
                            child: Text(unit.title,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: 22,
                                    color: cellColor,
                                    fontWeight: FontWeight.w400)))
                      ]))));

      var cell = TableCell(
        child: GestureDetector(
            onTap: () {
              if (!locked || debugMode) {
                var route = MaterialPageRoute(builder: (context) {
                  return UnitWidget(widget.course, widget.chapter, unit);
                });
                Navigator.push(context, route).then((value) {
                  setState(() {});
                });
              }
            },
            child: Container(
              //height: 200,
              margin: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(8.0)),
              child: content,
            )),
      );
      tableCells.add(cell);
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
    var unitsTable = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      children: tableRows,
    );

    List<Widget> contents = [title, unitsTable];

    if (widget.chapter.error.isNotEmpty) {
      var err = generateErrorWidget(widget.chapter.error);
      contents.insert(0, err);
    }

    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(children: contents))));

    return Scaffold(
      appBar: buildAppBar(true, true, this, context, widget.course),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the chapter widget that contains the list of units.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // logo
    Widget logo = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 50),
        child: Image.asset('assets/img/logo.png'));

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
      Widget icon = Text("");
      if (unit.iconData.isNotEmpty) {
        icon = SvgPicture.string(unit.iconData, color: cellColor);
      }
      icon = SizedBox(height: 75, child: icon);
      Widget content = Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(children: [
            icon,
            //Wrap(children: [
            Text(unit.title,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    fontSize: 22,
                    color: cellColor,
                    fontWeight: FontWeight.w400))
          ]));
      // TODO!! use Table(defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicXX)
      //  in flutter 3.18+
      var fill = unit.title == "Integral-Lösungsansätze";
      var cell = TableCell(
        //verticalAlignment: TableCellVerticalAlignment.fill,
        //verticalAlignment: TableCellVerticalAlignment.middle,
        verticalAlignment: fill
            ? TableCellVerticalAlignment.fill
            : TableCellVerticalAlignment.top,
        child: GestureDetector(
            onTap: () {
              var route = MaterialPageRoute(builder: (context) {
                return UnitWidget(widget.course, widget.chapter, unit);
              });
              Navigator.push(context, route).then((value) {
                setState(() {});
              });
            },
            child: Container(
              alignment: Alignment.center,
              //height: 200,
              margin: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: getStyle()
                      .matheBuddyRed //courseColors[i % getStyle().courseColors.length]
                  //.withOpacity(0.95)
                  ,
                  borderRadius: BorderRadius.circular(8.0)),
              child: content,
            )),
      );
      tableCells.add(cell);
    }
    if ((tableCells.length % 2) != 0) {
      tableCells.add(TableCell(child: Text("")));
    }

    // var heights = [];
    // for(var cell in tableCells) {
    //   heights.add(cell.)
    // }

    var numRows = (tableCells.length / 2).ceil();
    for (var i = 0; i < numRows; i++) {
      List<TableCell> columns = [];
      for (var j = 0; j < 2; j++) {
        columns.add(tableCells[i * 2 + j]);
      }
      tableRows.add(TableRow(children: columns));
    }
    var unitsTable = Table(
      //defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      children: tableRows,
    );

    List<Widget> contents = [
      //logo,
      title, unitsTable
    ];

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
      appBar: buildAppBar(this, widget.chapter, null),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

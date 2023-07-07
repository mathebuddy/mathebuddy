/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the course widget that contains the list of chapters.

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/course.dart';

import 'appbar.dart';
import 'chapter.dart';

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
    List<TableRow> tableRows = [];
    for (var chapter in widget.course.chapters) {
      tableRows.add(TableRow(children: [
        TableCell(
          child: GestureDetector(
              onTap: () {
                var route = MaterialPageRoute(builder: (context) {
                  return ChapterWidget(chapter);
                });
                Navigator.push(context, route).then((value) => setState(() {}));
              },
              child: Container(
                  margin: EdgeInsets.all(2.0),
                  height: 40.0,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2.0, color: Color.fromARGB(255, 81, 81, 81)),
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Center(child: Text(chapter.title)))),
        )
      ]));
    }

    var unitsTable = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );

    var contents = Column(children: [unitsTable]);

    var body =
        SingleChildScrollView(padding: EdgeInsets.all(5), child: contents);
    return Scaffold(
      appBar: buildAppBar(this, false),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

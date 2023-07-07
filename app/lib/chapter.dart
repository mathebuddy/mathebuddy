/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the chapter widget that contains the list of units.

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';

import 'appbar.dart';
import 'unit.dart';

class ChapterWidget extends StatefulWidget {
  final MbclChapter chapter;

  const ChapterWidget(this.chapter, {Key? key}) : super(key: key);

  @override
  State<ChapterWidget> createState() {
    return ChapterState();
  }
}

class ChapterState extends State<ChapterWidget> {
  @override
  void initState() {
    super.initState();
    //TODO: e.g. widget.course;
  }

  @override
  Widget build(BuildContext context) {
    List<TableRow> tableRows = [];
    for (var unit in widget.chapter.units) {
      tableRows.add(TableRow(children: [
        TableCell(
          child: GestureDetector(
              onTap: () {
                var route = MaterialPageRoute(builder: (context) {
                  return UnitWidget(unit);
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
                  child: Center(child: Text(unit.title)))),
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

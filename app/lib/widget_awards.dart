/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the awards widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/award.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

class AwardsWidget extends StatefulWidget {
  final MbclCourse course;

  const AwardsWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<AwardsWidget> createState() {
    return AwardsState();
  }
}

class AwardsState extends State<AwardsWidget> {
  @override
  void initState() {
    super.initState();
    widget.course.loadUserData(); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text("Awards",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));

    List<MbclAward> testAwards = [];
    testAwards.add(
        MbclAward("3-days-in-row", "Trained 3 days in a row", DateTime.now()));
    testAwards.add(MbclAward("5-days-in-row", "Trained 5 days in a row", null));
    testAwards
        .add(MbclAward("10-days-in-row", "Trained 10 days in a row", null));

    List<TableRow> awardWidgets = [];
    for (var award in testAwards) {
      String dateStr = award.dateTime != null
          ? award.dateTime!.toLocal().toString()
          : "go fot it!";

      var dateEarned = Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            dateStr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ));

      Color backgroundColor = award.dateTime != null
          ? Style().matheBuddyGreen
          : const Color.fromARGB(255, 59, 59, 59);
      awardWidgets.add(TableRow(children: [
        TableCell(
            child: GestureDetector(
                onTap: () {},
                child: Container(
                    margin: EdgeInsets.all(2.0),
                    padding: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              backgroundColor,
                              backgroundColor.withOpacity(0.9)
                            ]),
                        borderRadius: BorderRadius.circular(7.0)),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Column(children: [
                        Text(
                          award.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        dateEarned
                      ]),
                    ))))
      ]));
    }
    var table = Table(children: awardWidgets);

    List<Widget> contents = [title, table];

    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(children: contents))));

    return Scaffold(
        appBar: buildAppBar(this, null, null),
        body: body,
        backgroundColor: Colors.white);
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the progress widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

class ProgressWidget extends StatefulWidget {
  final MbclCourse course;

  const ProgressWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<ProgressWidget> createState() {
    return ProgressState();
  }
}

class ProgressState extends State<ProgressWidget> {
  @override
  void initState() {
    super.initState();
    widget.course.loadUserData(); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [];

    contents.add(Text("WORK-IN-PROGRESS :-)",
        style: TextStyle(color: Colors.red, fontSize: 25)));

    // page title
    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text(language == "en" ? "Progress" : "Fortschritt",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));
    contents.add(title);

    // chapter progress
    for (var chapter in widget.course.chapters) {
      // chapter title
      var label = language == "en" ? "Chapter" : "Kapitel";
      Widget chapterTitleLabel = Padding(
          padding: EdgeInsets.all(0.0),
          child: Text(label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              )));
      contents.add(Center(child: chapterTitleLabel));
      Widget chapterTitle = Padding(
          padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
          child: Text(chapter.title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold)));
      contents.add(Center(child: chapterTitle));
      contents.add(Text(" "));

      // chapter stats
      List<Color> progressColors = [
        getStyle().matheBuddyRed,
        getStyle().matheBuddyGreen,
        getStyle().matheBuddyYellow
      ];
      List<double> progressBarPercentages = [0.88, 0.55, 0.44]; // TODO
      List<String> progressBarLabels = ["Text", "Übungen", "Spiele"];
      if (language == "en") {
        progressBarLabels = ["Text", "Training", "Games"];
      }
      List<Widget> progressBars = [];
      for (var i = 0; i < progressBarPercentages.length; i++) {
        var percentage = (100.0 * progressBarPercentages[i]).round();
        var percentageText = "$percentage%";
        progressBars.add(Column(children: [
          Stack(children: [
            SizedBox(
                width: 50,
                height: 50,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      percentageText,
                      style:
                          TextStyle(fontSize: 10.0, color: progressColors[i]),
                    ))),
            SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                    strokeWidth: 15,
                    value: progressBarPercentages[i],
                    color: progressColors[i]))
          ]),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                progressBarLabels[i],
                style: TextStyle(fontSize: 14),
              ))
        ]));
        progressBars.add(Container(width: 20));
      }
      contents.add(Row(
          mainAxisAlignment: MainAxisAlignment.center, children: progressBars));

      contents.add(Text(" "));
      contents.add(Text(" "));
      // TODO: add link "go to chapter"
    }

    // page body
    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: Center(
            child: Container(
                alignment: Alignment.topCenter,
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: contents))));

    return Scaffold(
        appBar: buildAppBar(true, true, this, context, widget.course),
        body: body,
        backgroundColor: Colors.white);
  }
}

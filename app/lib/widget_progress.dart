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

    //contents.add(Text("WORK-IN-PROGRESS :-)",
    //    style: TextStyle(color: Colors.red, fontSize: 25)));

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
      List<Widget> boxChildren = [];

      // chapter title
      var label = language == "en" ? "Chapter" : "Kapitel";
      Widget chapterTitleLabel = Padding(
          padding: EdgeInsets.all(0.0),
          child: Text(label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              )));
      boxChildren.add(Center(child: chapterTitleLabel));
      Widget chapterTitle = Padding(
          padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
          child: Text(chapter.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold)));
      boxChildren.add(Center(child: chapterTitle));
      boxChildren.add(Text(" "));

      // chapter stats
      var progressText = chapter.getVisitedLevelPercentage();
      var progressExercises = chapter.progress;
      var progressGames = 0.0; // TODO

      List<Color> progressColors = [
        getStyle().matheBuddyRed,
        getStyle().matheBuddyGreen,
        getStyle().matheBuddyYellow
      ];
      List<double> progressBarPercentages = [
        progressText,
        progressExercises,
        progressGames,
      ]; // TODO
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
                style: TextStyle(fontSize: 14, color: Colors.white),
              ))
        ]));
        progressBars.add(Container(width: 20));
      }
      boxChildren.add(Row(
          mainAxisAlignment: MainAxisAlignment.center, children: progressBars));

      var box = Container(
          width: double.infinity,
          decoration: BoxDecoration(
              //color: Colors.black.withOpacity(0.85),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.85)
                  ]),
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: boxChildren)));
      contents.add(box);

      contents.add(
        Container(
          height: 5,
        ),
      );
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

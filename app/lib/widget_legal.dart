/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the legal info widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

class LegalWidget extends StatefulWidget {
  final MbclCourse? course;

  const LegalWidget.LegalWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<LegalWidget> createState() {
    return LegalState();
  }
}

class LegalState extends State<LegalWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [];

    // page title
    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text(language == "en" ? "Legal Notice" : "Impressum",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));
    contents.add(title);

    List<String> english = [
      "The learning application mathe:buddy is an interactive and gamified app for higher mathematics in the first year of study. Students are motivated through interactive training and elements of game-based learning, motivating, guiding, and individually supported.",
      "We provide this app as-is and do not take responsibility for any damage.",
      "Funded by Stiftung Innovation in der Hochschullehre; FREIRAUM 2022."
    ];

    List<String> german = [
      "Die Lernapplikation mathe:buddy ist eine interaktive und gamifizierte App für die höhere Mathematik im ersten Studienjahr. Studierende werden durch interaktives Training und Elemente des spielerischen Lernens motiviert, angeleitet und individuell gefördert.",
      "Wir stellen diese App ohne Gewähr zur Verfügung und übernehmen keine Verantwortung für eventuelle Schäden.",
      "Gefördert durch die Stiftung Innovation in der Hochschullehre; FREIRAUM 2022."
    ];

    // text
    var src = language == "de" ? german : english;
    for (var e in src) {
      Widget text = Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            e,
            style: TextStyle(fontSize: 18),
          ));
      contents.add(text);
    }

    // link to privacy polity
    contents.add(Container(
      height: 40,
    ));
    contents.add(Center(
        child: Text("https://mathebuddy.github.io/mathebuddy/privacy.html")));

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
        appBar: buildAppBar(true, [], true, this, context, widget.course),
        body: body,
        backgroundColor: Colors.white);
  }
}

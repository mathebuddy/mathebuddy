/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the awards widget.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/audio.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/award.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
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
    // var constructionSite = Text("WORK-IN-PROGRESS :-)",
    //     style: TextStyle(color: Colors.red, fontSize: 25));

    Widget resetAwardsBtn = Text("");
    if (debugMode) {
      resetAwardsBtn = GestureDetector(
          onTap: () {
            widget.course.awards.removeAllAwards();
            setState(() {});
          },
          child: Opacity(
              opacity: 0.8,
              child: Padding(
                  padding: EdgeInsets.only(right: 4, top: 20),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(" REMOVE ALL AWARDS ",
                              style: TextStyle(color: Colors.white)))))));
    }

    Widget title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
        child: Center(
            child: Text("Awards",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: getStyle().courseTitleFontColor,
                    fontSize: getStyle().courseTitleFontSize,
                    fontWeight: getStyle().courseTitleFontWeight))));

    Map<String, int> awardList = widget.course.awards.awards;
    // TODO: sort

    List<TableRow> awardWidgets = [];
    for (var entry in awardList.entries) {
      String awardId = entry.key;
      bool received = entry.value != 0;
      String dateStr = "go for it";
      if (received) {
        dateStr = DateTime.fromMillisecondsSinceEpoch(entry.value)
            .toLocal()
            .toString()
            .split(".")[0];
      }
      var dateEarned = Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            dateStr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ));

      Color backgroundColor = received
          ? Style().matheBuddyGreen
          : const Color.fromARGB(255, 39, 39, 39);
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
                        Icon(MdiIcons.fromString("medal"),
                            size: 70, color: Colors.white),
                        Text(
                          widget.course.awards.getText(awardId, language),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        dateEarned
                      ]),
                    ))))
      ]));
    }
    var table = Table(children: awardWidgets);

    List<Widget> contents = [
      /*constructionSite, */ title,
      resetAwardsBtn,
      table
    ];

    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        padding: EdgeInsets.all(5),
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(children: contents))));

    return Scaffold(
        appBar: buildAppBar(true, [], true, this, context, widget.course),
        body: body,
        backgroundColor: Colors.white);
  }
}

void renderGotAwardOverlay(
    MbclCourse course, State state, BuildContext buildContext,
    {textOpacity = 0.95, backgroundOpacity = 0.95}) {
  MbclAwardType? type = course.awards.popNotShownAward();
  if (type == null) {
    return;
  }
  if (!course.muteAudio) {
    appAudio.play(AppAudioId.passedExercise);
  }
  // show visual feedback as overlay
  //if (debugMode == false) {
  var overlayEntry = OverlayEntry(builder: (context) {
    var color = Style().matheBuddyGreen;
    var text = MbclAwards().getText(type.name, language);
    return Container(
        alignment: Alignment.center,
        width: 200,
        height: 200,
        child: Opacity(
            opacity: textOpacity,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(backgroundOpacity)),
                child: DefaultTextStyle(
                    style: TextStyle(fontSize: 64, color: color),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.fromString("medal"),
                          size: 120,
                          color: color,
                        ),
                        Center(
                            child: Text(
                          text,
                        ))
                      ],
                    )))));
  });
  Overlay.of(buildContext).insert(overlayEntry);
  // ignore: invalid_use_of_protected_member
  state.setState(() {});
  Future.delayed(const Duration(milliseconds: 1000), () {
    overlayEntry.remove();
    // ignore: invalid_use_of_protected_member
    //state.setState(() {});
  });
  //}
}

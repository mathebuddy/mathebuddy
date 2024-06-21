/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the settings widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

class SettingsWidget extends StatefulWidget {
  final MbclCourse? course;

  const SettingsWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<SettingsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [];

    if (widget.course == null) {
      contents.add(Text("!!! SETTINGS ARE ONLY AVAILABLE IN COURSE MODE !!!",
          style: TextStyle(color: Colors.red, fontSize: 25)));
    } else {
      // page title
      Widget title = Padding(
          padding: EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
          child: Center(
              child: Text(language == "en" ? "Settings" : "Einstellungen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: getStyle().courseTitleFontColor,
                      fontSize: getStyle().courseTitleFontSize,
                      fontWeight: getStyle().courseTitleFontWeight))));
      contents.add(title);

      // ----- misc -----
      List<Widget> boxChildren = [];

      // title
      // var label = language == "en" ? "Misc" : "Verschiedenes";
      // Widget chapterTitle = Padding(
      //     padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
      //     child: Text(label,
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 24.0,
      //             fontWeight: FontWeight.bold)));
      // boxChildren.add(Center(child: chapterTitle));

      var checkboxUnlockAll = CheckboxListTile(
          checkColor:
              widget.course!.unlockAll == false ? Colors.white : Colors.black,
          activeColor: Colors.white,
          hoverColor: Colors.grey,
          title: Text(
            language == "en"
                ? "Unlock all levels (this setting is NOT recommended from a didactic point of view)"
                : "Alle Level freischalten (diese Einstellung wird aus didaktischer Sicht NICHT empfohlen)",
            style: TextStyle(color: Colors.white),
          ),
          value: widget.course!.unlockAll,
          onChanged: (newValue) {
            widget.course!.unlockAll = !widget.course!.unlockAll;
            setState(() {});
          },
          controlAffinity: ListTileControlAffinity.leading);
      boxChildren.add(checkboxUnlockAll);
      var checkboxMuteAudio = CheckboxListTile(
          checkColor:
              widget.course!.muteAudio == false ? Colors.white : Colors.black,
          activeColor: Colors.white,
          hoverColor: Colors.grey,
          title: Text(
            language == "en"
                ? "Mute audio feedback"
                : "Audio Feedback abschalten",
            style: TextStyle(color: Colors.white),
          ),
          value: widget.course!.muteAudio,
          onChanged: (newValue) {
            widget.course!.muteAudio = !widget.course!.muteAudio;
            setState(() {});
          },
          controlAffinity: ListTileControlAffinity.leading);
      boxChildren.add(checkboxMuteAudio);

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
        appBar: buildAppBar(true, [], true, this, context, widget.course,
            hideSettings: true),
        body: body,
        backgroundColor: Colors.white);
  }
}

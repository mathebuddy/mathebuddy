/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the level widget.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';

import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/unit.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/level_item.dart';
import 'package:mathebuddy/widget_load.dart';

class LevelWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclChapter chapter;
  final MbclUnit? unit;
  final MbclLevel level;

  LevelWidget(this.course, this.chapter, this.unit, this.level, {Key? key})
      : super(key: key) {
    course.lastVisitedChapter = chapter;
    chapter.lastVisitedUnit = unit;
    chapter.lastVisitedLevel = level;
    course.saveUserData();
  }

  @override
  State<LevelWidget> createState() => LevelState();
}

class LevelState extends State<LevelWidget> {
  GlobalKey? levelTitleKey;

  @override
  void initState() {
    widget.level.currentPart = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    levelBuildContext = context;
    List<Widget> page = [];
    var level = widget.level;
    level.calcProgress();

    // debug: show level path
    if (debugMode && level.fileId.isNotEmpty) {
      var path = "${widget.chapter.fileId}/${level.fileId}.mbl";
      page.add(generateLevelPath(path));
    }

    // list errors
    if (widget.level.error.isNotEmpty) {
      page.add(generateErrorWidget(widget.level.error));
    }

    // title
    levelTitleKey = GlobalKey();
    var levelTitle = Column(children: [
      Container(
          key: levelTitleKey,
          margin: EdgeInsets.only(top: 20.0),
          child: Center(
            child: Text(
              level.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: getStyle().levelTitleFontSize,
                  color: getStyle().levelTitleColor,
                  fontWeight: getStyle().levelTitleFontWeight),
            ),
          ))
    ]);
    page.add(levelTitle);

    // debug: level reload button
    if (debugMode && level.isDebugLevel == false) {
      page.add(Text(" "));
      page.add(Center(
          child: Opacity(
              opacity: 0.8,
              child: GestureDetector(
                  onTap: (() {
                    var chapterIdx =
                        widget.course.chapters.indexOf(widget.chapter);
                    var levelIdx = widget.chapter.levels.indexOf(widget.level);
                    loadDebugCourse();
                    widget.level.fromJSON(courses[selectedCourseIdFromBundle]!
                        .chapters[chapterIdx]
                        .levels[levelIdx]
                        .toJSON());
                    setState(() {});
                  }),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 4, bottom: 4),
                          child: Text("reload level",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18))))))));
      page.add(Text(" "));
      page.add(Center(
          child: Opacity(
              opacity: 0.8,
              child: GestureDetector(
                  onTap: (() {
                    for (var item in widget.level.items) {
                      if (item.type == MbclLevelItemType.exercise) {
                        item.exerciseData!.feedback =
                            MbclExerciseFeedback.correct;
                      }
                    }
                    setState(() {});
                  }),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 4, bottom: 4),
                          child: Text("set all exercises correct",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18))))))));
    }

    // level items
    var part = -1;
    for (var item in level.items) {
      if (item.type == MbclLevelItemType.part) {
        part++;
        if (debugMode) {
          page.add(Text(" "));
          page.add(Icon(MdiIcons.fromString(level.partIconIDs[part])));
        }
      } else {
        // skip items that do not belong to current part
        if (!debugMode) {
          if (level.numParts > 0 && part != level.currentPart) {
            continue;
          }
        }
        // skip exercises that contain unfulfilled requirements
        var skip = false;
        if (!debugMode && item.type == MbclLevelItemType.exercise) {
          var data = item.exerciseData!;
          for (var reqEx in data.requiredExercises) {
            var reqExData = reqEx.exerciseData!;
            if (reqExData.feedback != MbclExerciseFeedback.correct) {
              skip = true;
              break;
            }
          }
        }
        if (skip) {
          continue;
        }
        // generate item and add it to level
        page.add(generateLevelItem(this, level, item));
      }
    }

    // add empty lines at the end; otherwise keyboard is in the way...
    for (var i = 0; i < 10; i++) {
      // TODO
      page.add(Text("\n"));
    }

    // generate document
    scrollController = ScrollController();
    scrollView = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        controller: scrollController,
        padding: EdgeInsets.only(right: 2.0),
        child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(left: 3.0, right: 3.0),
            child: Container(
                constraints: BoxConstraints(maxWidth: maxContentsWidth),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: page))));
    Widget? navBar;
    if (!debugMode && level.numParts != 0) {
      navBar = generateLevelTopNavigationBar(this, level);
    }
    var body = Column(children: [
      Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(children: navBar == null ? [] : [navBar])),
      Expanded(child: scrollView!)
    ]);
    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      var keyboard = Keyboard(this, keyboardState);
      bottomArea = keyboard.generateWidget();
    } else if (debugMode == false) {
      bottomArea =
          generateLevelBottomNavigationBar(this, level, levelTitleKey!);
    }
    return Scaffold(
      appBar: buildAppBar(true, true, this, context, widget.course),
      body: body,
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}

Widget generateLevelTopNavigationBar(State state, MbclLevel level) {
  // navigation bar
  // TODO: click animation
  var iconSize = 45.0;
  var selectedColor = Colors.white;
  var unselectedColor = Color.fromARGB(255, 60, 60, 60);
  // part icons
  List<Widget> icons = [];
  for (var i = 0; i < level.partIconIDs.length; i++) {
    var iconId = level.partIconIDs[i];
    var icon = TextButton(
        onPressed: () {
          level.currentPart = i;
          keyboardState.layout = null;
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
        },
        child: Icon(MdiIcons.fromString(iconId),
            size: iconSize,
            color: level.currentPart == i ? selectedColor : unselectedColor));
    icons.add(
        Padding(padding: EdgeInsets.only(left: 2.0, right: 2.0), child: icon));
  }
  // panel
  // TODO: animate progress controller
  var progress = level.progress;
  if (progress < 0.01) {
    // make progress bar visible
    progress = 0.01;
  }
  return Column(children: [
    LinearProgressIndicator(
      backgroundColor: Colors.grey.withOpacity(0.25),
      value: progress,
      valueColor: AlwaysStoppedAnimation(getStyle().matheBuddyGreen),
      minHeight: 4,
    ),
    Container(
        margin:
            //EdgeInsets.only(left: 5.0, right: 5.0, bottom: 8.0, top: 10),
            EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0, top: 0),
        padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            //border: Border.all(width: 20),
            border: Border(
                //top: BorderSide(width: 0.75, color: Colors.black54),
                bottom: BorderSide(
                    width: 0.85, color: Colors.black.withOpacity(0.125))),
            //borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.18),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(1, 3))
            ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: icons))
  ]);
}

Widget generateLevelBottomNavigationBar(
    State state, MbclLevel level, GlobalKey levelTitleKey) {
  // bottom navigation bar
  var bottomNavBarIconSize = 32.0;
  var bottomNavBarIconColor = Colors.black.withOpacity(0.75);
  List<Widget> buttons = [];
  // left
  if (level.numParts > 0 && level.currentPart > 0) {
    buttons.add(GestureDetector(
        onTapDown: (TapDownDetails d) {
          level.currentPart--;
          keyboardState.layout = null;
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
          Scrollable.ensureVisible(levelTitleKey.currentContext!);
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width: 2.5, color: Colors.black, style: BorderStyle.solid),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Icon(
                MdiIcons.fromString(
                    "chevron-left" /*"arrow-left-bold-box-outline"*/),
                size: bottomNavBarIconSize,
                color: bottomNavBarIconColor))));
  }
  // right
  if (level.numParts > 0) {
    if (level.currentPart < level.numParts - 1) {
      buttons.add(Text('  '));
      buttons.add(GestureDetector(
          onTapDown: (TapDownDetails d) {
            level.currentPart++;
            keyboardState.layout = null;
            // ignore: invalid_use_of_protected_member
            state.setState(() {});
            Scrollable.ensureVisible(levelTitleKey.currentContext!);
          },
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width: 2.5,
                      color: Colors.black,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Icon(
                  MdiIcons.fromString(
                      "chevron-right" /*"arrow-right-bold-box-outline"*/),
                  size: bottomNavBarIconSize,
                  color: bottomNavBarIconColor))));
    } else {
      buttons.add(Text('  '));
      buttons.add(GestureDetector(
          onTapDown: (TapDownDetails d) {
            keyboardState.layout = null;
            Navigator.pop(levelBuildContext!);
            // ignore: invalid_use_of_protected_member
            state.setState(() {});
          },
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width: 2.5,
                      color: Colors.black,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Icon(MdiIcons.fromString("graph-outline"),
                      size: bottomNavBarIconSize,
                      color: bottomNavBarIconColor)))));
    }
  }
  // spacing
  buttons.add(Text("  "));
  // output
  return Opacity(
      opacity: 1.0,
      child: SizedBox(
          height: 60,
          child: Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buttons,
              ))));
}

Widget generateLevelPath(String text) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    Opacity(
        opacity: 0.8,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
                padding: EdgeInsets.all(2),
                child: Text(" $text ", style: TextStyle(color: Colors.white)))))
  ]);
}

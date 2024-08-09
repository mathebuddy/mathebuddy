/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

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

class LevelWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclChapter chapter;
  final MbclUnit? unit;
  final MbclLevel level;
  bool isHelpLevel = false;

  LevelWidget(this.course, this.chapter, this.unit, this.level, {super.key}) {
    isHelpLevel = level.fileId == "help";
    if (isHelpLevel == false) {
      course.lastVisitedChapter = chapter;
      chapter.lastVisitedUnit = unit;
      chapter.lastVisitedLevel = level;
    }
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
    var languageIndex = language == "de" ? 0 : 1; // TODO;
    var title = filterLanguage(level.title, languageIndex);
    levelTitleKey = GlobalKey();
    var levelTitle = Column(children: [
      Container(
          key: levelTitleKey,
          margin: EdgeInsets.only(top: 20.0),
          child: Center(
            child: Text(
              title,
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
    if (widget.isHelpLevel == false &&
        debugMode &&
        level.isDebugLevel == false) {
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

        if (level.showTutorial && part == level.currentPart) {
          var text = "";
          switch (part) {
            case 0:
              text =
                  "\nZum Einstieg in ein neues Level stelle ich dir zunächst eine einfache Frage.\n\n-Wähle die richtige Antwort aus und klicke zur Auswertung auf den Button 'GO'.\n\n-Mit dem Pfeil unten kannst du zur nächsten Lernseite wechseln.";
              break;
            case 1:
              text =
                  "\nAuf der zweiten Seite eines Levels erhältst du neue Informationen.";
              break;
            case 2:
              text =
                  "\nAuf der dritten (und letzten) Seite eines Levels stelle ich dir eine Abschlussfrage. Wenn du diese beantworten kannst, hast du das Wesentliche verstanden!";
              break;
          }
          page.add(Padding(
              padding: EdgeInsets.only(left: 6, right: 6),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 20, color: getStyle().matheBuddyGreen))));
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
    //Widget? navBar;
    List<Widget> levelPartIcons = [];
    if (!debugMode && level.numParts != 0) {
      levelPartIcons = generateLevelPartIcons(this, level);
    }
    var body = scrollView!;

    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      var keyboard = Keyboard(this, keyboardState);
      bottomArea = keyboard.generateWidget();
    }
    /*else*/ if (debugMode == false) {
      var bottomNavBar = generateLevelBottomNavigationBar(
          this, level, levelTitleKey!, context);
      //bottomArea = bottomNavBar;
      page.add(bottomNavBar);
    }

    // add empty lines at the end; otherwise keyboard is in the way...
    for (var i = 0; i < 10; i++) {
      // TODO
      page.add(Text("\n"));
    }

    return Scaffold(
      appBar:
          buildAppBar(true, levelPartIcons, true, this, context, widget.course),
      body: Stack(children: [
        Opacity(
            opacity: 0.035,
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/img/background.jpg"),
                        fit: BoxFit.cover)))),
        body
      ]),
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}

List<Widget> generateLevelPartIcons(State state, MbclLevel level) {
  var selectedColor = Colors.white;
  var unselectedColor = Color.fromARGB(255, 80, 80, 80);
  // part icons
  List<Widget> icons = [];
  for (var i = 0; i < level.partIconIDs.length; i++) {
    var iconId = level.partIconIDs[i];
    var icon = Container(
        width: 38,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: level.currentPart != i
              ? selectedColor.withOpacity(0.33)
              : unselectedColor.withOpacity(0.33),
        ),
        child: GestureDetector(
            onTap: () {
              level.currentPart = i;
              keyboardState.layout = null;
              // ignore: invalid_use_of_protected_member
              state.setState(() {});
            },
            child: Icon(MdiIcons.fromString(iconId),
                color:
                    level.currentPart == i ? selectedColor : unselectedColor)));
    icons.add(Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0, bottom: 0.0),
        child: Container(child: icon)));
  }
  // panel
  // TODO: animate progress controller
  var progress = level.progress;
  if (progress < 0.01) {
    // make progress bar visible
    progress = 0.01;
  }

  //return Container(color: Colors.black, child: Column(children: icons));
  return icons;
}

Widget generateLevelBottomNavigationBar(State state, MbclLevel level,
    GlobalKey levelTitleKey, BuildContext context) {
  // bottom navigation bar
  var bottomNavBarIconSize = 32.0;
  var bottomNavBarIconColor = Colors.black.withOpacity(0.75);
  List<Widget> buttons = [];
  // left
  var hasLeftButton = false;
  if (level.numParts > 0 && level.currentPart > 0) {
    hasLeftButton = true;
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
            child: Icon(MdiIcons.fromString("chevron-left"),
                size: bottomNavBarIconSize, color: bottomNavBarIconColor))));
  }
  // right
  if (level.numParts > 0) {
    if (level.currentPart < level.numParts - 1) {
      if (hasLeftButton) buttons.add(Text('  '));
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
              child: Icon(MdiIcons.fromString("chevron-right"),
                  size: bottomNavBarIconSize, color: bottomNavBarIconColor))));
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
              child:
                  //padding: EdgeInsets.only(left: 5, right: 5),
                  Icon(MdiIcons.fromString("chevron-right" /*"graph-outline"*/),
                      size: bottomNavBarIconSize,
                      color: bottomNavBarIconColor))));
    }
  }
  // add spacing
  for (var i = 0; i < 3; i++) {
    buttons.add(Text('  '));
  }
  // output
  var screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > maxContentsWidth) screenWidth = maxContentsWidth;
  return Container(
      alignment: Alignment.bottomRight,
      child: SizedBox(
          height: 65,
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buttons,
          )));
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

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the unit widget that contains the list of levels.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/event.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/mbcl/src/unit.dart';
import 'package:mathebuddy/screen.dart';

import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_event.dart';
import 'package:mathebuddy/widget_unit_painter.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/widget_level.dart';

class UnitWidget extends StatefulWidget {
  final MbclCourse course;
  final MbclChapter chapter;
  final MbclUnit unit;

  UnitWidget(this.course, this.chapter, this.unit, {Key? key})
      : super(key: key) {
    course.saveUserData();
  }

  @override
  State<UnitWidget> createState() => UnitState();
}

class UnitState extends State<UnitWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var unit = widget.unit;

    var title = Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10, right: 10),
        child: Text(unit.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: getStyle().unitTitleFontColor,
                fontSize: getStyle().unitTitleFontSize)));

    var numRows = unit.levelPosY.reduce(max) + 1;
    var numCols = unit.levelPosX.reduce(max) + 1;

    var maxTileWidth = 500.0;

    var screenWidth = MediaQuery.of(context).size.width;

    var additionalOffsetX = 0.0;
    if (screenWidth > maxContentsWidth) {
      additionalOffsetX = (screenWidth - maxContentsWidth) / 2.0;
      screenWidth = maxContentsWidth;
    }

    var tileWidth = (screenWidth - 50) / (numCols);
    if (tileWidth > maxTileWidth) tileWidth = maxTileWidth;
    var tileHeight = tileWidth;

    var spacingX = 10.0;
    var spacingY = 10.0;
    var offsetX = (screenWidth - (tileWidth + spacingX) * numCols) / 2;
    offsetX += additionalOffsetX;
    var offsetY = 20.0;

    List<Widget> widgets = [];
    // Container is required for SingleChildScrollView
    var height = offsetY + (tileHeight + spacingY) * numRows;
    widgets.add(Container(height: height));

    var unitEdges = UnitEdges(tileWidth * 0.1);

    // calculate progress and vertex coordinates
    for (var i = 0; i < unit.levels.length; i++) {
      var level = unit.levels[i];
      level.calcProgress();
      level.screenPosX = offsetX + unit.levelPosX[i] * (tileWidth + spacingX);
      level.screenPosY = offsetY + unit.levelPosY[i] * (tileHeight + spacingY);
    }
    // calculate edges coordinates
    for (var level in unit.levels) {
      if (level.fileId == "final") continue;
      for (var req in level.requires) {
        if (unit.levelFileIDs.contains(req.fileId) == false) continue;
        unitEdges.addEdge(
            level.screenPosX + tileWidth / 2,
            level.screenPosY + tileHeight / 2,
            req.screenPosX + tileWidth / 2,
            req.screenPosY + tileHeight / 2);
      }
    }
    // render edges
    widgets.add(Positioned(
        left: 0,
        top: 0,
        child: Container(
            //width: 100,
            //height: 100,
            alignment: Alignment.center,
            child: CustomPaint(size: Size(100, 100), painter: unitEdges))));
    // create and render level widgets
    for (var level in unit.levels) {
      var color = level.visited
          ? getStyle().matheBuddyYellow.withOpacity(0.96)
          : getStyle().matheBuddyRed.withOpacity(0.96);
      var textColor =
          Colors.white; //level.visited ? Colors.black : Colors.white;
      if ((level.progress - 1).abs() < 1e-12) {
        color = getStyle().matheBuddyGreen;
        textColor = Colors.white;
      }

      Widget iconOrText;
      if (level.fileId == "final") {
        iconOrText = SizedBox(
            width: 130,
            height: 130,
            child: Icon(
              MdiIcons.fromString("star-circle"),
              size: tileWidth * 0.5,
              color: textColor,
            ));
      } else if (level.iconData.isNotEmpty) {
        // used icon, if available
        iconOrText = SvgPicture.string(
          level.iconData,
          width: tileWidth,
          color: textColor,
          allowDrawingOutsideViewBox: true,
        );
      } else {
        // if there is no icon, show the level title
        var fontSize = getStyle().unitOverviewFontSize;
        if (screenWidth < 512) {
          fontSize *= 0.75;
        }
        iconOrText = Text(level.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: getStyle().unitOverviewFontColor, fontSize: fontSize));
      }

      Widget content = Container(
          alignment: Alignment.center,
          width: tileWidth,
          height: tileHeight,
          child: Padding(
              padding: EdgeInsets.all(0),
              //child: Stack(children: stackedItems)));
              child: iconOrText));

      widgets.add(Positioned(
          left: level.screenPosX,
          top: level.screenPosY,
          child: GestureDetector(
              onTap: () {
                var route = MaterialPageRoute(builder: (context) {
                  if (level.isEvent) {
                    return EventWidget(widget.course, widget.chapter,
                        widget.unit, level, EventData(level));
                  } else {
                    return LevelWidget(
                        widget.course, widget.chapter, widget.unit, level);
                  }
                });
                Navigator.push(context, route).then((value) {
                  setState(() {});
                });
                level.visited = true;
                widget.chapter.saveUserData();
                setState(() {});
              },
              child: Container(
                  width: tileWidth,
                  height: tileHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: color,
                      //border: Border.all(width: 1.5, color: matheBuddyRed),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 0.5,
                            blurRadius: 1.5,
                            offset: Offset(0.5, 0.5)),
                      ],
                      borderRadius:
                          BorderRadius.all(Radius.circular(tileWidth * 0.175))),
                  child: content))));

      if (level.isLocked()) {
        // if the level is locked, show a lock-icon
        var lockSize = tileWidth * 0.25;
        widgets.add(Positioned(
            left: level.screenPosX + 5,
            top: level.screenPosY + 5,
            child: IgnorePointer(
                child: Icon(Icons.lock,
                    size: lockSize, color: Colors.white.withOpacity(0.25)))));
      }
    }

    // debug buttons
    Widget resetProgressBtn = Text("", style: TextStyle(fontSize: 1));
    Widget allLevelsBtn = Text("", style: TextStyle(fontSize: 1));
    if (debugMode) {
      resetProgressBtn = GestureDetector(
          onTap: () {
            unit.resetProgress();
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
                          child: Text(" RESET PROGRESS ",
                              style: TextStyle(color: Colors.white)))))));

      allLevelsBtn = GestureDetector(
          onTap: () {
            // build pseudo level and fill contents of all levels of unit
            var megaLevel = MbclLevel(widget.course, widget.chapter);
            megaLevel.isDebugLevel = true;
            megaLevel.title = "ALL LEVELS OF UNIT: ${unit.title}";
            for (var level in unit.levels) {
              var title =
                  MbclLevelItem(megaLevel, MbclLevelItemType.debugInfo, -1);
              title.text = "----- LEVEL ${level.fileId} -----";
              megaLevel.items.add(title);
              for (var item in level.items) {
                if (item.type == MbclLevelItemType.part) {
                  var part =
                      MbclLevelItem(megaLevel, MbclLevelItemType.debugInfo, -1);
                  part.text = "next part";
                  megaLevel.items.add(part);
                } else {
                  megaLevel.items.add(item);
                }
              }
            }
            // push
            var route = MaterialPageRoute(builder: (context) {
              return LevelWidget(
                  widget.course, widget.chapter, widget.unit, megaLevel);
            });
            Navigator.push(context, route).then((value) => setState(() {}));
            megaLevel.visited = true;
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
                          child: Text(" SHOW ALL LEVELS IN SEQUENCE ",
                              style: TextStyle(color: Colors.white)))))));
    }
    // create body
    var body = SingleChildScrollView(
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        child: Column(children: [
          title,
          resetProgressBtn,
          allLevelsBtn,
          Stack(children: widgets)
        ]));
    return Scaffold(
      appBar: buildAppBar(true, this, widget.chapter),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the unit widget that contains the list of levels.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/unit.dart';

import 'color.dart';
import 'unit_painter.dart';
import 'appbar.dart';
import 'level.dart';

class UnitWidget extends StatefulWidget {
  final MbclUnit unit;

  const UnitWidget(this.unit, {Key? key}) : super(key: key);

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
            style: TextStyle(color: matheBuddyRed, fontSize: 32.0)));

    var numRows = 1.0;
    var numCols = 1.0;
    for (var level in unit.levels) {
      if (level.posX + 1 > numCols) {
        numCols = level.posX + 1;
      }
      if (level.posY + 1 > numRows) {
        numRows = level.posY + 1;
      }
    }
    var maxTileWidth = 500.0;

    var screenWidth = MediaQuery.of(context).size.width;
    var tileWidth = (screenWidth - 50) / (numCols);
    if (tileWidth > maxTileWidth) tileWidth = maxTileWidth;
    var tileHeight = tileWidth;

    var spacingX = 10.0;
    var spacingY = 10.0;
    var offsetX = (screenWidth - (tileWidth + spacingX) * numCols) / 2;
    var offsetY = 20.0;

    List<Widget> widgets = [];
    // Container is required for SingleChildScrollView
    var height = offsetY + (tileHeight + spacingY) * numRows;
    widgets.add(Container(height: height));

    var unitEdges = UnitEdges(tileWidth * 0.1);

    // calculate progress and vertex coordinates
    for (var level in unit.levels) {
      level.calcProgress();
      level.screenPosX = offsetX + level.posX * (tileWidth + spacingX);
      level.screenPosY = offsetY + level.posY * (tileHeight + spacingY);
    }
    // calculate edges coordinates
    for (var level in unit.levels) {
      for (var level2 in level.requires) {
        unitEdges.addEdge(
            level.screenPosX + tileWidth / 2,
            level.screenPosY + tileHeight / 2,
            level2.screenPosX + tileWidth / 2,
            level2.screenPosY + tileHeight / 2);
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
          ? matheBuddyYellow.withOpacity(0.96)
          : matheBuddyRed.withOpacity(0.96);
      var textColor = level.visited ? Colors.black : Colors.white;
      if ((level.progress - 1).abs() < 1e-12) {
        color = matheBuddyGreen;
        textColor = Colors.white;
      }

      var locked = level.isLocked();
      var lockSizePercentage = 0.33;

      // TODO: performance is currently slow...
      List<Widget> stackedItems = [];

      if (level.iconData.isNotEmpty) {
        // used icon, if available
        stackedItems.add(//Opacity(
            //opacity: locked ? lockedItemOpacity : 1.0,
            //child:
            SvgPicture.string(
          level.iconData,
          width: tileWidth,
          color: textColor,
          allowDrawingOutsideViewBox: true,
        ));
      } else {
        // if there is no icon, show the level title
        stackedItems.add(//Opacity(
            //opacity: locked ? lockedItemOpacity : 1.0,
            //child:
            Text(level.title,
                style: TextStyle(color: Colors.white, fontSize: 10)));
      }
      if (locked) {
        // if the level is locked, show a lock-icon
        // TODO: icon instead of text
        stackedItems.add(Padding(
            padding: EdgeInsets.only(top: 5, left: 3),
            child: Icon(Icons.lock,
                size: tileWidth * lockSizePercentage,
                color: Colors.white.withOpacity(0.75))));
      }

      Widget content = Stack(children: stackedItems);
      widgets.add(Positioned(
          left: level.screenPosX,
          top: level.screenPosY,
          child: GestureDetector(
              onTap: () {
                var route = MaterialPageRoute(builder: (context) {
                  return LevelWidget(level);
                });
                Navigator.push(context, route).then((value) => setState(() {}));
                // TODO
                // _level = level;
                // _currentPart = 0;
                // _viewState = ViewState.level;
                level.visited = true;
                //print('clicked on ${level.fileId}');
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
    }
    // create body
    var body = SingleChildScrollView(
        child: Column(children: [title, Stack(children: widgets)]));
    return Scaffold(
      appBar: buildAppBar(this, false),
      body: body,
      backgroundColor: Colors.white,
    );
  }
}

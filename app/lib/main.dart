/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/mbcl/src/event.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/unit.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/level.dart';
import 'package:mathebuddy/screen.dart';

//var bundleName = 'assets/bundle-test.json'; // TODO: this is default!
var bundleName = 'assets/bundle-complex.json';

var debugMode = true;

void main() {
  runApp(const MatheBuddy());
}

class MatheBuddy extends StatelessWidget {
  const MatheBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    //debugPaintBaselinesEnabled = true;
    // mathe:buddy red: 0xFFAA322C
    return MaterialApp(
        title: 'mathe:buddy',
        theme: ThemeData(
          primarySwatch: buildMaterialColor(Color(0xFFFFFFFF)),
        ),
        home: const CoursePage(title: 'mathe:buddy Start Page'),
        debugShowCheckedModeBanner: false);
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key, required this.title});

  final String title;

  @override
  State<CoursePage> createState() => CoursePageState();
}

class KeyboardState {
  KeyboardLayout? layout; // null := not shown
  MbclExerciseData? exerciseData;
  MbclInputFieldData? inputFieldData;
}

enum ViewState { selectCourse, selectUnit, selectLevel, level }

class CoursePageState extends State<CoursePage> {
  Map<String, dynamic> _bundleDataJson = {};
  Map<String, dynamic> _courses = {};

  ViewState _viewState = ViewState.selectCourse;

  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclUnit? _unit;
  MbclLevel? _level;
  GlobalKey? _levelTitleKey;
  int _currentPart = 0;

  String coursePath = "";

  MbclLevelItem? activeExercise; // TODO: must be private!

  KeyboardState keyboardState = KeyboardState();

  bool _onKey(KeyEvent event) {
    // TODO: connect to app keyboard
    print(event);
    print(event.character);
    return true;
  }

  @override
  void initState() {
    super.initState();
    _reloadCourseBundle();

    // TODO: only activate for desktop and web app (NOT mobile)
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  void _selectCourse(String path) async {
    if (path != coursePath) {
      coursePath = path;
      Map<String, dynamic> courseDataJson = {};
      if (path == "DEBUG") {
        if (html.document.getElementById('course-data-span') != null &&
            ((html.document.getElementById('course-data-span')
                        as html.SpanElement)
                    .innerHtml as String)
                .isNotEmpty) {
          var courseDataStr = html.document
              .getElementById('course-data-span')
              ?.innerHtml as String;
          courseDataStr = courseDataStr.replaceAll('&lt;', '<');
          courseDataStr = courseDataStr.replaceAll('&gt;', '>');
          courseDataStr = courseDataStr.replaceAll('&quot;', '"');
          courseDataStr = courseDataStr.replaceAll('&#039;', '\'');
          courseDataStr = courseDataStr.replaceAll('&amp;', '&');
          courseDataJson = jsonDecode(courseDataStr);
          //print(courseDataStr);
        } else {
          return;
        }
      } else {
        courseDataJson = _bundleDataJson[path];
      }
      //print("selected course: ");
      //print(courseDataJson);
      _course = MbclCourse();
      _course?.fromJSON(courseDataJson);
      print("course title ${_course!.title}");
    }
    if (_course!.debug == MbclCourseDebug.level) {
      _chapter = _course!.chapters[0];
      _level = _chapter!.levels[0];
      _currentPart = 0;
      _viewState = ViewState.level;
    } else if (_course!.debug == MbclCourseDebug.chapter) {
      _chapter = _course!.chapters[0];
      _viewState = ViewState.selectUnit;
      if (_chapter!.units.length == 1) {
        _unit = _chapter!.units[0];
        _viewState = ViewState.selectLevel;
      }
    }
    setState(() {});
  }

  void _reloadCourseBundle() async {
    if (html.document.getElementById('bundle-id') != null) {
      bundleName = html.document.getElementById('bundle-id')!.innerHtml!;
    }

    _bundleDataJson = {};
    var bundleDataStr = await DefaultAssetBundle.of(context)
        .loadString(bundleName, cache: false);
    _bundleDataJson = jsonDecode(bundleDataStr);
    //print(bundleDataJson);
    _courses = {};
    if (bundleName.contains('bundle-test.json')) {
      _courses = {'DEBUG': ''};
    }
    _bundleDataJson.forEach((key, value) {
      if (key != '__type') {
        _courses[key] = value;
      }
    });
    print('list of courses: ${_courses.keys}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: split into multiple methods (or even classes)

    screenWidth = MediaQuery.of(context).size.width;
    scrollController = ScrollController();

    Widget body = Text(
      "No course was selected!!!",
      style: Theme.of(context).textTheme.headlineLarge,
    );

    List<Widget> page = [];

    if (_viewState == ViewState.selectCourse) {
      // ----- course list -----
      List<TableRow> tableRows = [];
      for (var course in _courses.keys) {
        tableRows.add(TableRow(children: [
          TableCell(
            child: GestureDetector(
                onTap: () {
                  _selectCourse(course);
                },
                child: Container(
                    margin: EdgeInsets.all(2.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                        color: course == 'DEBUG'
                            ? Color.fromARGB(255, 255, 210, 210)
                            : Colors.white,
                        border: Border.all(
                            width: 2.0, color: Color.fromARGB(255, 81, 81, 81)),
                        borderRadius: BorderRadius.circular(100.0)),
                    child: Center(child: Text(course)))),
          )
        ]));
        if (debugMode == false) {
          // TODO
          break;
        }
      }

      var coursesTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      );

      var logo =
          Column(children: [Image.asset('assets/img/logo-large-en.png')]);

      // var text = Padding(
      //     padding: EdgeInsets.all(5),
      //     child: Container(
      //         decoration: BoxDecoration(
      //             color: Colors.white,
      //             border: Border.all(color: Colors.white),
      //             borderRadius: BorderRadius.circular(50)),
      //         child: Text(
      //           '  ALPHA  ',
      //           style: TextStyle(color: matheBuddyRed, fontSize: 36),
      //         )));

      var contents = Column(children: [logo /*, text*/, coursesTable]);

      body = SingleChildScrollView(padding: EdgeInsets.all(5), child: contents);
    } else if (_viewState == ViewState.selectUnit) {
      // ----- unit list -----
      List<TableRow> tableRows = [];
      for (var unit in _chapter!.units) {
        tableRows.add(TableRow(children: [
          TableCell(
            child: GestureDetector(
                onTap: () {
                  _unit = unit;
                  _viewState = ViewState.selectLevel;
                  setState(() {});
                },
                child: Container(
                    margin: EdgeInsets.all(2.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2.0, color: Color.fromARGB(255, 81, 81, 81)),
                        borderRadius: BorderRadius.circular(100.0)),
                    child: Center(child: Text(unit.title)))),
          )
        ]));
      }

      var unitsTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      );

      var contents = Column(children: [unitsTable]);

      body = SingleChildScrollView(padding: EdgeInsets.all(5), child: contents);
    } else if (_viewState == ViewState.selectLevel) {
      // ----- level list -----
      var unit = _unit!;

      var title = Padding(
          padding: EdgeInsets.only(top: 20.0, left: 10, right: 10),
          child: Text(unit.title,
              style: TextStyle(color: matheBuddyRed, fontSize: 32.0)));

      //print(_unit!.title);
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

      var tileWidth = (screenWidth - 50) / (numCols);
      if (tileWidth > maxTileWidth) tileWidth = maxTileWidth;
      var tileHeight = tileWidth;
      //print('num rows: $numRows');
      //print('num cols: $numCols');

      var spacingX = 10.0;
      var spacingY = 10.0;
      var offsetX = (screenWidth - (tileWidth + spacingX) * numCols) / 2;
      var offsetY = 20.0;

      List<Widget> widgets = [];
      // Container is required for SingleChildScrollView
      widgets
          .add(Container(height: offsetY + (tileHeight + spacingY) * numRows));

      var unitEdges = UnitEdges(tileWidth * 0.1);

      // calculate vertex coordinates
      for (var level in unit.levels) {
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
      var widget = Positioned(
          left: 0,
          top: 0,
          child: Container(
              //width: 100,
              //height: 100,
              alignment: Alignment.center,
              child: CustomPaint(size: Size(100, 100), painter: unitEdges)));
      widgets.add(widget);
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
        var widget = Positioned(
            left: level.screenPosX,
            top: level.screenPosY,
            child: GestureDetector(
                onTap: () {
                  _level = level;
                  _currentPart = 0;
                  _viewState = ViewState.level;
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(tileWidth * 0.175))),
                    child: content)));
        widgets.add(widget);
      }
      // create body
      body = SingleChildScrollView(
          child: Column(children: [title, Stack(children: widgets)]));
    } else if (_viewState == ViewState.level) {
      // ----- level -----
      var level = _level as MbclLevel;
      level.calcProgress();
      List<Widget> levelHeadItems = [];
      // title
      _levelTitleKey = GlobalKey();
      // var levelTitle = Column(children: [
      //   Container(
      //       //width: screenWidth,
      //       margin: EdgeInsets.only(top: level.numParts > 0 ? 8 : 8),
      //       decoration: BoxDecoration(
      //           //color: Colors.white,
      //           color: matheBuddyRed,
      //           // border: Border(
      //           //   //left: BorderSide(color: matheBuddyRed, width: 1.5),
      //           //   top: BorderSide(color: matheBuddyRed, width: 1.25),
      //           //   bottom: BorderSide(color: matheBuddyRed, width: 1.25),
      //           // ),
      //           border: Border.all(width: 0, color: matheBuddyRed),
      //           borderRadius: BorderRadius.circular(5)
      //           // boxShadow: [
      //           //   BoxShadow(
      //           //       //color: Colors.grey.withOpacity(0.18),
      //           //       color: matheBuddyRed.withOpacity(0.58),
      //           //       spreadRadius: 2,
      //           //       blurRadius: 2,
      //           //       offset: Offset(1, 1))
      //           // ]
      //           ),
      //       child: Padding(
      //           key: _levelTitleKey,
      //           padding: EdgeInsets.only(
      //               left: 5.0, right: 3.0, top: 2.0, bottom: 2.0),
      //           child: Center(
      //               child: Container(
      //             // decoration: BoxDecoration(
      //             //     color: Colors.white,
      //             //     border: Border.all(color: matheBuddyRed, width: 4),
      //             //     borderRadius: BorderRadius.circular(5)),
      //             child: Text(level.title, //.toUpperCase(),
      //                 style: TextStyle(
      //                   //color: matheBuddyRed,
      //                   color: Colors.white,
      //                   fontSize: level.numParts > 0 ? 20 : 32,
      //                   //fontWeight: FontWeight.bold
      //                 )),
      //           ))))
      // ]);
      var levelTitle = Column(children: [
        Container(
          key: _levelTitleKey,
          margin: EdgeInsets.only(top: 10.0),
          child: Text(
            level.title,
            style: TextStyle(
                fontSize: 24,
                color: matheBuddyRed,
                fontWeight: FontWeight.w600),
          ),
        )
      ]);
      //levelHeadItems.add(levelTitle);
      page.add(levelTitle);
      // navigation bar
      if (level.numParts > 0) {
        // TOOD: click animation
        var iconSize = 42.0;
        var selectedColor = matheBuddyGreen; // TODO
        var unselectedColor = Color.fromARGB(255, 91, 91, 91);
        // part icons
        List<Widget> icons = [];
        for (var i = 0; i < level.partIconIDs.length; i++) {
          var iconId = level.partIconIDs[i];
          var icon = GestureDetector(
              onTapDown: (TapDownDetails d) {
                _currentPart = i;
                keyboardState.layout = null;
                setState(() {});
              },
              child: Icon(MdiIcons.fromString(iconId),
                  size: iconSize,
                  color: _currentPart == i ? selectedColor : unselectedColor));
          icons.add(Padding(
              padding: EdgeInsets.only(left: 2.0, right: 2.0), child: icon));
        }
        // level percentage
        // icons.add(Text("   "));
        // var percentage = (_level!.progress * 100).round();
        // var actionLevelPercentage = Padding(
        //     padding: EdgeInsets.only(top: 12),
        //     child: Text(
        //       '$percentage %',
        //       style: TextStyle(fontSize: 14, color: Colors.black87),
        //     ));
        // icons.add(actionLevelPercentage);
        // up icon
        /*var icon = GestureDetector(
            onTapDown: (TapDownDetails d) {
              _onHomeButton();
              setState(() {});
            },
            child: Padding(
                padding: EdgeInsets.only(left: 30),
                child: Icon(
                    MdiIcons.fromString(
                        "graph-outline" /*"arrow-up-circle-outline"*/),
                    size: iconSize,
                    color: unselectedColor)));
        icons.add(icon);*/

        // panel
        // TODO: animate progress controller
        var progress = _level!.progress;
        if (progress < 0.01) {
          // make progress bar visible
          progress = 0.01;
        }
        levelHeadItems.add(Column(children: [
          LinearProgressIndicator(
            value: progress,
            valueColor: AlwaysStoppedAnimation(matheBuddyGreen),
            minHeight: 5,
          ),
          Container(
              margin:
                  //EdgeInsets.only(left: 5.0, right: 5.0, bottom: 8.0, top: 10),
                  EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0, top: 0),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
              decoration: BoxDecoration(
                  color: Colors.white,
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
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, children: icons))
        ]));
      }

      // level items
      level.isEvent = false; // TODO!!!!
      if (level.isEvent) {
        // -------- event level --------
        // create event instance, if it does not exist
        level.eventData ??= MbclEventData(level);
        // add timer

        // TODO: refresh every second!!
        var elapsedTime =
            DateTime.now().difference(level.eventData!.startTimeEvent);
        var elapsedTimeStr = "${elapsedTime.inSeconds}";
        page.add(Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(children: [
                  Text(
                    elapsedTimeStr,
                    style: TextStyle(fontSize: 32),
                  ),
                  Text('   '),
                  Text(
                    '1337',
                    style: TextStyle(fontSize: 32),
                  )
                ]))));
        // add current exercise
        var ex = level.eventData!.getCurrentExercise();
        if (ex != null) {
          page.add(generateLevelItem(this, level, ex));
        }
      } else {
        // -------- non-event level --------
        var part = -1;
        for (var item in level.items) {
          if (item.type == MbclLevelItemType.part) {
            part++;
          } else {
            if (level.numParts > 0 && part != _currentPart) continue;
            page.add(generateLevelItem(this, level, item));
          }
        }
      }

      // bottom navigation bar
      var bottomNavBarIconSize = 32.0;
      var bottomNavBarIconColor = Colors.black.withOpacity(0.75);
      List<Widget> buttons = [];
      // left
      if (level.numParts > 0 && _currentPart > 0) {
        buttons.add(GestureDetector(
            onTapDown: (TapDownDetails d) {
              _currentPart--;
              keyboardState.layout = null;
              setState(() {});
              Scrollable.ensureVisible(_levelTitleKey!.currentContext!);
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
                        "chevron-left" /*"arrow-left-bold-box-outline"*/),
                    size: bottomNavBarIconSize,
                    color: bottomNavBarIconColor))));
      }
      // up
      /*buttons.add(GestureDetector(
          onTapDown: (TapDownDetails d) {
            keyboardState.layout = null;
            _onHomeButton();
            setState(() {});
          },
          child: Icon(MdiIcons.fromString("arrow-up-bold-box-outline"),
              size: iconSize, color: Colors.black87)));*/
      // right
      if (level.numParts > 0) {
        if (_currentPart < level.numParts - 1) {
          buttons.add(Text('  '));
          buttons.add(GestureDetector(
              onTapDown: (TapDownDetails d) {
                _currentPart++;
                keyboardState.layout = null;
                setState(() {});
                Scrollable.ensureVisible(_levelTitleKey!.currentContext!);
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
                _onHomeButton();
                setState(() {});
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
      page.add(Column(children: [
        Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end, children: buttons))
      ]));

      // add empty lines at the end; otherwise keyboard is in the way...
      for (var i = 0; i < 10; i++) {
        // TODO
        page.add(Text("\n"));
      }
      scrollView = SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(right: 2.0),
          child: Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: page)));

      body = Column(children: [
        Column(children: levelHeadItems),
        Expanded(
            child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: scrollView!))
      ]);

      /* OLD AND WORKING:
        body = Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: scrollView!);*/
    }

    /*page.add(TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ),
      onPressed: _getCourseDataDEBUG,
      child: Text('get message'),
    ));*/

    var keyboard = Keyboard();
    //print('screen width = $screenWidth');

    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      bottomArea = keyboard.generateWidget(this, keyboardState);
    }

    List<Widget> actions = [];
    // level percentage
    // if (_viewState == ViewState.level) {
    //   var percentage = (_level!.progress * 100).round();
    //   var actionLevelPercentage = Padding(
    //       padding: EdgeInsets.only(top: 12),
    //       child: Text(
    //         '$percentage %',
    //         style: TextStyle(fontSize: 28, color: Colors.black87),
    //       ));
    //   actions.add(actionLevelPercentage);
    // }
    // home button
    actions.add(Text('  '));
    var actionHome = IconButton(
      onPressed: () {
        _onHomeButton(allUp: false);
      },
      icon: _viewState == ViewState.level
          ? Icon(
              MdiIcons.fromString("graph-outline"),
              size: 36,
            )
          : Icon(Icons.home, size: 36),
    );
    actions.add(actionHome);
    actions.add(Text('    '));

    // === MAIN APP WIDGET ===
    var switchDebugReleaseButton = Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(6)),
        child: Text(debugMode ? " DEBUG " : " RELEASE ",
            style: TextStyle(fontSize: 16)));
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: GestureDetector(
              onTap: () {
                debugMode = !debugMode;
                setState(() {});
              },
              child: switchDebugReleaseButton),
          leading: IconButton(
            onPressed: () {},
            icon: Image.asset("assets/img/logoSmall.png"),
          ),
          elevation: 1,
          actions: actions
          // TODO: reactivate progress bars

          /*Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                value: _level != null ? _level!.progress : 0.0,
                semanticsLabel: "my progress",
                color: matheBuddyGreen,
              ),
            ),
          ),
          Text('    '),
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                value: 0.9,
                semanticsLabel: "my progress",
                color: matheBuddyYellow,
              ),
            ),
          ),
          Text('    '),
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                value: 0.45,
                semanticsLabel: "my progress",
                color: matheBuddyGreen,
              ),
            ),
          ),
          Text('       '),*/
          // TODO: chat icon
          /*IconButton(
            onPressed: () {
              // TODO
            },
            icon: Icon(Icons.chat, size: 36),
          ),*/

          ),
      body: body,
      bottomSheet: bottomArea,
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          //_selectCourse();
        },
        tooltip: 'load course',
        child: const Icon(Icons.add),
      ),*/
    );
  }

  void _onHomeButton({bool allUp = false}) {
    //_reloadCourseBundle();
    keyboardState.layout = null;
    _level = null;
    if (allUp) {
      _viewState = ViewState.selectCourse;
    }
    switch (_viewState) {
      case ViewState.selectCourse:
        {
          // do nothing
          break;
        }
      case ViewState.selectUnit:
        {
          _viewState = ViewState.selectCourse;
          break;
        }
      case ViewState.selectLevel:
        {
          _viewState = ViewState.selectUnit;
          if (_chapter!.units.length == 1) {
            _viewState = ViewState.selectCourse;
          }
          break;
        }
      case ViewState.level:
        {
          _level?.eventData = null;
          if (_course!.debug == MbclCourseDebug.chapter) {
            _viewState = ViewState.selectLevel;
          } else {
            _viewState = ViewState.selectCourse;
          }
          break;
        }
    }
    setState(() {});
  }
}

// TODO: move this to a new file
class UnitEdge {
  double x1 = 0;
  double y1 = 0;
  double x2 = 0;
  double y2 = 0;
  UnitEdge(this.x1, this.x2, this.y1, this.y2);
}

// TODO: move this to a new file
class UnitEdges extends CustomPainter {
  List<UnitEdge> _edges = [];
  double strokeWidth = 10.0;

  UnitEdges(this.strokeWidth);

  void addEdge(double x1, double y1, double x2, double y2) {
    _edges.add(UnitEdge(x1, x2, y1, y2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black87;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    for (var e in _edges) {
      Offset startingOffset = Offset(e.x1, e.y1);
      Offset endingOffset = Offset(e.x2, e.y2);
      canvas.drawLine(startingOffset, endingOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

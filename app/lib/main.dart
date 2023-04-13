/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

//import 'package:google_fonts/google_fonts.dart';

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

var bundleName = 'assets/bundle-test.json';

void main() {
  /*GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('assets/google_fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['assets/google_fonts'], license);
  });*/

  runApp(const MatheBuddy());
}

class MatheBuddy extends StatelessWidget {
  const MatheBuddy({super.key});

  @override
  Widget build(BuildContext context) {
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
        courseDataJson = jsonDecode(courseDataStr);
        //print(courseDataStr);
      } else {
        return;
      }
    } else {
      courseDataJson = _bundleDataJson[path];
    }
    print("selected course: ");
    print(courseDataJson);
    _course = MbclCourse();
    _course?.fromJSON(courseDataJson);
    var course = _course as MbclCourse;
    print("course title ${course.title}");
    if (course.debug == MbclCourseDebug.level) {
      _chapter = _course?.chapters[0];
      _level = _chapter?.levels[0];
      _viewState = ViewState.level;
    } else if (course.debug == MbclCourseDebug.chapter) {
      _chapter = _course?.chapters[0];
      _viewState = ViewState.selectUnit;
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
                        border: Border.all(
                            width: 2.0, color: Color.fromARGB(255, 81, 81, 81)),
                        borderRadius: BorderRadius.circular(100.0)),
                    child: Center(child: Text(course)))),
          )
        ]));
      }

      var coursesTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      );

      var logo =
          Column(children: [Image.asset('assets/img/logo-large-en.png')]);
      var contents = Column(children: [logo, coursesTable]);

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
      var unit = _unit!;

      var title = Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(unit.title,
              style: TextStyle(color: matheBuddyRed, fontSize: 42.0)));

      //print(_unit!.title);
      var numRows = 1;
      var numCols = 1;
      for (var level in unit.levels) {
        if (level.posX + 1 > numCols) {
          numCols = level.posX + 1;
        }
        if (level.posY + 1 > numRows) {
          numRows = level.posY + 1;
        }
      }
      var maxTileWidth = 100.0;

      var tileWidth = screenWidth / (numCols + 1);
      if (tileWidth > maxTileWidth) tileWidth = maxTileWidth;
      var tileHeight = tileWidth;
      //print('num rows: $numRows');
      //print('num cols: $numCols');

      var spacing = 10.0;
      var offsetX = (screenWidth - (tileWidth + spacing) * numCols) / 2;
      var offsetY = 20.0;

      List<Widget> widgets = [];
      // Container is required for SingleChildScrollView
      widgets
          .add(Container(height: offsetY + (tileHeight + spacing) * numRows));

      for (var level in unit.levels) {
        var x = offsetX + level.posX * (tileWidth + spacing);
        var y = offsetY + level.posY * (tileHeight + spacing);
        var widget = Positioned(
            left: x,
            top: y,
            child: GestureDetector(
                onTap: () {
                  _level = level;
                  _viewState = ViewState.level;
                  //print('clicked on ${level.fileId}');
                  setState(() {});
                },
                child: Container(
                    width: tileWidth,
                    height: tileHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: matheBuddyGreen,
                        border: Border.all(width: 1.5, color: matheBuddyGreen),
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    child: Text(
                      level.title,
                      style: TextStyle(color: Colors.white),
                    ))));
        widgets.add(widget);
      }

      body = SingleChildScrollView(
          child: Column(children: [title, Stack(children: widgets)]));
    } else if (_viewState == ViewState.level) {
      // ----- level -----
      var level = _level as MbclLevel;
      page.add(Padding(
          padding:
              EdgeInsets.only(left: 3.0, right: 3.0, top: 5.0, bottom: 5.0),
          child: Text(
            level.title.toUpperCase(),
            style: TextStyle(
                color: matheBuddyRed,
                fontSize: 40,
                fontWeight: FontWeight.bold),
          )));
      for (var item in level.items) {
        page.add(generateLevelItem(this, item));
      }
      // add empty lines at the end; otherwise keyboard is in the way...
      for (var i = 0; i < 20; i++) {
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
      //body = scrollView as Widget;
      body = Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: scrollView!);
      //body = Shortcuts(shortcuts: <ShortcutActivator,Intent>{
      //  SingleActivator()
      //}, child: body);
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(/*widget.title*/ ""),
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/img/logoSmall.png"),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                value: 0.7,
                semanticsLabel: "my progress",
                color: matheBuddyRed,
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
          Text('       '),
          IconButton(
            onPressed: () {
              // TODO
            },
            icon: Icon(Icons.chat, size: 36),
          ),
          Text('  '),
          IconButton(
            onPressed: () {
              _reloadCourseBundle();
              switch (_viewState) {
                case ViewState.selectCourse:
                  {
                    // do nothing
                    break;
                  }
                case ViewState.selectUnit:
                  {
                    _viewState = ViewState.selectCourse;
                    _chapter = null;
                    _level = null;
                    keyboardState.layout = null;
                    setState(() {});
                    break;
                  }
                case ViewState.selectLevel:
                  {
                    _viewState = ViewState.selectUnit;
                    keyboardState.layout = null;
                    setState(() {});
                    break;
                  }
                case ViewState.level:
                  {
                    if (_course!.debug == MbclCourseDebug.chapter) {
                      _viewState = ViewState.selectLevel;
                      keyboardState.layout = null;
                      setState(() {});
                    } else {
                      _viewState = ViewState.selectCourse;
                      _chapter = null;
                      _level = null;
                      keyboardState.layout = null;
                      setState(() {});
                    }
                    break;
                  }
              }
            },
            icon: Icon(Icons.home, size: 36),
          ),
          Text('    ')
        ],
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
}

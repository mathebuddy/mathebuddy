/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/level.dart';

void main() {
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

class CoursePageState extends State<CoursePage> {
  String _courseData = '';
  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclLevel? _level;

  KeyboardState keyboardState = KeyboardState();

  @override
  void initState() {
    super.initState();
  }

  void _selectCourse(String path) async {
    print("_getCourseDataDEBUG:");
    if (path == "DEBUG" &&
        html.document.getElementById('course-data-span') != null &&
        ((html.document.getElementById('course-data-span') as html.SpanElement)
                .innerHtml as String)
            .isNotEmpty) {
      _courseData =
          html.document.getElementById('course-data-span')?.innerHtml as String;
    } else {
      if (path == "DEBUG") path = "assets/hello_COMPILED.json";
      _courseData =
          await DefaultAssetBundle.of(context).loadString(path, cache: false);
    }
    print("received course: ");
    print(_courseData);
    if (_courseData.isNotEmpty) {
      var courseDataJson = jsonDecode(_courseData);
      _course = MbclCourse();
      _course?.fromJSON(courseDataJson);
      var course = _course as MbclCourse;
      print("course title ${course.title}");
      if (course.debug == MbclCourseDebug.level) {
        _chapter = _course?.chapters[0];
        _level = _chapter?.levels[0];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Text(
      "No course was selected!!!",
      style: Theme.of(context).textTheme.headlineLarge,
    );

    var screenWidth = MediaQuery.of(context).size.width;

    List<Widget> page = [];
    if (_level == null) {
      var courses = [
        'assets/definitions_COMPILED.json',
        'assets/equations_COMPILED.json',
        'assets/examples_COMPILED.json',
        'assets/exercises-simple_COMPILED.json',
        'assets/typography_COMPILED.json',
        'DEBUG'
      ];
      List<TableRow> tableRows = [];
      for (var course in courses) {
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
        //border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      );

      var logo =
          Column(children: [Image.asset('assets/img/logo-large-en.png')]);
      var contents = Column(children: [logo, coursesTable]);

      body = SingleChildScrollView(padding: EdgeInsets.all(5), child: contents);
      /*Container(
              //color: Colors.white,
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: rows,
              ))*/
    } else {
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
      for (var i = 0; i < 10; i++) {
        page.add(Text("\n"));
      }
      body = SingleChildScrollView(
          padding: EdgeInsets.only(right: 2.0),
          child: Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: page)));
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
      bottomArea = Container(
          color: Colors.black26,
          alignment: Alignment.bottomCenter,
          constraints: BoxConstraints(maxHeight: 285.0),
          child: keyboard.generateWidget(this, keyboardState, screenWidth));
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
                color: Colors.amber.shade800,
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
                color: Colors.green.shade700,
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
              _level = null;
              keyboardState.layout = null;
              setState(() {});
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

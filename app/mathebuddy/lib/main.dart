/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'color.dart';

// TODO: rename all classes!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mathe:buddy',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: buildMaterialColor(Color(0xFFAA322C)), // Colors.red,
      ),
      home: const MyHomePage(title: 'mathe:buddy Start Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  String _courseData = '';
  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclLevel? _level;

  void _getCourseDataDEBUG() async {
    _courseData = await DefaultAssetBundle.of(context)
        .loadString("assets/typography_COMPILED.json");
    setState(() {
      print("_getCourseDataDEBUG:");
      if (html.document.getElementById('course-data-span') != null &&
          ((html.document.getElementById('course-data-span')
                      as html.SpanElement)
                  .innerHtml as String)
              .isNotEmpty) {
        _courseData = html.document
            .getElementById('course-data-span')
            ?.innerHtml as String;
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
      // update view
      setState(() {}); // TODO: necessary? was also called above!
    });
  }

  void _incrementCounter() {
    setState(() {
      //_counter++;
    });
  }

  TextSpan genParagraphItem(MbclLevelItem item) {
    switch (item.type) {
      case MbclLevelItemType.text:
        //return TextSpan(text: item.text, style: Theme.of(context).textTheme.bodyLarge);
        return TextSpan(
            text: "${item.text} ", style: TextStyle(color: Colors.black));
      case MbclLevelItemType.boldText:
      case MbclLevelItemType.italicText:
      case MbclLevelItemType.color:
        {
          List<TextSpan> gen = [];
          for (var it in item.items) {
            gen.add(genParagraphItem(it));
          }
          switch (item.type) {
            case MbclLevelItemType.boldText:
              return TextSpan(
                  children: gen,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold));
            case MbclLevelItemType.italicText:
              return TextSpan(
                  children: gen,
                  style: TextStyle(
                      color: Colors.black, fontStyle: FontStyle.italic));
            case MbclLevelItemType.color:
              // TODO: coloring does not work...
              // TODO: color must depend on key (id entry defines a number as string)
              return TextSpan(
                  children: gen, style: TextStyle(color: Colors.blue));
            default:
              // this will never happen
              return TextSpan();
          }
        }
      case MbclLevelItemType.lineFeed:
        return TextSpan(text: '\n');
      default:
        print(
            "ERROR: genParagraphItem(..): type '${item.type.name}' is not implemented");
        return TextSpan(text: "", style: TextStyle());
    }
  }

  Widget genLevelItem(MbclLevelItem item) {
    switch (item.type) {
      case MbclLevelItemType.section:
        {
          return Text(item.text,
              style: Theme.of(context).textTheme.headlineLarge);
        }
      case MbclLevelItemType.subSection:
        {
          return Text(item.text,
              style: Theme.of(context).textTheme.headlineMedium);
        }
      case MbclLevelItemType.paragraph:
        {
          List<TextSpan> list = [];
          for (var subItem in item.items) {
            list.add(genParagraphItem(subItem));
          }
          var richText = RichText(
            text: TextSpan(children: list),
          );
          return richText;
        }
      case MbclLevelItemType.alignCenter:
        {
          List<Widget> list = [];
          for (var subItem in item.items) {
            list.add(genLevelItem(subItem));
          }
          return Align(
              alignment: Alignment.topCenter,
              child: Wrap(alignment: WrapAlignment.start, children: list));
        }
      default:
        print(
            "ERROR: genLevelItem(..): type '${item.type.name}' is not implemented");
        return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> page = [];
    if (_level == null) {
      page.add(Text(
        "No course was selected!!!",
        style: Theme.of(context).textTheme.headlineLarge,
      ));
    } else {
      // TODO: own method for this
      var level = _level as MbclLevel;
      page.add(Text(
        level.title.toUpperCase(),
        style: Theme.of(context).textTheme.headlineMedium,
      ));
      for (var item in level.items) {
        page.add(genLevelItem(item));
      }
    }
    /*page.add(TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ),
      onPressed: _getCourseDataDEBUG,
      child: Text('get message'),
    ));*/

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              child: Column(
                  // Column is also a layout widget. It takes a list of children and
                  // arranges them vertically. By default, it sizes itself to fit its
                  // children horizontally, and tries to be as tall as its parent.
                  //
                  // Invoke "debug painting" (press "p" in the console, choose the
                  // "Toggle Debug Paint" action from the Flutter Inspector in Android
                  // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                  // to see the wireframe for each widget.
                  //
                  // Column has various properties to control how it sizes itself and
                  // how it positions its children. Here we use mainAxisAlignment to
                  // center the children vertically; the main axis here is the vertical
                  // axis because Columns are vertical (the cross axis would be
                  // horizontal).
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: page))),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCourseDataDEBUG,
        tooltip: 'load course',
        child: const Icon(Icons.add),
      ),
    );
  }
}

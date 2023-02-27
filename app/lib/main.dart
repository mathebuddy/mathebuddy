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

void main() {
  runApp(const MatheBuddy());
}

class MatheBuddy extends StatelessWidget {
  const MatheBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mathe:buddy',
      theme: ThemeData(
        primarySwatch: buildMaterialColor(Color(0xFFAA322C)),
      ),
      home: const CoursePage(title: 'mathe:buddy Start Page'),
    );
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key, required this.title});

  final String title;

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String _courseData = '';
  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclLevel? _level;

  void _getCourseDataDEBUG() async {
    // TODO: config default course
    _courseData = await DefaultAssetBundle.of(context)
        .loadString("assets/typography_COMPILED.json");
    print("_getCourseDataDEBUG:");
    if (html.document.getElementById('course-data-span') != null &&
        ((html.document.getElementById('course-data-span') as html.SpanElement)
                .innerHtml as String)
            .isNotEmpty) {
      _courseData =
          html.document.getElementById('course-data-span')?.innerHtml as String;
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

  TextSpan _genParagraphItem(MbclLevelItem item) {
    switch (item.type) {
      case MbclLevelItemType.text:
        return TextSpan(
            text: "${item.text} ", style: TextStyle(color: Colors.black));
      case MbclLevelItemType.boldText:
      case MbclLevelItemType.italicText:
      case MbclLevelItemType.color:
        {
          List<TextSpan> gen = [];
          for (var it in item.items) {
            gen.add(_genParagraphItem(it));
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

  Widget _genLevelItem(MbclLevelItem item) {
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
            list.add(_genParagraphItem(subItem));
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
            list.add(_genLevelItem(subItem));
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
        page.add(_genLevelItem(item));
      }
    }
    /*page.add(TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ),
      onPressed: _getCourseDataDEBUG,
      child: Text('get message'),
    ));*/

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 3.0, right: 3.0),
              child: Column(
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

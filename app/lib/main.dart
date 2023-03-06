/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:tex/tex.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'color.dart';

const matheBuddyRed = Color.fromARGB(0xFF, 0xAA, 0x32, 0x2C);

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
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String _courseData = '';
  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclLevel? _level;

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
      _courseData = await DefaultAssetBundle.of(context).loadString(path);
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

  InlineSpan _genParagraphItem(MbclLevelItem item) {
    double fontSize = 16;
    switch (item.type) {
      case MbclLevelItemType.text:
        return TextSpan(
          text: "${item.text} ",
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        );
      case MbclLevelItemType.boldText:
      case MbclLevelItemType.italicText:
      case MbclLevelItemType.color:
        {
          List<InlineSpan> gen = [];
          for (var it in item.items) {
            gen.add(_genParagraphItem(it));
          }
          switch (item.type) {
            case MbclLevelItemType.boldText:
              return TextSpan(
                  children: gen,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize));
            case MbclLevelItemType.italicText:
              return TextSpan(
                  children: gen,
                  style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontSize: fontSize));
            case MbclLevelItemType.color:
              // TODO: coloring does not work...
              // TODO: color must depend on key (id entry defines a number as string)
              return TextSpan(
                  children: gen,
                  style: TextStyle(color: Colors.blue, fontSize: fontSize));
            default:
              // this will never happen
              return TextSpan();
          }
        }
      case MbclLevelItemType.inlineMath:
        {
          var tex = TeX();
          var texSrc = ''; // TODO: must get this from child elements!
          for (var subItem in item.items) {
            switch (subItem.type) {
              case MbclLevelItemType.text:
                texSrc += subItem.text;
                break;
              default:
                print(
                    "ERROR: genParagraphItem(..): type '${item.type.name}' is not finally implemented");
            }
          }
          // TODO: if texSrc.isEmpty -> then do NOT create SVG, since flutter_svg will crash when displaying an image of width 0
          var svg = tex.tex2svg(texSrc);
          print(svg);

          if (svg.isEmpty) {
            return TextSpan(
              text: "${tex.error} ",
              style: TextStyle(color: Colors.red, fontSize: fontSize),
            );
          } else {
            return WidgetSpan(
                child: SvgPicture.string(
              svg,
              //height: 20,
              width: 75, // TODO!! must get width from tex-API
            ));
          }
        }

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
          return Padding(
              //padding: EdgeInsets.all(3.0),
              padding: EdgeInsets.only(
                  left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
              child: Text(item.text,
                  style: Theme.of(context).textTheme.headlineLarge));
        }
      case MbclLevelItemType.subSection:
        {
          return Padding(
              padding: EdgeInsets.only(
                  left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
              child: Text(item.text,
                  style: Theme.of(context).textTheme.headlineMedium));
        }
      case MbclLevelItemType.paragraph:
        {
          List<InlineSpan> list = [];
          for (var subItem in item.items) {
            list.add(_genParagraphItem(subItem));
          }
          var richText = RichText(
            text: TextSpan(children: list),
          );
          return Padding(
            padding: EdgeInsets.all(3.0),
            child: richText,
          );
        }
      case MbclLevelItemType.alignCenter:
        {
          List<Widget> list = [];
          for (var subItem in item.items) {
            list.add(_genLevelItem(subItem));
          }
          return Padding(
              padding: EdgeInsets.all(3.0),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Wrap(alignment: WrapAlignment.start, children: list)));
        }
      /*case MbclLevelItemType.itemize:
        {
          List<ListTile> listTiles = [];
          for (var item in item.items) {
            listTiles.add(ListTile(
              enabled: true,
              leading: Icon(Icons.map),
              title: Text('TODO'),
            ));
          }
          // TODO: list-view is not what we want... use two cols instead??
          return Flexible(
            fit: FlexFit.loose,
            child: ListView(
              //physics: const NeverScrollableScrollPhysics(),
              children: listTiles,
            ),
          );
        }*/
      default:
        print(
            "ERROR: genLevelItem(..): type '${item.type.name}' is not implemented");
        return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Text(
      "No course was selected!!!",
      style: Theme.of(context).textTheme.headlineLarge,
    );

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
      var listTiles = <Widget>[];
      for (var course in courses) {
        listTiles.add(ListTile(
          enabled: true,
          leading: Icon(Icons.fiber_manual_record),
          title: Text(course),
          onTap: () {
            _selectCourse(course);
          },
        ));
      }
      body = ListView(children: listTiles);
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
        page.add(_genLevelItem(item));
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(/*widget.title*/ ""),
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/img/logoSmall.png"),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _level = null;
              setState(() {});
            },
            icon: Icon(Icons.home),
          )
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //_selectCourse();
        },
        tooltip: 'load course',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

  InlineSpan _genParagraphItem(MbclLevelItem item,
      {bold = false, italic = false, color = Colors.black}) {
    double fontSize = 16;
    switch (item.type) {
      case MbclLevelItemType.reference:
        {
          return TextSpan(
              text: "REFERENCES_NOT_YET_IMPLEMENTED",
              style: TextStyle(color: Colors.red));
        }
      case MbclLevelItemType.text:
        return TextSpan(
          text: "${item.text} ",
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal),
        );
      case MbclLevelItemType.boldText:
      case MbclLevelItemType.italicText:
      case MbclLevelItemType.color:
        {
          List<InlineSpan> gen = [];
          switch (item.type) {
            case MbclLevelItemType.boldText:
              {
                for (var it in item.items) {
                  gen.add(_genParagraphItem(it, bold: true));
                }
                return TextSpan(children: gen);
              }
            case MbclLevelItemType.italicText:
              {
                for (var it in item.items) {
                  gen.add(_genParagraphItem(it, italic: true));
                }
                return TextSpan(
                  children: gen,
                );
              }
            case MbclLevelItemType.color:
              {
                var colorKey = int.parse(item.id);
                var colors = [
                  // TODO
                  Colors.black,
                  Colors.red,
                  Colors.blue,
                  Colors.purple,
                  Colors.orange
                ];
                var color = colors[colorKey % colors.length];
                for (var it in item.items) {
                  gen.add(_genParagraphItem(it, color: color));
                }
                return TextSpan(children: gen);
              }
            default:
              // this will never happen
              return TextSpan();
          }
        }
      case MbclLevelItemType.inlineMath:
        {
          var tex = TeX();
          var texSrc = '';
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
          tex.scalingFactor = 1.17;
          var svg = tex.tex2svg(texSrc);
          var svgWidth = tex.width;
          if (svg.isEmpty) {
            return TextSpan(
              text: "${tex.error} ",
              style: TextStyle(color: Colors.red, fontSize: fontSize),
            );
          } else {
            return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SvgPicture.string(
                  svg,
                  width: svgWidth.toDouble(),
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
      case MbclLevelItemType.equation:
        {
          var texSrc = item.text;
          Widget equationWidget = Text('');
          var tex = TeX();
          tex.scalingFactor = 1.1;
          var svg = tex.tex2svg(texSrc);
          var svgWidth = tex.width;
          if (svg.isEmpty) {
            equationWidget = Text(tex.error);
          } else {
            var eqNumber = int.parse(item.id);
            var eqNumberWidget = Text(eqNumber >= 0 ? '($eqNumber)' : '');
            equationWidget = Row(
              children: [
                Expanded(
                    child: SvgPicture.string(svg, width: svgWidth.toDouble())),
                Column(children: [eqNumberWidget]),
              ],
            );
          }
          return Padding(
              padding: EdgeInsets.all(3.0),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Wrap(
                      alignment: WrapAlignment.start,
                      children: [equationWidget])));
        }
      case MbclLevelItemType.span:
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
      case MbclLevelItemType.itemize:
      case MbclLevelItemType.enumerate:
      case MbclLevelItemType.enumerateAlpha:
        {
          List<Row> rows = [];
          for (var i = 0; i < item.items.length; i++) {
            var subItem = item.items[i];
            Widget w = Icon(
              Icons.fiber_manual_record,
              size: 8,
            );
            if (item.type == MbclLevelItemType.enumerate) {
              w = Text("${i + 1}.");
            } else if (item.type == MbclLevelItemType.enumerateAlpha) {
              w = Text("${String.fromCharCode("a".codeUnitAt(0) + i)})");
            }
            var label = Column(children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 3.0, top: 0.0, bottom: 0.0),
                  child: w)
            ]);
            var row = Row(children: [
              label,
              Column(children: [_genLevelItem(subItem)])
            ]);
            rows.add(row);
          }
          return Column(children: rows);
        }
      case MbclLevelItemType.newPage:
        {
          return Text(
            '\n--- page break will be here later ---\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
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

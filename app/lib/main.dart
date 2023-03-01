/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// TODO: remove all JavaScript dependencies, as soon as own TeX is ready
// the following imports "dart:js" for the web app, or "flutter_js" for iOS/Android/...
//import 'package:flutter_js/flutter_js.dart' as js if (dart.library.io) "dart:js";

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

  //dynamic flutterJs;

  @override
  void initState() {
    super.initState();

    //if (dart.library.io) {
    /*flutterJs = js.getJavascriptRuntime();
    var fjs = flutterJs as js.JavascriptRuntime;
    fjs.evaluate('console.log("hello, world from flutter_js.");');
    DefaultAssetBundle.of(context)
        .loadString("assets/mathjax.min.js")
        .then((value) {
      fjs.evaluate(value);
      fjs.evaluate("let mj = new tex.MathJax();");
      fjs.evaluate("console.log(mj.tex2svgInline('x^2'));");
    });*/
    /*}
    if (dart.library.js) {
      // TODO: browser
    }*/
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
          // width="2.403ex" height="1.464ex"
          var testSvgData =
              """<svg style="" xmlns="http://www.w3.org/2000/svg" role="img" focusable="false" viewBox="0 -800 2000 900"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    <defs>
        <path id="MJX-1-TEX-I-1D465"
            d="M52 289Q59 331 106 386T222 442Q257 442 286 424T329 379Q371 442 430 442Q467 442 494 420T522 361Q522 332 508 314T481 292T458 288Q439 288 427 299T415 328Q415 374 465 391Q454 404 425 404Q412 404 406 402Q368 386 350 336Q290 115 290 78Q290 50 306 38T341 26Q378 26 414 59T463 140Q466 150 469 151T485 153H489Q504 153 504 145Q504 144 502 134Q486 77 440 33T333 -11Q263 -11 227 52Q186 -10 133 -10H127Q78 -10 57 16T35 71Q35 103 54 123T99 143Q142 143 142 101Q142 81 130 66T107 46T94 41L91 40Q91 39 97 36T113 29T132 26Q168 26 194 71Q203 87 217 139T245 247T261 313Q266 340 266 352Q266 380 251 392T217 404Q177 404 142 372T93 290Q91 281 88 280T72 278H58Q52 284 52 289Z"></path>
        <path id="MJX-1-TEX-I-1D466"
            d="M208 74Q208 50 254 46Q272 46 272 35Q272 34 270 22Q267 8 264 4T251 0Q249 0 239 0T205 1T141 2Q70 2 50 0H42Q35 7 35 11Q37 38 48 46H62Q132 49 164 96Q170 102 345 401T523 704Q530 716 547 716H555H572Q578 707 578 706L606 383Q634 60 636 57Q641 46 701 46Q726 46 726 36Q726 34 723 22Q720 7 718 4T704 0Q701 0 690 0T651 1T578 2Q484 2 455 0H443Q437 6 437 9T439 27Q443 40 445 43L449 46H469Q523 49 533 63L521 213H283L249 155Q208 86 208 74ZM516 260Q516 271 504 416T490 562L463 519Q447 492 400 412L310 260L413 259Q516 259 516 260Z"></path>
    </defs>
    <g stroke="currentColor" fill="currentColor" stroke-width="0" transform="scale(1,-1)">
        <g data-mml-node="math">
            <g data-mml-node="mi">
                <use data-c="1D465" xlink:href="#MJX-1-TEX-I-1D465"></use>
            </g>
            <g data-mml-node="mi" transform="translate(500,0)">
                <use data-c="1D466" xlink:href="#MJX-1-TEX-I-1D466"></use>
            </g>
        </g>
    </g>
</svg>""";
          return WidgetSpan(
              child: SvgPicture.string(
            testSvgData,
            height: 20,
          ));
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
          // TODO: listview is not what we want... use two cols instead??
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

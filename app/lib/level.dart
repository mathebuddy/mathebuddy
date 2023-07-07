/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the level widget.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/event.dart';

import 'keyboard.dart';
import 'color.dart';
import 'appbar.dart';
import 'main.dart';
import 'screen.dart';

import 'level_align.dart';
import 'level_example.dart';
import 'level_exercise.dart';
import 'level_itemize.dart';
import 'level_definition.dart';
import 'level_figure.dart';
import 'level_single_multi_choice.dart';
import 'level_table.dart';
import 'level_equation.dart';
import 'level_paragraph.dart';
import 'level_paragraph_item.dart';
import 'level_todo.dart';

class LevelWidget extends StatefulWidget {
  final MbclLevel level;

  const LevelWidget(this.level, {Key? key}) : super(key: key);

  @override
  State<LevelWidget> createState() => LevelState();
}

class LevelState extends State<LevelWidget> {
  MbclLevelItem? activeExercise;
  KeyboardState keyboardState = KeyboardState();
  int currentPart = 0;
  GlobalKey? levelTitleKey;

  @override
  void initState() {
    super.initState();
    // TODO: keyboard for deskto app
    //import 'package:flutter/services.dart';
    //ServicesBinding.instance.keyboard.addHandler(onKey);
  }

  bool onKey(KeyEvent event) {
    // TODO: connect to app keyboard
    print(event);
    print(event.character);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    scrollController = ScrollController();

    var level = widget.level;
    level.calcProgress();
    List<Widget> levelHeadItems = [];
    List<Widget> page = [];
    // title
    levelTitleKey = GlobalKey();
    var levelTitle = Column(children: [
      Container(
        key: levelTitleKey,
        margin: EdgeInsets.only(top: 10.0),
        child: Text(
          level.title,
          style: TextStyle(
              fontSize: 24, color: matheBuddyRed, fontWeight: FontWeight.w600),
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
              currentPart = i;
              keyboardState.layout = null;
              setState(() {});
            },
            child: Icon(MdiIcons.fromString(iconId),
                size: iconSize,
                color: currentPart == i ? selectedColor : unselectedColor));
        icons.add(Padding(
            padding: EdgeInsets.only(left: 2.0, right: 2.0), child: icon));
      }
      // panel
      // TODO: animate progress controller
      var progress = level.progress;
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
          // skip items that do not belong to current part
          if (level.numParts > 0 && part != currentPart) {
            continue;
          }
          // skip exercises that contain unfulfilled requirements
          var skip = false;
          if (!debugMode && item.type == MbclLevelItemType.exercise) {
            var data = item.exerciseData!;
            for (var reqEx in data.requiredExercises) {
              var reqExData = reqEx.exerciseData!;
              if (reqExData.feedback != MbclExerciseFeedback.correct) {
                skip = true;
                break;
              }
            }
          }
          if (skip) {
            continue;
          }
          // generate item and add it to level
          page.add(generateLevelItem(this, level, item));
        }
      }
    }

    // bottom navigation bar
    var bottomNavBarIconSize = 32.0;
    var bottomNavBarIconColor = Colors.black.withOpacity(0.75);
    List<Widget> buttons = [];
    // left
    if (level.numParts > 0 && currentPart > 0) {
      buttons.add(GestureDetector(
          onTapDown: (TapDownDetails d) {
            currentPart--;
            keyboardState.layout = null;
            setState(() {});
            Scrollable.ensureVisible(levelTitleKey!.currentContext!);
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
    // right
    if (level.numParts > 0) {
      if (currentPart < level.numParts - 1) {
        buttons.add(Text('  '));
        buttons.add(GestureDetector(
            onTapDown: (TapDownDetails d) {
              currentPart++;
              keyboardState.layout = null;
              setState(() {});
              Scrollable.ensureVisible(levelTitleKey!.currentContext!);
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
              Navigator.pop(context);
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons))
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

    var body = Column(children: [
      Column(children: levelHeadItems),
      Expanded(
          child: Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: scrollView!))
    ]);

    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      var keyboard = Keyboard();
      bottomArea = keyboard.generateWidget(this, keyboardState);
    }

    return Scaffold(
      appBar: buildAppBar(this, false),
      body: body,
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}

// =====================================================

// TODO: migrate the following into class above

Widget generateLevelItem(LevelState state, MbclLevel level, MbclLevelItem item,
    {paragraphPaddingLeft = 3.0,
    paragraphPaddingRight = 3.0,
    paragraphPaddingTop = 10.0,
    paragraphPaddingBottom = 5.0,
    MbclExerciseData? exerciseData}) {
  if (item.error.isNotEmpty) {
    var title = item.title;
    if (title.isEmpty) {
      title = "(no title)";
    }
    return generateErrorWidget(
        'ERROR in element "$title" in/near source line ${item.srcLine + 1}:\n'
        '${item.error}');
  }
  switch (item.type) {
    case MbclLevelItemType.error:
      {
        return Padding(
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
            child: Text(
              item.text,
              style: TextStyle(fontSize: 14, color: Colors.red),
            ));
      }
    case MbclLevelItemType.section:
      {
        return Padding(
            //padding: EdgeInsets.all(3.0),
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
            child: Text(item.text,
                style: Theme.of(state.context).textTheme.headlineLarge));
      }
    case MbclLevelItemType.subSection:
      {
        return Padding(
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
            child: Text(item.text,
                style: Theme.of(state.context).textTheme.headlineMedium));
      }
    case MbclLevelItemType.span:
      {
        List<InlineSpan> list = [];
        for (var subItem in item.items) {
          list.add(generateParagraphItem(state, subItem,
              exerciseData: exerciseData));
        }
        var richText = RichText(
          text: TextSpan(children: list),
        );
        return richText;
      }
    case MbclLevelItemType.paragraph:
      {
        return generateParagraph(state, level, item,
            exerciseData: exerciseData,
            paragraphPaddingLeft: paragraphPaddingLeft,
            paragraphPaddingRight: paragraphPaddingRight,
            paragraphPaddingTop: paragraphPaddingTop,
            paragraphPaddingBottom: paragraphPaddingBottom);
      }
    case MbclLevelItemType.alignCenter:
      {
        return generateAlign(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.equation:
      {
        return generateEquation(state, level, item, exerciseData: exerciseData);
      }

    case MbclLevelItemType.itemize:
    case MbclLevelItemType.enumerate:
    case MbclLevelItemType.enumerateAlpha:
      {
        return generateItemize(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.example:
      {
        return generateExample(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.defDefinition:
    case MbclLevelItemType.defTheorem:
      {
        return generateDefinition(state, level, item,
            exerciseData: exerciseData);
      }
    case MbclLevelItemType.figure:
      {
        return generateFigure(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.table:
      {
        return generateTable(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.todo:
      {
        return generateTodo(state, level, item, exerciseData: exerciseData);
      }
    case MbclLevelItemType.exercise:
      {
        return generateExercise(state, level, item);
      }
    case MbclLevelItemType.multipleChoice:
    case MbclLevelItemType.singleChoice:
      {
        return generateSingleMultiChoice(state, level, item,
            exerciseData: exerciseData);
      }
    default:
      {
        print(
            "ERROR: genLevelItem(..): type '${item.type.name}' is not implemented");
        return Text(
          "\n--- ERROR: genLevelItem(..): type '${item.type.name}' is not implemented ---\n",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        );
      }
  }
}

Widget generateErrorWidget(String errorText) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          padding: EdgeInsets.all(5),
          child: Text(errorText,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        )
      ]);
}

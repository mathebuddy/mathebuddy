/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math';

import 'package:tex/tex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/paragraph.dart';

Widget generateLevelItem(CoursePageState state, MbclLevelItem item,
    {paragraphPaddingLeft = 3.0,
    paragraphPaddingRight = 3.0,
    paragraphPaddingTop = 10.0,
    paragraphPaddingBottom = 5.0,
    MbclExerciseData? exerciseData}) {
  switch (item.type) {
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
    case MbclLevelItemType.paragraph:
      {
        List<InlineSpan> list = [];
        for (var subItem in item.items) {
          list.add(generateParagraphItem(state, subItem,
              exerciseData: exerciseData));
        }
        var richText = RichText(
          text: TextSpan(children: list),
        );
        return Padding(
          padding: EdgeInsets.only(
              left: paragraphPaddingLeft,
              right: paragraphPaddingRight,
              top: paragraphPaddingTop,
              bottom: paragraphPaddingBottom),
          child: richText,
        );
      }
    case MbclLevelItemType.alignCenter:
      {
        List<Widget> list = [];
        for (var subItem in item.items) {
          list.add(
              generateLevelItem(state, subItem, exerciseData: exerciseData));
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
          list.add(generateParagraphItem(state, subItem,
              exerciseData: exerciseData));
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
            Column(children: [
              generateLevelItem(state, subItem, exerciseData: exerciseData)
            ])
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
    case MbclLevelItemType.defDefinition:
    case MbclLevelItemType.defTheorem:
      {
        var prefix = '';
        switch (item.type) {
          case MbclLevelItemType.defDefinition:
            prefix = 'Definition';
            break;
          case MbclLevelItemType.defTheorem:
            prefix = 'Theorem';
            break;
          default:
            prefix = 'UNIMPLEMENTED';
            break;
        }
        List<Widget> list = [];
        var title = Row(children: [
          Padding(
              padding: EdgeInsets.all(3.0),
              child: Text('$prefix (${item.title})',
                  style: TextStyle(fontWeight: FontWeight.bold)))
        ]);
        list.add(title);
        for (var i = 0; i < item.items.length; i++) {
          var subItem = item.items[i];
          list.add(Wrap(children: [
            generateLevelItem(state, subItem,
                paragraphPaddingLeft: 20.0,
                paragraphPaddingTop: i == 0 ? 0.0 : 10.0,
                exerciseData: exerciseData)
          ]));
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: list);
      }
    case MbclLevelItemType.exercise:
      {
        var exerciseData = item.exerciseData as MbclExerciseData;
        if (item.error.isNotEmpty) {
          // TODO: check, if item.error is catched everywhere!!!!
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(item.error, style: TextStyle(color: Colors.red))
              ]);
        }
        if (exerciseData.runInstanceIdx < 0) {
          exerciseData.runInstanceIdx =
              Random().nextInt(exerciseData.instances.length);
        }
        List<Widget> list = [];
        var title = Wrap(children: [
          Container(
              child: Row(children: [
            Text(' '), // TODO: use padding instead of Text(' ')
            Icon(Icons.play_circle_outlined),
            Text(' '),
            // TODO: wrap does not work:
            Text(item.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]))
        ]);
        list.add(title);
        for (var i = 0; i < item.items.length; i++) {
          var subItem = item.items[i];
          list.add(Wrap(children: [
            generateLevelItem(state, subItem,
                paragraphPaddingLeft: 10.0,
                paragraphPaddingTop: i == 0 ? 5.0 : 10.0,
                exerciseData: item.exerciseData)
          ]));
        }

        var feedbackColor = matheBuddyRed;
        Widget feedbackText = Text('');
        switch (exerciseData.feedback) {
          case MbclExerciseFeedback.unchecked:
            feedbackText =
                Text('?', style: TextStyle(color: matheBuddyRed, fontSize: 20));
            break;
          case MbclExerciseFeedback.correct:
            feedbackColor = Colors.green.shade700;
            feedbackText = Icon(Icons.check, color: feedbackColor, size: 24);
            break;
          case MbclExerciseFeedback.incorrect:
            feedbackColor = matheBuddyRed;
            feedbackText = Icon(Icons.clear, color: feedbackColor, size: 24);
            break;
        }

        list.add(GestureDetector(
            onTap: () {
              // check exercise: TODO must implement in e.g. new file exercise.dart
              var allCorrect = true;
              for (var inputFieldId in exerciseData.inputFields.keys) {
                var inputField = exerciseData.inputFields[inputFieldId]
                    as MbclInputFieldData;
                // TODO: must use math-runtime for checks!
                if (inputField.studentValue == inputField.expectedValue) {
                  print("answer OK");
                } else {
                  allCorrect = false;
                  print("answer wrong");
                }
              }
              if (allCorrect) {
                print("... all answers are correct!");
                exerciseData.feedback = MbclExerciseFeedback.correct;
              } else {
                print("... at least one answer is incorrect!");
                exerciseData.feedback = MbclExerciseFeedback.incorrect;
              }
              // ignore: invalid_use_of_protected_member
              state.setState(() {});
            },
            child: Center(
                child: Container(
                    margin: EdgeInsets.only(left: 20, top: 10, right: 20),
                    child: Container(
                      width: 75, //double.infinity,
                      //padding: EdgeInsets.only(left: 15, right: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2.5,
                              color: feedbackColor,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Center(child: feedbackText),
                    )))));
        return Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: list));
      }
    case MbclLevelItemType.multipleChoice:
      {
        List<Widget> mcOptions = [];
        for (var i = 0; i < item.items.length; i++) {
          var inputField = item.items[i];
          var inputFieldData = inputField.inputFieldData as MbclInputFieldData;
          if (exerciseData != null &&
              exerciseData.inputFields.containsKey(inputField.id) == false) {
            exerciseData.inputFields[inputField.id] = inputFieldData;
            inputFieldData.studentValue = "false";
            var exerciseInstance =
                exerciseData.instances[exerciseData.runInstanceIdx];
            inputFieldData.expectedValue =
                exerciseInstance[inputFieldData.variableId] as String;
          }
          // 57688 := Icons.check_box_outline_blank
          // 61254 := Icons.check_box_outlined
          var icon = Icon(
            IconData(inputFieldData.studentValue == "false" ? 57688 : 61254,
                fontFamily: 'MaterialIcons'),
            color: matheBuddyRed,
            size: 36,
          );
          var button = Column(children: [
            Padding(
                padding: EdgeInsets.only(
                    left: 8.0, right: 2.0, top: 0.0, bottom: .0),
                child: icon),
          ]);
          var text = generateLevelItem(state, inputField.items[0],
              exerciseData: exerciseData);
          mcOptions.add(GestureDetector(
              onTap: () {
                if (inputFieldData.studentValue == "true") {
                  inputFieldData.studentValue = "false";
                } else {
                  inputFieldData.studentValue = "true";
                }
                // ignore: invalid_use_of_protected_member
                state.setState(() {});
              },
              child: Row(children: [button, text])));
        }
        return Column(children: mcOptions);
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

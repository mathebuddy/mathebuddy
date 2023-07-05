/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'main.dart';

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

Widget generateLevelItem(
    CoursePageState state, MbclLevel level, MbclLevelItem item,
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
        return generateTable(state, level, item, exerciseData: exerciseData);
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

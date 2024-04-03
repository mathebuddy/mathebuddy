/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:mathebuddy/error.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';

import 'package:mathebuddy/level_align.dart';
import 'package:mathebuddy/level_example.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/level_itemize.dart';
import 'package:mathebuddy/level_definition.dart';
import 'package:mathebuddy/level_figure.dart';
import 'package:mathebuddy/level_single_multi_choice.dart';
import 'package:mathebuddy/level_table.dart';
import 'package:mathebuddy/level_equation.dart';
import 'package:mathebuddy/level_paragraph.dart';
import 'package:mathebuddy/level_todo.dart';
import 'package:mathebuddy/style.dart';

Widget generateLevelItem(State state, MbclLevel level, MbclLevelItem item,
    {paragraphPaddingLeft = 3.0,
    paragraphPaddingRight = 3.0,
    paragraphPaddingTop = 5.0,
    paragraphPaddingBottom = 5.0,
    textColor = Colors.black,
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
    case MbclLevelItemType.debugInfo:
      {
        return Opacity(
            opacity: 0.8,
            child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Text("\n${item.text}\n",
                            style: TextStyle(color: Colors.white))))));
      }
    case MbclLevelItemType.section:
      {
        return Padding(
            //padding: EdgeInsets.all(3.0),
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
            child: Text(item.text,
                style: TextStyle(
                    color: getStyle().sectionColor,
                    fontSize: getStyle().sectionFontSize,
                    fontWeight: getStyle().sectionFontWidth)));
      }
    case MbclLevelItemType.subSection:
      {
        return Padding(
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0, bottom: 5.0),
            child: Text(item.text,
                style: TextStyle(
                    color: getStyle().subSectionColor,
                    fontSize: getStyle().subSectionFontSize,
                    fontWeight: getStyle().subSectionFontWidth)));
      }
    case MbclLevelItemType.span:
      {
        List<InlineSpan> list = [];
        var languageIndex = language == "de" ? 0 : 1; // TODO
        for (var subItem in filterLanguage2(item.items, languageIndex)) {
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
            paragraphPaddingBottom: paragraphPaddingBottom,
            textColor: textColor);
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
    case MbclLevelItemType.defProof:
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
        if (debugMode) {
          return generateTodo(state, level, item, exerciseData: exerciseData);
        } else {
          return Text("");
        }
      }
    case MbclLevelItemType.exercise:
      {
        return generateExercise(state, level, item, borderWidth: 3.0);
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

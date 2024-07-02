/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';
import 'package:mathebuddy/level_paragraph_input.dart';
import 'package:mathebuddy/level_paragraph_math.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

Widget generateParagraph(State state, MbclLevel level, MbclLevelItem item,
    {paragraphPaddingLeft = 3.0,
    paragraphPaddingRight = 3.0,
    paragraphPaddingTop = 5.0,
    paragraphPaddingBottom = 5.0,
    textColor = Colors.black,
    MbclExerciseData? exerciseData}) {
  List<InlineSpan> list = [];
  var languageIndex = language == "de" ? 0 : 1; // TODO
  for (var subItem in filterLanguage2(item.items, languageIndex)) {
    list.add(generateParagraphItem(state, subItem,
        exerciseData: exerciseData, color: textColor));
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

InlineSpan generateParagraphItem(State state, MbclLevelItem item,
    {bold = false,
    italic = false,
    color = Colors.black,
    MbclExerciseData? exerciseData}) {
  var screenWidth = MediaQuery.of(state.context).size.width;
  if (screenWidth > maxContentsWidth) screenWidth = maxContentsWidth;
  var textHeight = screenWidth < 480 ? 1.5 : 1.6;
  switch (item.type) {
    case MbclLevelItemType.reference:
      {
        var text = TextSpan(
            text: item.text, //
            style: TextStyle(
              color: getStyle().matheBuddyGreen,
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
            ));
        if (item.error.isNotEmpty) {
          text = TextSpan(
              text: item.error, //
              style: TextStyle(color: Colors.red));
        }
        return text;
      }
    case MbclLevelItemType.text:
      return TextSpan(
        text: "${item.text} ",
        style: TextStyle(
            color: color,
            height: textHeight,
            fontSize: defaultFontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal),
      );
    case MbclLevelItemType.inlineCode:
      return TextSpan(
        text: "${item.text} ",
        style: TextStyle(
            color: color,
            height: textHeight,
            fontFamily: 'RobotoMono',
            fontSize: defaultFontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal),
      );
    case MbclLevelItemType.color:
      {
        List<InlineSpan> gen = [];
        var colorKey = int.parse(item.id);
        var colors = [
          // TODO
          Colors.black,
          getStyle().matheBuddyRed,
          getStyle().matheBuddyYellow,
          getStyle().matheBuddyGreen,
          Colors.orange
        ];
        var color = colors[colorKey % colors.length];
        for (var it in item.items) {
          gen.add(generateParagraphItem(state, it,
              color: color, exerciseData: exerciseData));
        }
        return TextSpan(children: gen);
      }
    case MbclLevelItemType.boldText:
    case MbclLevelItemType.italicText:
      {
        List<InlineSpan> gen = [];
        switch (item.type) {
          case MbclLevelItemType.boldText:
            {
              for (var it in item.items) {
                gen.add(generateParagraphItem(state, it,
                    bold: true, color: color, exerciseData: exerciseData));
              }
              return TextSpan(children: gen);
            }
          case MbclLevelItemType.italicText:
            {
              for (var it in item.items) {
                gen.add(generateParagraphItem(state, it,
                    italic: true, color: color, exerciseData: exerciseData));
              }
              return TextSpan(
                children: gen,
              );
            }
          default:
            // this will never happen
            return TextSpan();
        }
      }
    case MbclLevelItemType.inlineMath:
    case MbclLevelItemType.displayMath:
      {
        return generateParagraphItemMath(state, item,
            bold: bold,
            italic: italic,
            color: color,
            exerciseData: exerciseData);
      }
    case MbclLevelItemType.inputField:
      {
        var generate =
            exerciseData != null ? exerciseData.generateInputFields : true;
        if (generate) {
          AppInputField f = AppInputField();
          InlineSpan inputField = f.generateParagraphItemInputField(state, item,
              bold: bold,
              italic: italic,
              color: color,
              exerciseData: exerciseData);
          return inputField;
        } else {
          return TextSpan(text: "");
        }
      }
    default:
      {
        print(
            "ERROR: genParagraphItem(..): type '${item.type.name}' is not implemented");
        return TextSpan(
            text: "ERROR: genParagraphItem(..): "
                "type '${item.type.name}' is not implemented",
            style: TextStyle(color: Colors.red));
      }
  }
}

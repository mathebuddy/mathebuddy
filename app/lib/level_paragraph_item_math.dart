/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:tex/tex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';

import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/level.dart';

InlineSpan generateParagraphItemMath(LevelState state, MbclLevelItem item,
    {bold = false,
    italic = false,
    color = Colors.black,
    MbclExerciseData? exerciseData}) {
  var texSrc = '';
  for (var subItem in item.items) {
    switch (subItem.type) {
      case MbclLevelItemType.text:
        {
          texSrc += subItem.text;
          break;
        }
      case MbclLevelItemType.variableReferenceOperand:
      case MbclLevelItemType.variableReferenceTerm:
      case MbclLevelItemType.variableReferenceOptimizedTerm:
        {
          var variableId = subItem.id;
          if (exerciseData == null) {
            texSrc += 'ERROR: not in exercise mode!';
          } else {
            var key = "$variableId.tex";
            switch (subItem.type) {
              case MbclLevelItemType.variableReferenceTerm:
                key = "@$key";
                break;
              case MbclLevelItemType.variableReferenceOptimizedTerm:
                key = "@@$key";
                break;
              default:
            }
            var variableTeXValue = exerciseData.activeInstance[key];
            if (variableTeXValue == null) {
              texSrc += 'ERROR: unknown exercise variable $variableId';
            } else {
              texSrc += variableTeXValue /*+ key.replaceAll(".tex", "")*/;
            }
          }
          break;
        }
      default:
        print(
            "ERROR: genParagraphItem(..): type '${item.type.name}' is not finally implemented");
    }
  }
  var tex = TeX();
  tex.setColor(color.red, color.green, color.blue);
  tex.scalingFactor = 1.08; //1.17;
  //print("... tex src: $texSrc");
  var svg = tex.tex2svg(texSrc,
      displayStyle: item.type == MbclLevelItemType.displayMath,
      deltaYOffset: -110);
  var svgWidth = tex.width;
  if (tex.success() == false) {
    return TextSpan(
      text: tex.error,
      style: TextStyle(color: Colors.red, fontSize: defaultFontSize),
    );
  } else {
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
            //decoration:
            //    BoxDecoration(border: Border.all(color: Colors.red)),
            padding: EdgeInsets.only(right: 4.0),
            child: SvgPicture.string(
              svg,
              width: svgWidth.toDouble(),
              allowDrawingOutsideViewBox: true,
              //height: 25.0,
            )));
  }
}

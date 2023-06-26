/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:mathebuddy/keyboard_layouts.dart';
import 'package:tex/tex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/help.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/screen.dart';

const double defaultFontSize = 16;

InlineSpan generateParagraphItem(CoursePageState state, MbclLevelItem item,
    {bold = false,
    italic = false,
    color = Colors.black,
    MbclExerciseData? exerciseData}) {
  switch (item.type) {
    case MbclLevelItemType.reference:
      {
        var text = TextSpan(
            text: item.text, //
            style: TextStyle(
              color: matheBuddyGreen,
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
            height: 1.6, //1.6,
            //overflow: TextOverflow.fade,
            //letterSpacing: 0.1,
            //wordSpacing: 0.0,
            fontSize: defaultFontSize,
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
                gen.add(generateParagraphItem(state, it,
                    bold: true, exerciseData: exerciseData));
              }
              return TextSpan(children: gen);
            }
          case MbclLevelItemType.italicText:
            {
              for (var it in item.items) {
                gen.add(generateParagraphItem(state, it,
                    italic: true, exerciseData: exerciseData));
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
                matheBuddyRed,
                matheBuddyYellow,
                matheBuddyGreen,
                Colors.orange
              ];
              var color = colors[colorKey % colors.length];
              for (var it in item.items) {
                gen.add(generateParagraphItem(state, it,
                    color: color, exerciseData: exerciseData));
              }
              return TextSpan(children: gen);
            }
          default:
            // this will never happen
            return TextSpan();
        }
      }
    case MbclLevelItemType.inlineMath:
    case MbclLevelItemType.displayMath:
      {
        var texSrc = '';
        for (var subItem in item.items) {
          switch (subItem.type) {
            case MbclLevelItemType.text:
              {
                texSrc += subItem.text;
                break;
              }
            case MbclLevelItemType.variableReference:
              {
                var variableId = subItem.id;
                if (exerciseData == null) {
                  texSrc += 'ERROR: not in exercise mode!';
                } else {
                  var instance =
                      exerciseData.instances[exerciseData.runInstanceIdx];
                  var variableTeXValue = instance["$variableId.tex"];
                  if (variableTeXValue == null) {
                    texSrc += 'ERROR: unknown exercise variable $variableId';
                  } else {
                    //texSrc += convertMath2TeX(variableTeXValue);
                    texSrc += variableTeXValue;
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
        tex.scalingFactor = 1.08; //1.17;
        //print("... tex src: $texSrc");
        var svg = tex.tex2svg(texSrc,
            displayStyle: item.type == MbclLevelItemType.displayMath,
            deltaYOffset: -110);
        var svgWidth = tex.width;
        if (svg.isEmpty) {
          return TextSpan(
            text: "${tex.error}. TEX-INPUT: $texSrc",
            style: TextStyle(color: Colors.red, fontSize: defaultFontSize),
          );
        } else {
          //var viewBoxValues = "0 -795 3754 1591";
//           var viewBoxValues = "0 0 3804 700";
//           svg = '''
// <svg width="75" height="32" xmlns="http://www.w3.org/2000/svg" role="img" focusable="false" viewBox="$viewBoxValues" xmlns:xlink="http://www.w3.org/1999/xlink">
//   <defs>
//     <path id="TEX-I-1D466" d="M21 287Q21 301 36 335T84 406T158 442Q199 442 224 419T250 355Q248 336 247 334Q247 331 231 288T198 191T182 105Q182 62 196 45T238 27Q261 27 281 38T312 61T339 94Q339 95 344 114T358 173T377 247Q415 397 419 404Q432 431 462 431Q475 431 483 424T494 412T496 403Q496 390 447 193T391 -23Q363 -106 294 -155T156 -205Q111 -205 77 -183T43 -117Q43 -95 50 -80T69 -58T89 -48T106 -45Q150 -45 150 -87Q150 -107 138 -122T115 -142T102 -147L99 -148Q101 -153 118 -160T152 -167H160Q177 -167 186 -165Q219 -156 247 -127T290 -65T313 -9T321 21L315 17Q309 13 296 6T270 -6Q250 -11 231 -11Q185 -11 150 11T104 82Q103 89 103 113Q103 170 138 262T173 379Q173 380 173 381Q173 390 173 393T169 400T158 404H154Q131 404 112 385T82 344T65 302T57 280Q55 278 41 278H27Q21 284 21 287Z"></path>
//     <path id="TEX-N-32" d="M109 429Q82 429 66 447T50 491Q50 562 103 614T235 666Q326 666 387 610T449 465Q449 422 429 383T381 315T301 241Q265 210 201 149L142 93L218 92Q375 92 385 97Q392 99 409 186V189H449V186Q448 183 436 95T421 3V0H50V19V31Q50 38 56 46T86 81Q115 113 136 137Q145 147 170 174T204 211T233 244T261 278T284 308T305 340T320 369T333 401T340 431T343 464Q343 527 309 573T212 619Q179 619 154 602T119 569T109 550Q109 549 114 549Q132 549 151 535T170 489Q170 464 154 447T109 429Z"></path>
//     <path id="TEX-N-3D" d="M56 347Q56 360 70 367H707Q722 359 722 347Q722 336 708 328L390 327H72Q56 332 56 347ZM56 153Q56 168 72 173H708Q722 163 722 153Q722 140 707 133H70Q56 140 56 153Z"></path>
//     <path id="TEX-N-2212" d="M84 237T84 250T98 270H679Q694 262 694 250T679 230H98Q84 237 84 250Z"></path>
//     <path id="TEX-N-31" d="M213 578L200 573Q186 568 160 563T102 556H83V602H102Q149 604 189 617T245 641T273 663Q275 666 285 666Q294 666 302 660V361L303 61Q310 54 315 52T339 48T401 46H427V0H416Q395 3 257 3Q121 3 100 0H88V46H114Q136 46 152 46T177 47T193 50T201 52T207 57T213 61V578Z"></path>
//   </defs>
//   <g transform="scale(1,-1)">
//     <g fill="rgb(0,0,0)" stroke-width="0" transform="translate(0.0,-650.0) scale(1.0000,1.0000)" data-token="y">
//       <use xlink:href="#TEX-I-1D466"></use>
//     </g>
//     <g fill="rgb(0,0,0)" stroke-width="0" transform="translate(500.0,165.0) scale(0.7071,0.7071)" data-token="2">
//       <use xlink:href="#TEX-N-32"></use>
//     </g>
//     <g fill="rgb(0,0,0)" stroke-width="0" transform="translate(1053.55,-210.0) scale(1.0000,1.0000)" data-token="=">
//       <use xlink:href="#TEX-N-3D"></use>
//     </g>
//     <g fill="rgb(0,0,0)" stroke-width="0" transform="translate(2253.55,-210.0) scale(1.0000,1.0000)" data-token="-">
//       <use xlink:href="#TEX-N-2212"></use>
//     </g>
//     <g fill="rgb(0,0,0)" stroke-width="0" transform="translate(3253.55,-210.0) scale(1.0000,1.0000)" data-token="1">
//       <use xlink:href="#TEX-N-31"></use>
//     </g>
//   </g>
// </svg>
// ''';
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
    case MbclLevelItemType.inputField:
      {
        var inputFieldData = item.inputFieldData as MbclInputFieldData;
        inputFieldData.exerciseData = exerciseData;
        if (exerciseData != null &&
            exerciseData.inputFields.containsKey(item.id) == false) {
          exerciseData.inputFields[item.id] = inputFieldData;
          inputFieldData.studentValue = "";
          var exerciseInstance =
              exerciseData.instances[exerciseData.runInstanceIdx];
          inputFieldData.expectedValue =
              exerciseInstance[inputFieldData.variableId] as String;
        }
        Widget contents;
        Color feedbackColor = getFeedbackColor(exerciseData?.feedback);
        var isActive = state.keyboardState.layout != null &&
            state.keyboardState.inputFieldData == inputFieldData;
        if (inputFieldData.studentValue.isEmpty) {
          contents = RichText(
              text: TextSpan(children: [
            WidgetSpan(
                child: Container(
                    decoration: BoxDecoration(
                        color: isActive
                            ? feedbackColor.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: Icon(
                      //Icons.settings_ethernet,
                      Icons.aspect_ratio,
                      size: 32,
                      color: feedbackColor,
                    ))),
          ]));
        } else {
          var tex = TeX();
          tex.scalingFactor = 1.33; //1.17;
          tex.setColor(
              feedbackColor.red, feedbackColor.green, feedbackColor.blue);

          List<InlineSpan> parts = [];

          var studentValue = inputFieldData.studentValue;
          var studentValueTeX = studentValue;
          try {
            studentValueTeX = convertMath2TeX(studentValue, true);
          } catch (e) {
            studentValueTeX =
                studentValueTeX.replaceAll("{", "\\{").replaceAll("}", "\\}");
          }
          var svgData = tex.tex2svg(studentValueTeX, displayStyle: true);
          if (tex.error.isEmpty) {
            parts.add(WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                    padding: isActive
                        ? EdgeInsets.only(left: 5, right: 5)
                        : EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: isActive
                            ? feedbackColor.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: SvgPicture.string(svgData,
                        width: tex.width.toDouble()))));
          } else {
            parts.add(TextSpan(
                text: tex.error,
                style:
                    TextStyle(color: Colors.red, fontSize: defaultFontSize)));
          }

          contents = RichText(text: TextSpan(children: parts));
        }
        var key = exerciseKey;
        return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
                onTap: () {
                  state.activeExercise = exerciseData?.exercise;
                  if (key != null) {
                    Scrollable.ensureVisible(key.currentContext!,
                        duration: Duration(milliseconds: 250));
                  }
                  /*if (state.keyboardState.layout != null) {
                    state.keyboardState.layout = null;
                  } else {*/
                  state.keyboardState.exerciseData = exerciseData;
                  state.keyboardState.inputFieldData = inputFieldData;
                  switch (inputFieldData.type) {
                    case MbclInputFieldType.int:
                      state.keyboardState.layout = keyboardLayoutInteger;
                      break;
                    case MbclInputFieldType.real:
                      state.keyboardState.layout = keyboardLayoutReal;
                      break;
                    case MbclInputFieldType.complexNormal:
                      state.keyboardState.layout =
                          keyboardLayoutComplexNormalForm;
                      break;
                    case MbclInputFieldType.intSet:
                      state.keyboardState.layout = keyboardLayoutIntegerSet;
                      break;
                    case MbclInputFieldType.complexIntSet:
                      state.keyboardState.layout =
                          keyboardLayoutComplexIntegerSet;
                      break;
                    /*case MbclInputFieldType.choices:
                      //inputFieldData.choices
                      break;*/
                    default:
                      print("WARNING: generateParagraphItem():"
                          "keyboard layout for input field type"
                          " ${inputFieldData.type.name} not yet implemented");
                      state.keyboardState.layout = keyboardLayoutTerm;
                  }
                  //}
                  // ignore: invalid_use_of_protected_member
                  state.setState(() {});
                },
                child: contents));
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

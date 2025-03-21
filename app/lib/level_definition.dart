/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';
import 'package:mathebuddy/level_item.dart';
import 'package:mathebuddy/main.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

Widget generateDefinition(State state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
// TODO: other MbclLevelItemType.def*
  // TODO: icon
  // var prefix = '';
  // switch (item.type) {
  //   case MbclLevelItemType.defDefinition:
  //     prefix = 'Definition';
  //     break;
  //   case MbclLevelItemType.defTheorem:
  //     prefix = 'Theorem';
  //     break;
  //   default:
  //     prefix = 'UNIMPLEMENTED';
  //     break;
  // }
  List<Widget> list = [];
  if (level.disableBlockTitles) {
    var titleText = "";
    switch (item.type) {
      case MbclLevelItemType.defProof:
        titleText = language == 'de' ? 'Beweis' : 'Proof';
        break;
      default:
        break;
    }
    var title = Wrap(children: [
      Padding(
          padding: EdgeInsets.only(left: 9.0, bottom: 5.0, top: 10.0),
          child: Row(children: [
            // TODO: wrap does not work:
            Flexible(
                child: Text(titleText,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
          ]))
    ]);
    list.add(title);
  } else {
    var languageIndex = language == "de" ? 0 : 1; // TODO
    var titleText = filterLanguage(item.title, languageIndex);
    var title = Wrap(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 5.0, top: 10.0),
          child: Row(children: [
            Text(' '), // TODO: use padding instead of Text(' ')
            Icon(Icons.lightbulb_outline, size: 35.0),
            Text(' '),
            // TODO: wrap does not work:
            Flexible(
                child: Text(titleText,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
          ]))
    ]);
    list.add(title);
  }

  for (var i = 0; i < item.items.length; i++) {
    var subItem = item.items[i];
    list.add(Wrap(children: [
      generateLevelItem(state, level, subItem,
          paragraphPaddingLeft: 10.0,
          paragraphPaddingTop: i == 0 ? 0.0 : 5.0,
          exerciseData: exerciseData)
    ]));
  }
  return Container(
      //color: Color.fromARGB(255, 255, 250, 234),
      //decoration: BoxDecoration(
      //    borderRadius: BorderRadius.circular(8.0),
      //    color: Color.fromARGB(31, 192, 192, 192)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: debugMode ? Border.all(width: 1.0) : null,
        //border: Border.all(width: 1.0, color: Colors.black26),
        //borderRadius: BorderRadius.circular(5),
        // boxShadow: [
        //   BoxShadow(
        //       color: Colors.grey.withOpacity(0.8),
        //       spreadRadius: 1,
        //       blurRadius: 2,
        //       offset: Offset(0, 1))
        // ]
      ),
      padding: EdgeInsets.only(bottom: 10.0, right: 5),
      margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: list));
}

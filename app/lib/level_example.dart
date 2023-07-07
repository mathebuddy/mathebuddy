/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

import 'level.dart';

Widget generateExample(LevelState state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  List<Widget> list = [];
  if (level.disableBlockTitles) {
    list.add(Text(' '));
  } else {
    var title = Wrap(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 5.0, top: 10.0),
          child: Row(children: [
            Text(' '), // TODO: use padding instead of Text(' ')
            Icon(
              Icons.gesture_outlined,
              size: 35.0,
            ),
            Text(' '),
            // TODO: wrap does not work:
            Flexible(
                child: Text(item.title,
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
          paragraphPaddingTop: i == 0 ? 0.0 : 10.0,
          exerciseData: exerciseData)
    ]));
  }
  return Container(
      //color: Color.fromARGB(31, 255, 221, 198),
      //decoration: BoxDecoration(
      //    borderRadius: BorderRadius.circular(8.0),
      //    color: Color.fromARGB(22, 128, 128, 128)),
      //padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3))
      ]),
      padding: EdgeInsets.only(bottom: 10.0),
      margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: list));
}

/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';
import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level.dart';

Widget generateTodo(State state, MbclLevel level, MbclLevelItem item,
    {MbclExerciseData? exerciseData}) {
  var opacity = 1.0;
  List<Widget> list = [];
  var title = Wrap(children: [
    Padding(
        padding: EdgeInsets.only(bottom: 5.0, top: 10.0),
        child: Row(children: [
          Text(' '),
          Icon(
            Icons.build,
            size: 50.0,
            color: Colors.white,
          ),
          Text(' '),
          Flexible(
              child: Text(item.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
        ]))
  ]);
  list.add(title);
  var text = "";
  try {
    text = item.items[0].items[0].text;
  } catch (e) {
    //
  }
  list.add(Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: RichText(
          text: TextSpan(style: TextStyle(fontSize: 20), text: text))));
  return Opacity(
      opacity: opacity,
      child: Container(
          decoration: BoxDecoration(color: Colors.red, boxShadow: [
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
              children: list)));
}

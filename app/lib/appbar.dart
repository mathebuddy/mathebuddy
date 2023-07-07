/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'main.dart';

AppBar buildAppBar(State state, bool graphButton) {
  List<Widget> actions = [];
  // home button
  actions.add(Text('  '));
  var actionHome = IconButton(
    onPressed: () {
      if (Navigator.canPop(state.context)) {
        Navigator.pop(state.context);
      }
    },
    icon: graphButton
        ? Icon(
            MdiIcons.fromString("graph-outline"),
            size: 36,
          )
        : Icon(Icons.home,
            size: 36,
            color: Navigator.canPop(state.context)
                ? Colors.black
                : Colors.black26),
  );
  actions.add(actionHome);
  actions.add(Text('    '));
  // debug/release button
  var switchDebugReleaseButton = Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(6)),
      child: Text(debugMode ? " DEBUG " : " RELEASE ",
          style: TextStyle(fontSize: 16)));
  return AppBar(
      centerTitle: true,
      title: showDebugReleaseSwitch
          ? GestureDetector(
              onTap: () {
                debugMode = !debugMode;
                state.setState(() {});
              },
              child: switchDebugReleaseButton)
          : Text(''),
      leading: IconButton(
        onPressed: () {},
        icon: Image.asset("assets/img/logoSmall.png"),
      ),
      elevation: 1,
      actions: actions
      // TODO: chat icon
      /*IconButton(
            onPressed: () { },
            icon: Icon(Icons.chat, size: 36),
          ),*/
      );
}

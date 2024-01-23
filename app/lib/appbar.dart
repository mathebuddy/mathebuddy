/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/keyboard.dart';

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_chat.dart';

AppBar buildAppBar(bool showAppLogo, bool showChatButton, State state,
    BuildContext context, MbclCourse? course) {
  List<Widget> actions = [];
  // home button
  actions.add(Text('  '));
  var actionHome = IconButton(
    onPressed: () {
      if (Navigator.canPop(state.context)) {
        Navigator.pop(state.context);
        keyboardState.layout = null;
      }
    },
    icon: Icon(Icons.home,
        size: 36,
        color: Navigator.canPop(state.context)
            ? getStyle().appbarIconActiveColor
            : getStyle().appbarIconInactiveColor),
  );
  if (showChatButton && course != null) {
    actions.add(IconButton(
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) {
            return ChatWidget(course);
          });
          Navigator.push(context, route)
              // ignore: invalid_use_of_protected_member
              .then((value) => {state.setState(() {})});
        },
        icon: Icon(
          MdiIcons.fromString("chat-question-outline"),
          size: 42,
          color: getStyle().appbarIconActiveColor,
        )));
  }
  actions.add(Text('  '));
  actions.add(actionHome);
  actions.add(Text('    '));
  // language switch
  var languageSwitchButton = Opacity(
      opacity: 0.5,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: getStyle().appbarDebugButtonColor,
                  width: getStyle().appbarDebugButtonBorderSize),
              borderRadius: BorderRadius.circular(1)),
          child: Padding(
              padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
              child: Text(" $language ",
                  style: TextStyle(
                      color: getStyle().appbarDebugButtonColor,
                      fontSize: getStyle().appbarDebugButtonFontSize)))));
  // debug/release button
  var switchDebugReleaseButton = Opacity(
      opacity: 0.5,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: getStyle().appbarDebugButtonColor,
                  width: getStyle().appbarDebugButtonBorderSize),
              borderRadius: BorderRadius.circular(1)),
          child: Padding(
              padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
              child: Text(debugMode ? " debug " : " release ",
                  style: TextStyle(
                      color: getStyle().appbarDebugButtonColor,
                      fontSize: getStyle().appbarDebugButtonFontSize)))));
  // Container(
  //     decoration: BoxDecoration(
  //         color: getStyle().appbarDebugButtonBackgroundColor,
  //         borderRadius: BorderRadius.circular(6)),
  //     child: Opacity(
  //         opacity: 0.8,
  //         child: Padding(
  //             padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
  //             child: Text(debugMode ? " debug " : " release ",
  //                 style: TextStyle(
  //                     color: getStyle().appbarDebugButtonColor,
  //                     fontSize: getStyle().appbarDebugButtonFontSize)))));
  // var saveButton = Container(
  //     decoration: BoxDecoration(
  //         color: getStyle().appbarDebugButtonBackgroundColor,
  //         borderRadius: BorderRadius.circular(6)),
  //     child: Opacity(
  //         opacity: 0.8,
  //         child: Padding(
  //             padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
  //             child: Text(" save ",
  //                 style: TextStyle(
  //                     color: getStyle().appbarDebugButtonColor,
  //                     fontSize: getStyle().appbarDebugButtonFontSize)))));
  var title = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    showDebugReleaseSwitch
        ? GestureDetector(
            onTap: () {
              language = language == 'en' ? 'de' : 'en';
              // ignore: invalid_use_of_protected_member
              state.setState(() {});
            },
            child: languageSwitchButton)
        : Text(''),
    Text(' '),
    showDebugReleaseSwitch
        ? GestureDetector(
            onTap: () {
              debugMode = !debugMode;
              // ignore: invalid_use_of_protected_member
              state.setState(() {});
            },
            child: switchDebugReleaseButton)
        : Text(''),
  ]);
  return AppBar(
      centerTitle: true,
      backgroundColor: getStyle().appbarBackgroundColor,
      title: title,
      leading: showAppLogo
          ? Padding(
              padding: EdgeInsets.all(7),
              child: Image.asset("assets/img/logoSmall.png"))
          : Text(""),
      elevation: 1,
      actions: actions);
}

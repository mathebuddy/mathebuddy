/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/style.dart';
import 'package:mathebuddy/widget_awards.dart';
import 'package:mathebuddy/widget_chat.dart';
import 'package:mathebuddy/widget_load.dart';
import 'package:mathebuddy/widget_settings.dart';

AppBar buildAppBar(bool showAppLogo, List<Widget> additionalButtons,
    bool showChatButton, State state, BuildContext context, MbclCourse? course,
    {showSettings = false}) {
  var iconSize = 36.0;

  List<Widget> debugButtons = [];

  Widget leading = Text("");
  double leadingWidth = 60.0;

  if (showDebugReleaseSwitch) {
    leadingWidth = 115.0;
    leading = Row(children: debugButtons);
  } else if (showAppLogo) {
    leading = Padding(
        padding: EdgeInsets.all(12),
        child: Image.asset("assets/img/logoSmall.png"));
  }

  // debug buttons
  if (showDebugReleaseSwitch) {
    // restart app
    debugButtons.add(GestureDetector(
        onTap: () {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          var route = MaterialPageRoute(builder: (context) {
            return LoadWidget();
          });
          Navigator.pushReplacement(context, route)
              // ignore: invalid_use_of_protected_member
              .then((value) => {state.setState(() {})});
        },
        child: Opacity(
            opacity: 0.5,
            child: Container(
                margin: EdgeInsets.only(left: 4.0, right: 4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: getStyle().appbarDebugButtonColor,
                        width: getStyle().appbarDebugButtonBorderSize),
                    borderRadius: BorderRadius.circular(1)),
                child: Padding(
                    padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: Icon(
                      MdiIcons.refresh,
                      size: 32.0,
                      color: getStyle().appbarDebugButtonColor,
                    ))))));

    // language switch
    debugButtons.add(GestureDetector(
        onTap: () {
          language = language == 'en' ? 'de' : 'en';
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
        },
        child: Opacity(
            opacity: 0.5,
            child: Container(
                margin: EdgeInsets.only(right: 4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: getStyle().appbarDebugButtonColor,
                        width: getStyle().appbarDebugButtonBorderSize),
                    borderRadius: BorderRadius.circular(1)),
                child: Container(
                    height: 35.0,
                    padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: Text(" ${language.toUpperCase()} ",
                        style: TextStyle(
                            color: getStyle().appbarDebugButtonColor,
                            fontSize:
                                getStyle().appbarDebugButtonFontSize)))))));
    // switch debug / release mode
    debugButtons.add(GestureDetector(
        onTap: () {
          debugMode = !debugMode;
          // ignore: invalid_use_of_protected_member
          state.setState(() {});
        },
        child: Opacity(
            opacity: 0.5,
            child: Container(
                margin: EdgeInsets.only(right: 0.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: getStyle().appbarDebugButtonColor,
                        width: getStyle().appbarDebugButtonBorderSize),
                    borderRadius: BorderRadius.circular(1)),
                child: Padding(
                    padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: Icon(
                      //debugMode ? MdiIcons.testTube : MdiIcons.sitemap,
                      debugMode ? MdiIcons.alphaD : MdiIcons.alphaR,
                      size: 32.0,
                      color: getStyle().appbarDebugButtonColor,
                    ))))));
  }

  List<Widget> actions = [];

  // settings button
  if (showSettings) {
    actions.add(IconButton(
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) {
            return SettingsWidget(course);
          });
          Navigator.push(context, route).then((value) {
            // ignore: invalid_use_of_protected_member
            state.setState(() {});
          });
        },
        icon: Icon(MdiIcons.cogOutline,
            size: iconSize, color: getStyle().appbarIconActiveColor)));
  }
  // home button
  actions.add(Text(' '));
  var actionHome = IconButton(
    onPressed: () {
      while (Navigator.canPop(state.context)) {
        if (course != null) {
          renderGotAwardOverlay(course, state, context);
        }
        Navigator.pop(state.context);
        keyboardState.layout = null;
      }
    },
    icon: Icon(Icons.home,
        size: iconSize,
        color: Navigator.canPop(state.context)
            ? getStyle().appbarIconActiveColor
            : getStyle().appbarIconInactiveColor),
  );
  // back button
  actions.add(Text(' '));
  var actionBack = IconButton(
    onPressed: () {
      if (Navigator.canPop(state.context)) {
        if (course != null) {
          renderGotAwardOverlay(course, state, context);
        }
        Navigator.pop(state.context);
        keyboardState.layout = null;
      }
    },
    icon: Icon(Icons.arrow_back_ios_new, //   Icons.home,
        size: iconSize,
        color: Navigator.canPop(state.context)
            ? getStyle().appbarIconActiveColor
            : getStyle().appbarIconInactiveColor),
  );
  // chat button
  if (showChatButton && course != null) {
    actions.add(IconButton(
        onPressed: () {
          keyboardState.layout = null;
          var route = MaterialPageRoute(builder: (context) {
            return ChatWidget(course);
          });
          Navigator.push(context, route)
              // ignore: invalid_use_of_protected_member
              .then((value) => {state.setState(() {})});
        },
        icon: Icon(
          MdiIcons.fromString("chat-question-outline"),
          size: iconSize,
          color: getStyle().appbarIconActiveColor,
        )));
  }
  //actions.add(Text(' '));
  actions.add(actionHome);
  actions.add(actionBack);
  actions.add(Text('  '));

  return AppBar(
      titleSpacing: 2.0,
      leadingWidth: leadingWidth,
      centerTitle: true,
      backgroundColor: getStyle().appbarBackgroundColor,
      title: Row(children: additionalButtons),
      leading: leading,
      elevation: 1,
      actions: actions);
}

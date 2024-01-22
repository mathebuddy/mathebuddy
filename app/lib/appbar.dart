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
import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/style.dart';

AppBar buildAppBar(bool showLogo, State state, MbclChapter? chapter) {
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
  var actionChat = IconButton(
      onPressed: () {
        // TODO
        // var route = MaterialPageRoute(builder: (context) {
        //   return ChatWidget(widget.course);
        // });
        // Navigator.push(context, route).then((value) => setState(() {}));
      },
      icon: Icon(
        MdiIcons.fromString("chat-question-outline"),
        size: 42,
        color: getStyle().appbarIconActiveColor,
      )
      // Icon(
      //   Icons.chat,
      //   size: 36,
      //   color: getStyle().appbarIconActiveColor,
      // ),
      );
  //actions.add(actionChat);
  //actions.add(Text('  '));
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
    // Text(' '),
    // debugMode
    //     ? GestureDetector(
    //         onTap: () {
    //           if (chapter != null) chapter.saveProgress();
    //           // ignore: invalid_use_of_protected_member
    //           state.setState(() {});
    //         },
    //         child: saveButton)
    //     : Text('')
  ]);
  return AppBar(
      centerTitle: true,
      backgroundColor: getStyle().appbarBackgroundColor,
      title: title,
      leading: showLogo
          ? Padding(
              padding: EdgeInsets.all(7),
              child: /*Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 4.0,
                    offset: Offset(1, 1),
                    color: const Color.fromARGB(255, 30, 30, 30))
              ]),*/
                  Image.asset("assets/img/logoSmall.png"))
          : Text(""),
      elevation: 1,
      actions: actions);
}

/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:mathebuddy/mbcl/src/level_item.dart';

import 'package:mathebuddy/color.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/screen.dart';

class KeyboardKey {
  var value = ''; // special values: "!B" := backspace, "!E" := enter
  var text = '';
  int rowIndex = 0;
  int columnIndex = 0;
  int rowSpan = 1;
  int columnSpan = 1;
}

class KeyboardLayout {
  int rowCount = 4;
  int columnCount = 4;
  List<KeyboardKey?> keys = [];

  KeyboardLayout(this.rowCount, this.columnCount) {
    var n = rowCount * columnCount;
    for (var k = 0; k < n; k++) {
      keys.add(null);
    }
  }

  static KeyboardLayout parse(String src) {
    // TODO: error checks
    var lines = src.split('\n');
    List<List<String>> rowData = [];
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      var tokens = line.split(' ');
      List<String> row = [];
      for (var token in tokens) {
        token = token.trim();
        if (token.isNotEmpty) row.add(token);
      }
      rowData.add(row);
    }
    var numRows = rowData.length;
    var numCols = rowData[0].length;
    var layout = KeyboardLayout(numRows, numCols);
    List<String> processedIndices = [];
    for (var i = 0; i < numRows; i++) {
      for (var j = 0; j < numCols; j++) {
        var data = rowData[i][j];
        var idx = '$i,$j';
        if (processedIndices.contains(idx)) continue;
        var rowSpan = 1;
        var colSpan = 1;
        for (var k = i; k < numRows; k++) {
          for (var l = j; l < numCols; l++) {
            var data2 = rowData[k][l];
            var idx2 = '$k,$l';
            if (data != '#' && data == data2) {
              processedIndices.add(idx2);
              if (k - i + 1 > rowSpan) rowSpan = k - i + 1;
              if (l - j + 1 > colSpan) colSpan = l - j + 1;
            }
          }
        }
        layout.addKey(i, j, rowSpan, colSpan, data);
        processedIndices.add(idx);
      }
    }
    return layout;
  }

  resize(int numRowsNew, int numColsNew) {
    List<KeyboardKey?> keysNew = [];
    for (var k = 0; k < numRowsNew * numColsNew; k++) {
      keysNew.add(null);
    }
    for (var i = 0; i < numRowsNew; i++) {
      for (var j = 0; j < numColsNew; j++) {
        if (i >= rowCount || j >= columnCount) continue;
        keysNew[i * numColsNew + j] = keys[i * columnCount + j];
      }
    }
    rowCount = numColsNew;
    columnCount = numColsNew;
    keys = keysNew;
  }

  addKey(
    int rowIndex,
    int columnIndex,
    int rowSpan,
    int columnSpan,
    String value,
  ) {
    var key = KeyboardKey();
    keys[rowIndex * columnCount + columnIndex] = key;
    key.rowIndex = rowIndex;
    key.columnIndex = columnIndex;
    key.rowSpan = rowSpan;
    key.columnSpan = columnSpan;
    key.value = value;
    // hex-icon codes from
    // https://api.flutter.dev/flutter/material/Icons-class.html
    switch (value) {
      case '!B': // backspace
        //key.text = 'icon:E0C5'; // backspace
        key.text = 'icon:EEB5'; // backspace_outlined
        break;
      case '!E': // enter
        //key.text = 'icon:E1F7'; // done_all
        key.text = 'icon:E614'; // subdirectory_arrow_left
        break;
      /*case '!L': // left arrow
        key.text = 'icon:F05BC';
        break;
      case '!R': // right arrow
        key.text = 'icon:F05BD';
        break;*/
      // TODO: TeX keys
      /*case '*':
        key.text = '\${}\\cdot{}\$';
        break;
      case 'pi':
        key.text = '\$pi\$';
        break;*/
      default:
        key.text = value;
    }
  }

  removeKey(int rowIndex, int columnIndex) {
    keys[rowIndex * columnCount + columnIndex] = null;
  }
}

// TODO: move "KeyboardState keyboardState" to attributes here!

class Keyboard {
  Widget generateWidget(CoursePageState state, KeyboardState keyboardState) {
    var keyboardLayout = keyboardState.layout as KeyboardLayout;
    var keyboardInputFieldData =
        keyboardState.inputFieldData as MbclInputFieldData;

    var keyWidth = screenWidth < 350 ? 45.0 : 55.0;
    const keyHeight = 50.0;
    const keyFontSize = 24.0;
    const keyFontSizeSmall = 18.0;
    const keyMargin = 4.0;

    var offsetX = (screenWidth - keyboardLayout.columnCount * keyWidth) / 2.0;
    var offsetY = 65.0;

    //double opacity = 0.5;

    List<Widget> widgets = [];
    for (var key in keyboardLayout.keys) {
      if (key == null || key.value == '#') continue;

      var textColor = Colors.black; //Colors.black87;
      var backgroundColor = Colors.white;

      var labelWidget = key.text.startsWith('icon:')
          ? Icon(
              IconData(int.parse(key.text.split(':')[1], radix: 16),
                  fontFamily: 'MaterialIcons'),
              color: textColor, // matheBuddyRed,
              size: keyFontSize,
            )
          : Text(key.text,
              style: TextStyle(
                  color: textColor,
                  fontSize:
                      key.text.length >= 2 ? keyFontSizeSmall : keyFontSize));
      var buttonWidth = keyWidth * key.columnSpan.toDouble() - keyMargin;
      var buttonHeight = keyHeight * key.rowSpan.toDouble() - keyMargin;

      var keyWidget = Positioned(
          left: offsetX + key.columnIndex * keyWidth,
          top: offsetY + key.rowIndex * keyHeight,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  elevation: 3.0,
                  shadowColor: Color.fromARGB(255, 0, 0, 0),
                  minimumSize: Size(buttonWidth, buttonHeight),
                  maximumSize: Size(buttonWidth, buttonHeight)),
              onPressed: () {
                //print('pressed key ${key.value}');
                if (key.value == '!B') {
                  // backspace
                  if (keyboardInputFieldData.studentValue.isNotEmpty &&
                      keyboardInputFieldData.cursorPos > 0) {
                    var oldValue = keyboardInputFieldData.studentValue;
                    var newValue = "";
                    var specialKeys = [
                      "pi",
                      "sin(",
                      "cos(",
                      "tan(",
                      "exp(",
                      "log(",
                      "sqrt("
                    ];
                    var specialKey = "";
                    var oldValueLeftOfCursor =
                        oldValue.substring(0, keyboardInputFieldData.cursorPos);
                    for (var key in specialKeys) {
                      if (oldValueLeftOfCursor.endsWith(key)) {
                        specialKey = key;
                        break;
                      }
                    }
                    var removeLength =
                        specialKey.isEmpty ? 1 : specialKey.length;
                    newValue = oldValue.substring(
                        0, keyboardInputFieldData.cursorPos - removeLength);
                    newValue +=
                        oldValue.substring(keyboardInputFieldData.cursorPos);
                    keyboardInputFieldData.studentValue = newValue;
                    keyboardInputFieldData.cursorPos -= removeLength;
                  }
                } else if (key.value == '!E') {
                  // enter
                  state.activeExercise = null;
                  keyboardState.layout = null;
                } else {
                  var beforeCursor = keyboardInputFieldData.studentValue
                      .substring(0, keyboardInputFieldData.cursorPos);
                  var afterCursor = keyboardInputFieldData.studentValue
                      .substring(keyboardInputFieldData.cursorPos);
                  var newStr = key.value;
                  if (beforeCursor.isNotEmpty) {
                    // if the last character before the cursor is alpha
                    // and the inserted string starts with an alpha character,
                    // then insert "*" before the new string.
                    var beforeCursorLastChar =
                        beforeCursor.codeUnitAt(beforeCursor.length - 1);
                    var isBeforeCursorLastCharAlpha =
                        beforeCursorLastChar >= "a".codeUnitAt(0) &&
                            beforeCursorLastChar <= "z".codeUnitAt(0);
                    var newStrFirstChar = newStr.codeUnitAt(0);
                    var isNewStrFirstCharAlpha =
                        newStrFirstChar >= "a".codeUnitAt(0) &&
                            newStrFirstChar <= "z".codeUnitAt(0);
                    if (isBeforeCursorLastCharAlpha && isNewStrFirstCharAlpha) {
                      newStr = "*$newStr";
                    }
                  }

                  keyboardInputFieldData.studentValue =
                      beforeCursor + newStr + afterCursor;
                  keyboardInputFieldData.cursorPos += newStr.length;
                }
                keyboardState.exerciseData?.feedback =
                    MbclExerciseFeedback.unchecked;

                // ignore: invalid_use_of_protected_member
                state.setState(() {});
              },
              child: Center(
                child: labelWidget,
              )));
      widgets.add(keyWidget);
    }

    // render typed text
    var studentValue = keyboardInputFieldData.studentValue;
    var cursorPos = keyboardInputFieldData.cursorPos;
    var charWidth = 16.8;

    // input field
    widgets.add(Positioned(
        left: 5,
        top: 10,
        child: GestureDetector(
            onTapDown: (TapDownDetails d) {
              // TODO: move to separate method

              // tap to change cursor position
              var x = d.globalPosition.dx;
              //print("x=$x");
              var newCursorPos =
                  ((x - (screenWidth - charWidth * studentValue.length) / 2) /
                          charWidth)
                      .round();
              if (newCursorPos < 0) {
                newCursorPos = 0;
              } else if (newCursorPos > studentValue.length) {
                newCursorPos = studentValue.length;
              }

              // move cursor to right, if it is within e.g. "sqrt("
              for (var i = 0; i < studentValue.length; i++) {
                for (var key in keyboardLayout.keys) {
                  if (key != null && key.value.startsWith("!") == false) {
                    var keyToken = key.value;
                    if (studentValue.substring(i).startsWith(keyToken)) {
                      if (newCursorPos > i &&
                          newCursorPos < i + keyToken.length) {
                        newCursorPos = i + keyToken.length;
                      }
                    }
                  }
                }
              }

              //print("newCursorPos=$newCursorPos");
              keyboardInputFieldData.cursorPos = newCursorPos;
              // ignore: invalid_use_of_protected_member
              state.setState(() {});
            },
            child: Container(
                width: screenWidth - 10,
                height: 45,
                decoration: BoxDecoration(
                  //color: Color.fromARGB(255, 245, 245, 245),
                  color: Colors.white,
                  //border: Border.all(
                  //   color: Color.fromARGB(255, 197, 197, 197), width: 1.0),
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Color.fromARGB(255, 192, 192, 192),
                  //       blurRadius: 3.0)
                  // ]
                ),
                child: Padding(
                    padding: EdgeInsets.only(top: 3.0),
                    child: Center(
                        child: Text(
                      studentValue,
                      style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'RobotoMono',
                          color: Colors.black),
                    )))))));

    // render cursor
    widgets.add(Positioned(
        left: (screenWidth - charWidth * studentValue.length) / 2 +
            charWidth * cursorPos,
        top: 15,
        child: Container(
          width: 2.5,
          height: 35,
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(1.0))),
        )));

    // render solution
    if (true /* TODO */ || bundleName.contains('bundle-test.json')) {
      var solution = keyboardState.inputFieldData!.expectedValue;
      widgets.add(Positioned(
          left: 0,
          top: 0,
          child: Container(
              decoration: BoxDecoration(
                  color: matheBuddyGreen.withOpacity(0.8),
                  //border: Border.all(width: 1.0),
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(2.0))),
              padding: EdgeInsets.only(top: 0, bottom: 1.5, left: 5, right: 5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                TextSpan(
                  text: solution,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )
              ])))));
    }

    // keyboard container
    return Container(
        decoration: BoxDecoration(
          //color: Color.fromARGB(255, 240, 240, 240),
          color: Colors.black87,
          //border:
          //    Border.all(width: 0.5, color: Color.fromARGB(135, 190, 190, 190)),
          //borderRadius: BorderRadius.only(
          //    topLeft: Radius.elliptical(screenWidth / 2, 5),
          //    topRight: Radius.elliptical(screenWidth / 2, 5))
        ),
        //color: Colors.black12,
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(maxHeight: 275.0),
        child: Stack(children: widgets));
  }
}

/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mathebuddy/mbcl/src/level_item_exercise.dart';
import 'package:mathebuddy/mbcl/src/level_item_input_field.dart';

import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/screen.dart';
import 'package:mathebuddy/style.dart';

KeyboardState keyboardState = KeyboardState();

class KeyboardState {
  KeyboardLayout? layout; // null := not shown
  MbclExerciseData? exerciseData;
  MbclInputFieldData? inputFieldData;
}

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
  bool isGapKeyboard = false; // does e.g. not insert "*" between alpha chars
  int lengthHint = -1; // shows hints on the number of keys, if >= 0
  bool hasBackButton = false;

  void setGapKeyboard(bool value) {
    isGapKeyboard = value;
  }

  void setLengthHint(int value) {
    lengthHint = value;
  }

  KeyboardLayout(this.rowCount, this.columnCount) {
    var n = rowCount * columnCount;
    for (var k = 0; k < n; k++) {
      keys.add(null);
    }
  }

  static KeyboardLayout parse(String src, {bool isGapKeyboard = false}) {
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
    layout.isGapKeyboard = isGapKeyboard;
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
    layout.hasBackButton = src.contains("!B");
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
        key.text = 'icon:EEB5'; // backspace_outlined
        break;
      case '!E': // enter
        key.text = 'icon:E614'; // subdirectory_arrow_left
        break;
      case '!M': //magic key
        key.text = 'icon:E5fA'; // star_border
        break;
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
  final State state;
  final KeyboardState keyboardState;
  //final bool evaluateDirectly;
  final KeyboardLayout keyboardLayout;
  final MbclInputFieldData keyboardInputFieldData;

  Keyboard(this.state, this.keyboardState /*, this.evaluateDirectly*/)
      : keyboardLayout = keyboardState.layout!,
        keyboardInputFieldData = keyboardState.inputFieldData!;

  Widget generateWidget() {
    var wideScreen = false;

    var screenWidth = MediaQuery.of(state.context).size.width;
    if (screenWidth > maxContentsWidth) {
      screenWidth = maxContentsWidth;
      wideScreen = true;
    }

    var keyWidth = screenWidth < 350 ? 45.0 : 55.0;
    if (keyboardLayout.columnCount >= 7) {
      keyWidth = 36;
    }
    const keyHeight = 50.0;
    const keyFontSize = 18.0; // 24.0;
    const keyFontSizeSmall = 12.0;
    const keyMargin = 4.0;

    var offsetX = (screenWidth - keyboardLayout.columnCount * keyWidth) / 2.0;
    var offsetY = 65.0;

    //double opacity = 0.5;

    List<Widget> widgets = [];
    for (var key in keyboardLayout.keys) {
      if (key == null || key.value == '#') continue;

      var textColor = Colors.black; //Colors.black87;
      var backgroundColor = Colors.white;

      var fontSize = key.text.length >= 2 ? keyFontSizeSmall : keyFontSize;
      if (keyboardLayout.columnCount >= 7) {
        fontSize = keyFontSizeSmall;
      }
      var keyText = key.text.replaceAll("!S", " ");
      var labelWidget = key.text.startsWith('icon:')
          ? Icon(
              IconData(int.parse(key.text.split(':')[1], radix: 16),
                  fontFamily: 'MaterialIcons'),
              color: textColor, // matheBuddyRed,
              size: keyFontSize,
            )
          : Text(keyText,
              style: TextStyle(color: textColor, fontSize: fontSize));
      var buttonWidth = keyWidth * key.columnSpan.toDouble() - keyMargin;
      var buttonHeight = keyHeight * key.rowSpan.toDouble() - keyMargin;

      var keyWidget = Positioned(
          left: offsetX + key.columnIndex * keyWidth,
          top: offsetY + key.rowIndex * keyHeight,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(0),
                  backgroundColor: backgroundColor,
                  elevation: 3.0,
                  shadowColor: Color.fromARGB(255, 0, 0, 0),
                  minimumSize: Size(buttonWidth, buttonHeight),
                  maximumSize: Size(buttonWidth, buttonHeight)),
              onPressed: () {
                keyPressed(key);
              },
              child: Center(
                child: labelWidget,
              )));
      widgets.add(keyWidget);
    }

    // render typed text
    var studentValue = keyboardInputFieldData.studentValue;
    var cursorPos = keyboardInputFieldData.cursorPos;

    var inputFieldFontSize = 28.0 - 0.3 * studentValue.length;
    /*if (studentValue.length > 15) {
      inputFieldFontSize = 20.0;
    }*/
    double charWidth = inputFieldFontSize * 3.0 / 5.0;
    if (charWidth * studentValue.length > screenWidth * 0.8) {
      inputFieldFontSize *= 0.75;
      charWidth *= 0.75;
    }

    // input field
    widgets.add(Positioned(
        left: 5,
        top: 10,
        child: GestureDetector(
            onTapDown: (TapDownDetails d) {
              // tap to change cursor position
              var x = d.localPosition.dx;
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
                          fontSize: inputFieldFontSize,
                          fontFamily: 'RobotoMono',
                          color: Colors.black),
                    )))))));

    // render cursor
    if (keyboardLayout.hasBackButton) {
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
    }
    // render length hint
    if (keyboardLayout.lengthHint >= 0) {
      var k = keyboardInputFieldData.studentValue.length;
      var n = keyboardLayout.lengthHint;
      var text = "$k/$n";
      widgets.add(Positioned(
          left: (screenWidth - charWidth * studentValue.length) / 2 +
              charWidth * cursorPos +
              15,
          top: 15,
          child: Text(text,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ))));
    }

    // render solution
    if (debugMode) {
      var solution = keyboardState.inputFieldData!.expectedValue;
      var diffVarId = keyboardState.inputFieldData!.diffVariableId;
      if (diffVarId.isNotEmpty) {
        solution = "$solution (student answer is first diff.ed to $diffVarId)";
      }
      widgets.add(Positioned(
          left: 0,
          top: 0,
          child: Container(
              decoration: BoxDecoration(
                  color: getStyle().matheBuddyGreen.withOpacity(0.8),
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
    return Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            var char = event.character ?? "###";
            for (var key in keyboardLayout.keys) {
              if (key == null || key.value == '#') continue;
              var isChar = key.value.startsWith(char);
              var isBackspace = key.value == "!B" &&
                  event.data.logicalKey.keyLabel == "Backspace";
              var isEnter = key.value == "!E" &&
                  event.data.logicalKey.keyLabel.endsWith("Enter");
              if (isChar || isBackspace || isEnter) {
                keyPressed(key);
              }
            }
          }
          return KeyEventResult.handled;
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: wideScreen
                  ? BorderRadius.only(
                      topLeft: Radius.circular(6), topRight: Radius.circular(6))
                  : null,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black87, const Color.fromARGB(175, 0, 0, 0)]),
            ),
            alignment: Alignment.bottomCenter,
            constraints: BoxConstraints(maxHeight: 275.0),
            child: Stack(children: widgets)));
  }

  keyPressed(KeyboardKey key) {
    // TODO: move code!!
    //print('pressed key ${key.value}');
    if (key.value == '!M') {
      // magic
      if (keyboardInputFieldData.type == MbclInputFieldType.string) {
        var expected = keyboardInputFieldData.expectedValue.toUpperCase();
        var student = keyboardInputFieldData.studentValue;
        if (student.length < expected.length &&
            expected.substring(0, student.length) == student) {
          keyboardInputFieldData.studentValue +=
              expected[student.length].toUpperCase();
          keyboardInputFieldData.cursorPos++;
        }
      }
    } else if (key.value == '!B') {
      // backspace
      if (keyboardInputFieldData.studentValue.isNotEmpty &&
          keyboardInputFieldData.cursorPos > 0) {
        var oldValue = keyboardInputFieldData.studentValue;
        var newValue = "";
        var specialKey = "";
        var oldValueLeftOfCursor =
            oldValue.substring(0, keyboardInputFieldData.cursorPos);
        for (var key in keyboardLayout.keys) {
          if (key == null) continue;
          if (oldValueLeftOfCursor.endsWith(key.value)) {
            specialKey = key.value;
            break;
          }
        }
        var removeLength = specialKey.isEmpty ? 1 : specialKey.length;
        newValue = oldValue.substring(
            0, keyboardInputFieldData.cursorPos - removeLength);
        newValue += oldValue.substring(keyboardInputFieldData.cursorPos);
        keyboardInputFieldData.studentValue = newValue;
        keyboardInputFieldData.cursorPos -= removeLength;
      }
    } else if (key.value == '!E') {
      // enter
      //state.activeExercise = null;
      keyboardState.layout = null;
    } else if (keyboardLayout.lengthHint >= 0 &&
        keyboardInputFieldData.studentValue.length >=
            keyboardLayout.lengthHint) {
      // do nothing
    } else if (keyboardLayout.hasBackButton == false) {
      // completely substitute answer, if keyboard has no
      // backspace button
      keyboardInputFieldData.studentValue = key.value;
      keyboardInputFieldData.cursorPos = key.value.length;
      keyboardState.exerciseData?.feedback = MbclExerciseFeedback.unchecked;
    } else {
      if (keyboardInputFieldData.studentValue.length < 32) {
        var beforeCursor = keyboardInputFieldData.studentValue
            .substring(0, keyboardInputFieldData.cursorPos);
        var afterCursor = keyboardInputFieldData.studentValue
            .substring(keyboardInputFieldData.cursorPos);
        var newStr = key.value.replaceAll("!S", " ");
        if (beforeCursor.isNotEmpty) {
          // if the last character before the cursor is alpha
          // and the inserted string starts with an alpha character,
          // then insert "*" before the new string.
          // This does NOT apply for gap question keyboards.
          var beforeCursorLastChar =
              beforeCursor.codeUnitAt(beforeCursor.length - 1);
          var isBeforeCursorLastCharAlpha =
              beforeCursorLastChar >= "a".codeUnitAt(0) &&
                  beforeCursorLastChar <= "z".codeUnitAt(0);
          var newStrFirstChar = newStr.codeUnitAt(0);
          var isNewStrFirstCharAlpha = newStrFirstChar >= "a".codeUnitAt(0) &&
              newStrFirstChar <= "z".codeUnitAt(0);
          if (isBeforeCursorLastCharAlpha &&
              isNewStrFirstCharAlpha &&
              keyboardLayout.isGapKeyboard == false) {
            newStr = "*$newStr";
          }
        }
        keyboardInputFieldData.studentValue =
            beforeCursor + newStr + afterCursor;
        keyboardInputFieldData.cursorPos += newStr.length;
      }
      keyboardState.exerciseData?.feedback = MbclExerciseFeedback.unchecked;
    }
    // evaluate exercise on first key (used e.g. for Event levels)
    // if (evaluateDirectly) {
    //   var exerciseData = keyboardState.exerciseData!;
    //   evaluateExercise(state, exerciseData.exercise.level, exerciseData);
    //   var bp = 1337;
    // }
    // ignore: invalid_use_of_protected_member
    state.setState(() {});
  }
}

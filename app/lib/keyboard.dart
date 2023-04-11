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
        key.text = 'icon:E0C5';
        break;
      case '!E': // enter
        key.text = 'icon:E1f7'; // done_all
        break;
      case '!L': // left arrow
        key.text = 'icon:F05BC';
        break;
      case '!R': // right arrow
        key.text = 'icon:F05BD';
        break;
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
    var offsetY = 20.0;

    //double opacity = 0.5;

    List<Widget> widgets = [];
    for (var key in keyboardLayout.keys) {
      if (key == null || key.value == '#') continue;

      var isArrowKey = key.value == '!L' || key.value == '!R';
      var textColor =
          isArrowKey ? Colors.black54 : matheBuddyRed; //Colors.black87;
      var backgroundColor =
          isArrowKey ? Color.fromARGB(0xFF, 0xd0, 0xd0, 0xD0) : Colors.white;

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
                      key.text.length >= 3 ? keyFontSizeSmall : keyFontSize));
      var buttonWidth = keyWidth * key.columnSpan.toDouble() - keyMargin;
      var buttonHeight = keyHeight * key.rowSpan.toDouble() - keyMargin;

      var keyWidget = Positioned(
          left: offsetX + key.columnIndex * keyWidth,
          top: offsetY + key.rowIndex * keyHeight,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  elevation: 1.0,
                  shadowColor: Colors.grey,
                  minimumSize: Size(buttonWidth, buttonHeight),
                  maximumSize: Size(buttonWidth, buttonHeight)),
              onPressed: () {
                //print('pressed key ${key.value}');
                if (key.value == '!B') {
                  // backspace
                  if (keyboardInputFieldData.studentValue.isNotEmpty) {
                    var oldValue = keyboardInputFieldData.studentValue;
                    var newValue = "";
                    var specialKeys = [
                      "pi",
                      "sin(",
                      "cos(",
                      "tan(",
                      "exp(",
                      "ln("
                    ];
                    var isSpecialKey = false;
                    for (var specialKey in specialKeys) {
                      if (oldValue.endsWith(specialKey)) {
                        newValue = oldValue.substring(
                            0, oldValue.length - specialKey.length);
                        isSpecialKey = true;
                        break;
                      }
                    }
                    if (isSpecialKey == false) {
                      newValue = oldValue.substring(0, oldValue.length - 1);
                    }
                    keyboardInputFieldData.studentValue = newValue;
                    // TODO: must take care for special keys!
                    keyboardInputFieldData.cursorPos--;
                  }
                } else if (key.value == '!E') {
                  // enter
                  state.activeExercise = null;
                  keyboardState.layout = null;
                } else if (key.value == '!L') {
                  if (keyboardInputFieldData.cursorPos > 0) {
                    keyboardInputFieldData.cursorPos--;
                  }
                } else if (key.value == '!R') {
                  if (keyboardInputFieldData.cursorPos <
                      keyboardInputFieldData.studentValue.length) {
                    keyboardInputFieldData.cursorPos++;
                  }
                } else {
                  //keyboardInputFieldData.studentValue += key.value;
                  var beforeCursor = keyboardInputFieldData.studentValue
                      .substring(0, keyboardInputFieldData.cursorPos);
                  var afterCursor = keyboardInputFieldData.studentValue
                      .substring(keyboardInputFieldData.cursorPos);

                  keyboardInputFieldData.studentValue =
                      beforeCursor + key.value + afterCursor;

                  keyboardInputFieldData.cursorPos++;
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

    if (bundleName.contains('bundle-test.json')) {
      widgets.add(Positioned(
          left: 25,
          top: 0,
          child: Text(
              'solution: ${keyboardState.inputFieldData?.expectedValue}')));
    }

    return Stack(children: widgets);
  }
}

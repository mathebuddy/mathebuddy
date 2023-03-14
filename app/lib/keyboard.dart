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
            if (data == data2) {
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
      case '*':
        key.text = '*';
        break;
      case '!B': // backspace
        key.text = 'icon:E0C5';
        break;
      case '!E': // enter
        key.text = 'icon:E156';
        break;
      case 'pi':
        key.text = '&pi;';
        break;
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

    const keyWidth = 55.0;
    const keyHeight = 50.0;
    const keyFontSize = 32.0;
    const keyBorderRadius = 5.0;
    const keyMargin = 4.0;

    var offsetX = (screenWidth - keyboardLayout.columnCount * keyWidth) / 2.0;
    var offsetY = 70.0;

    List<Widget> keyWidgets = [];
    for (var key in keyboardLayout.keys) {
      if (key == null) continue;
      var labelWidget = key.text.startsWith('icon:')
          ? Icon(
              IconData(int.parse(key.text.split(':')[1], radix: 16),
                  fontFamily: 'MaterialIcons'),
              color: matheBuddyRed,
              size: keyFontSize,
            )
          : Text(key.text,
              style: TextStyle(color: matheBuddyRed, fontSize: keyFontSize));

      var keyWidget = Positioned(
          left: offsetX + key.columnIndex * keyWidth,
          top: offsetY + key.rowIndex * keyHeight,
          child: GestureDetector(
              onTap: () {
                print('pressed key ${key.value}');
                if (key.value == '!B') {
                  // backspace
                  if (keyboardInputFieldData.studentValue.isNotEmpty) {
                    keyboardInputFieldData.studentValue =
                        keyboardInputFieldData.studentValue.substring(
                            0, keyboardInputFieldData.studentValue.length - 1);
                  }
                } else if (key.value == '!E') {
                  // enter
                  keyboardState.layout = null;
                } else {
                  keyboardInputFieldData.studentValue += key.value;
                }
                keyboardState.exerciseData?.feedback =
                    MbclExerciseFeedback.unchecked;
                // ignore: invalid_use_of_protected_member
                state.setState(() {});
              },
              child: Container(
                  width: keyWidth * key.columnSpan.toDouble() - keyMargin,
                  height: keyHeight * key.rowSpan.toDouble() - keyMargin,
                  //margin: EdgeInsets.all(keyMargin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius:
                        BorderRadius.all(Radius.circular(keyBorderRadius)),
                  ),
                  child: Center(
                    child: labelWidget,
                  ))));
      keyWidgets.add(keyWidget);
    }
    Widget widget = Container(
        //margin: EdgeInsets.only(bottom: 20.0),
        child: Stack(children: keyWidgets));
    return widget;
  }

  // TODO: remove old mathebuddy-sim src:

  /*private parent: HTMLElement = null;

  private inputText = '';
  private inputTextHTMLElement: HTMLSpanElement = null;
  private solutionHTMLElement: HTMLSpanElement = null;

  private listener: (text: string) => void;

  constructor(parent: HTMLElement) {
    this.parent = parent;
  }

  hide(): void {
    this.parent.style.display = 'none';
  }

  setInputText(inputText: string): void {
    this.inputText = inputText;
  }

  setSolutionText(solution: string): void {
    if (this.solutionHTMLElement == null) {
      console.log('called Keyboard.setSolutionText(..) before show()');
      return;
    }
    this.solutionHTMLElement.innerHTML = solution;
  }

  setListener(fct: (text: string) => void): void {
    this.listener = fct;
  }

  show(layout: KeyboardLayout, showPreview: boolean): void {
    this.parent.innerHTML = '';
    // div row
    var row = document.createElement('div');
    row.classList.add('row');
    this.parent.appendChild(row);
    // div column
    var col = document.createElement('div');
    row.appendChild(col);
    col.classList.add('col', 'text-center');
    // typed input
    this.inputTextHTMLElement = document.createElement('span');
    this.inputTextHTMLElement.innerHTML = this.inputText;
    this.inputTextHTMLElement.style.color = 'white';
    this.inputTextHTMLElement.style.fontSize = '18pt';
    //this.inputTextHTMLElement.style.borderBottomStyle = 'solid';
    //this.inputTextHTMLElement.style.borderColor = 'white';
    //this.inputTextHTMLElement.style.borderWidth = '2px';
    this.inputTextHTMLElement.style.marginTop = '8px';
    this.inputTextHTMLElement.style.paddingLeft = '3px';
    this.inputTextHTMLElement.style.paddingRight = '3px';
    col.appendChild(this.inputTextHTMLElement);
    if (showPreview == false) {
      var br = document.createElement('br');
      col.appendChild(br);
      this.inputTextHTMLElement.style.display = 'none';
    }
    // table
    var table = document.createElement('table');
    table.style.margin = '0 auto';
    table.style.padding = '0 0 0 0';
    var cells: HTMLTableCellElement[] = [];
    for (var i = 0; i < layout.rows; i++) {
      var tr = document.createElement('tr');
      table.appendChild(tr);
      for (var j = 0; j < layout.cols; j++) {
        var key = layout.keys[i * layout.cols + j];
        if (key == null) continue;
        var td = document.createElement('td');
        cells.push(td);
        tr.appendChild(td);
        td.style.backgroundColor = 'white';
        td.style.borderRadius = '6px';
        td.style.borderWidth = '4px';
        td.style.borderStyle = 'solid';
        td.style.borderColor = '#b1c752';
        td.style.color = '#b1c752';
        td.style.paddingLeft = '7px';
        td.style.paddingTop = '0px';
        td.style.paddingRight = '7px';
        td.style.paddingBottom = '0px';
        td.style.minWidth = '32px';
        //td.style.maxHeight = '14px';
        td.style.fontSize = '17pt';
        td.style.cursor = 'crosshair';
        if (key.rows > 1) td.rowSpan = key.rows;
        if (key.cols > 1) td.colSpan = key.cols;
        td.innerHTML = key.text;
        {
          var _value = key.value;
          td.addEventListener('click', () => {
            switch (_value) {
              case '!B': // backspace
                if (this.inputText.length > 0) {
                  this.inputText = this.inputText.substring(
                    0,
                    this.inputText.length - 1,
                  );
                }
                break;
              case '!E': // enter
                this.hide();
                break;
              default:
                this.inputText += _value;
            }
            this.listener(this.inputText);
            this.inputTextHTMLElement.innerHTML = this.inputText;
          });
        }
      }
    }
    col.appendChild(table);
    // solution preview (for debugging purposes)
    row = document.createElement('div');
    row.classList.add('row');
    this.parent.appendChild(row);
    col = document.createElement('div');
    col.classList.add('col', 'text-start');
    row.appendChild(col);
    this.solutionHTMLElement = document.createElement('span');
    this.solutionHTMLElement.innerHTML = '';
    this.solutionHTMLElement.style.marginTop = '0pt';
    this.solutionHTMLElement.style.paddingTop = '0pt';
    this.solutionHTMLElement.style.fontSize = '11pt';
    this.solutionHTMLElement.style.color = 'white';
    col.appendChild(this.solutionHTMLElement);
    // make keyboard visible
    this.parent.style.display = 'block';
  }*/
}

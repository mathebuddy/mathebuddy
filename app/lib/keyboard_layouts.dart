/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math';

import 'package:mathebuddy/keyboard.dart';

/// !B := backspace
/// !E := enter key
/// # := empty / no key
/// !X !Y !Z := variable placeholders (e.g. for x,y,z)

var keyboardLayoutsSrc = '''

### integer

7 8 9 !B
4 5 6 !B
1 2 3 !E
0 0 - !E

### integerWithOperators

7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 0 / !E

### real

7 8 9 pi !B
4 5 6 /  !B
1 2 3 -  !E
0 0 0 0  !E

### realWithOperators

7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 . / !E

### complexNormalForm

7 8 9 +     -     !B
4 5 6 *     /     !B
1 2 3 i     )     !E
0 0 0 sqrt( sqrt( !E

### integerSet

7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 0 , !E

### complexIntegerSet

7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 i , !E

### termX

7 8  9 + ^    !    !B
4 5  6 - sin( exp( !B
1 2  3 * cos( ln(  !E
0 !X ( / tan( )    !E

### termXY

7 8  9  + ^    !    !B
4 5  6  - sin( exp( !E
1 2  3  * cos( ln(  !E
0 !X !Y / tan( (    )

### termXYZ

7 8 9 !X + !    !B
4 5 6 !Y - sin( !E
1 2 3 !Z * cos( exp(
0 ( ) ^  / tan( ln(

### powerRoot

7 8 9  +     -     !B
4 5 6  *     /     !B
1 2 3  ^(    )     !E
0 i pi sqrt( sqrt( !E

### alpha

q w e r t z u i o p
a s d f g h j k l !B
y x c v b n m # # !B
''';

Map<String, String> keyboardLayouts = {};

bool parseKeyboardLayouts() {
  var lines = keyboardLayoutsSrc.split("\n");
  var id = '';
  var src = '';
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    if (line.startsWith('###')) {
      if (src.isNotEmpty) {
        keyboardLayouts[id] = src;
        src = "";
      }
      id = line.replaceAll('###', '').trim();
    } else {
      src += "$line\n";
    }
  }
  if (src.isNotEmpty) {
    keyboardLayouts[id] = src;
  }
  return true;
}

KeyboardLayout getKeyboardLayout(String keyboardId,
    {String varX = "x", String varY = "y", String varZ = "z"}) {
  if (keyboardLayouts.keys.isEmpty) {
    parseKeyboardLayouts();
  }
  if (keyboardLayouts.containsKey(keyboardId)) {
    var src = keyboardLayouts[keyboardId]!;
    src = src.replaceAll("!X", varX);
    src = src.replaceAll("!Y", varY);
    src = src.replaceAll("!Z", varZ);
    return KeyboardLayout.parse(src);
  }
  // fallback for non-existing ID: return integer layout
  return KeyboardLayout.parse("7 8 9 !B\n4 5 6 !B\n1 2 3 !E\n0 0 - !E\n");
}

KeyboardLayout createChoiceKeyboard(List<String> choices,
    {bool hasBackButton = true}) {
  // shuffle input s.t. the left-most key is not the first required letter
  // (prevents to show the solution from left to right in case of gap exercises)
  var originalOrder = List<String>.from(choices);
  var k = 0;
  do {
    choices.shuffle();
    k++;
    if (k > 5) break;
  } while (choices.length > 1 && choices[0] == originalOrder[0]);
  // generate the keyboard matrix
  var rows = sqrt(choices.length.toDouble()).floor();
  if (rows > 4) rows = 4;
  var cols = (choices.length / rows).ceil();
  var src = "";
  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols; j++) {
      if (i * cols + j < choices.length) {
        src += choices[i * cols + j];
      } else {
        src += '#'; // empty
      }
      src += " ";
    }
    if (hasBackButton) {
      if (i < 5) {
        src += '!B'; // backspace
      } else {
        src += '#'; // empty
      }
    }
    src += "\n";
  }
  return KeyboardLayout.parse(src, isGapKeyboard: true);
}

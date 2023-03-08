/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:mathebuddy/keyboard.dart';

/// !B := backspace
/// !E := enter

var integerKeyboardLayout = KeyboardLayout.parse('''
7 8 9 !B
4 5 6 !B
1 2 3 !E
0 0 - !E
''');

var integerOpKeyboardLayout = KeyboardLayout.parse('''
7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 0 / !E
''');

var realNumberKeyboardLayout = KeyboardLayout.parse('''
7 8 9 !B
4 5 6 !B
1 2 3 !E
0 . - !E
''');

var realNumberOpKeyboardLayout = KeyboardLayout.parse('''
7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 . / !E
''');

var complexNormalFormKeyboardLayout = KeyboardLayout.parse('''
7 8 9 + !B
4 5 6 - !B
1 2 3 i !E
0 0 0 . !E
''');

var integerSetKeyboardLayout = KeyboardLayout.parse('''
7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 0 , !E
''');

var complexSetKeyboardLayout = KeyboardLayout.parse('''
7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 i , !E
''');

var termKeyboardLayout = KeyboardLayout.parse('''
7 8 9 + sin( (   !B
4 5 6 - cos( )   !B
1 2 3 * tan( pi  !E
0 x . / exp( ln( !E
''');

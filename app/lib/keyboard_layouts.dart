/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:mathebuddy/keyboard.dart';

/// !B := backspace
/// !E := enter
/// !L := left arrow
/// !R := right arrow
/// # := empty

// TODO: add !L, !R and # for every layout

var keyboardLayoutInteger = KeyboardLayout.parse('''
!L 7 8 9 !B !R
!L 4 5 6 !B !R
!L 1 2 3 !E !R
!L 0 0 - !E !R
''');

var keyboardLayoutIntegerWithOperators = KeyboardLayout.parse('''
7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 0 / !E
''');

var keyboardLayoutReal = KeyboardLayout.parse('''
7 8 9 !B
4 5 6 !B
1 2 3 !E
0 . - !E
''');

var keyboardLayoutRealWithOperators = KeyboardLayout.parse('''
7 8 9 + !B
4 5 6 - !B
1 2 3 * !E
0 0 . / !E
''');

var keyboardLayoutComplexNormalForm = KeyboardLayout.parse('''
!L 7 8 9 + !B !R
!L 4 5 6 - !B !R
!L 1 2 3 / !E !R
!L 0 0 0 i !E !R
''');

var keyboardLayoutIntegerSet = KeyboardLayout.parse('''
7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 0 , !E
''');

var keyboardLayoutComplexIntegerSet = KeyboardLayout.parse('''
7 8 9 { !B
4 5 6 } !B
1 2 3 - !E
0 0 i , !E
''');

var keyboardLayoutTerm = KeyboardLayout.parse('''
7 8 9 + sin( (   !B
4 5 6 - cos( )   !B
1 2 3 * tan( pi  !E
0 x . / exp( ln( !E
''');

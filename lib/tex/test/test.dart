/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:io';

import '../src/tex.dart';

void main() {
  var tex = new TeX();
  var src =
      "f(x,y)=3x+y^{2^{8+1}}+z^{3+2}+\\alpha_{\\gamma}+\\beta+X"; //"\\frac x{ \\sum_1^{{6}} w } \\cdot 5";
  var output = '';
  var paintBox = true;
  output = tex.tex2svg(src, paintBox);
  if (output.isEmpty) {
    print("ERROR: tex2svg failed: " + tex.error);
    assert(false);
  }
  print(output);
  File('lib/tex/test/svg/test.svg').writeAsStringSync(output);
}

/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math';

import 'package:mathebuddy/math-runtime/src/parse.dart';
import 'package:tex/tex.dart';

void shuffleIntegerList(List<int> list) {
  var n = list.length;
  for (var k = 0; k < n; k++) {
    var i = Random().nextInt(n);
    var j = Random().nextInt(n);
    var tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}

String convertMath2TeX(String m, bool checkTeXRendering) {
  var parser = Parser();
  var texString = "";
  // parse input and convert to TeX String
  var term = parser.parse(m,
      splitIdentifiers: false); // TODO: splitIdentifiers: true??
  texString = term.toTeXString();
  // check if it can be rendered as TeX successfully
  if (checkTeXRendering) {
    var texEngine = TeX();
    var svg = texEngine.tex2svg(texString);
    if (svg.isEmpty || texEngine.error.isNotEmpty) {
      throw Exception('error');
    }
  }
  return texString;
}

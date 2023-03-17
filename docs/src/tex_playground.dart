/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:html';

import 'package:tex/tex.dart';

import 'help.dart';

void texPlayground() {
  setTextInput(
      'tex-input', 'f(x,y)=3x+y^{2^{8+1}}+z^{3+2}+\\alpha_{\\gamma}+\\beta+X');
  querySelector('#runTex')?.onClick.listen((event) {
    typeset(false);
  });
  querySelector('#runTexWithBorder')?.onClick.listen((event) {
    typeset(true);
  });
  typeset(false);
}

void typeset(bool paintBox) {
  var src = (querySelector('#tex-input') as InputElement).value as String;
  var tex = TeX();
  print(src);
  var output = tex.tex2svg(src, debugMode: paintBox);
  print(output);
  if (output.isNotEmpty) {
    var outputBase64 = base64Encode(utf8.encode(output));
    var img = document.createElement('img') as ImageElement;
    img.style.height = "72px";
    img.src = "data:image/svg+xml;base64,$outputBase64";
    /*var img =
          '<img class="" style="height:72px;" src="data:image/svg+xml;base64,${outputBase64}"/>';*/
    print(img);
    document.getElementById('tex-term')?.innerHtml = tex.parsed;
    document.getElementById('tex-rendering')?.innerHtml = '';
    document.getElementById('tex-rendering')?.append(img);
  } else {
    document.getElementById('tex-term')?.innerHtml = tex.error;
  }
}

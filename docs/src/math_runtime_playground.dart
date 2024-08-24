/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:html';

// ignore: avoid_relative_lib_imports
import '../../lib/math-runtime/src/parse.dart';

import 'package:tex/tex.dart';

import 'help.dart';

void appendTeXImg(Element e, String texSrc, {border = false}) {
  var tex = TeX();
  var output = tex.tex2svg(texSrc);
  if (tex.success()) {
    var outputBase64 = base64Encode(utf8.encode(output));
    var img = document.createElement('img') as ImageElement;
    img.style.height = "72px";
    img.src = "data:image/svg+xml;base64,$outputBase64";
    if (border) {
      var span = document.createElement('span');
      span.style.display = "inline-block";
      span.style.padding = "2px";
      span.style.margin = "2px";
      span.style.borderStyle = 'solid';
      span.style.borderWidth = '2px';
      span.append(img);
      e.append(span);
    } else {
      e.append(img);
    }
  } else {
    e.innerHtml = "${tex.error}, src=$texSrc";
  }
}

void mathRuntimePlayground() {
  // TERM PARSER
  setTextInput(
      'student-term', '{xy^2 + 4x + sin x * 3^(2+x) + sqrt(x) + |2x+1|, 2, 3}');
  querySelector('#runParser')?.onClick.listen((event) {
    var src = (querySelector('#student-term') as InputElement).value as String;
    var termHTML = document.createElement('span');
    var tokensHTML = '';
    try {
      var parser = Parser();
      var termTeX = parser.parse(src).toTeXString();
      appendTeXImg(termHTML, termTeX);
      var tokens = parser.getTokens();
      tokensHTML = tokens.map((element) {
        return '"$element"';
      }).join(", ");
      tokensHTML = '[$tokensHTML]';
    } catch (e) {
      termHTML.appendText(e.toString());
    }
    document.getElementById('tokens')?.innerHtml = tokensHTML;
    document.getElementById('term')?.innerHtml = "";
    document.getElementById('term')?.append(termHTML);
  });

  // TERM EVALUATION
  setTextInput('term-eval', '2^3 + 4 + sin pi');
  querySelector('#runEval')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-eval') as InputElement).value as String;
    var parser = Parser();
    var output = document.createElement('span');
    try {
      var term = parser.parse(termSrc);
      var termTeX = term.toTeXString();
      appendTeXImg(output, termTeX);
      var resultTeX = term.eval({}).toTeXString();
      appendTeXImg(output, "=$resultTeX");
    } catch (e) {
      output.appendText(e.toString());
    }
    document.getElementById('eval-output')?.innerHtml = '';
    document.getElementById('eval-output')?.append(output);
  });

  // TERM OPTIMIZATION
  setTextInput('term-opt', '1*3 + 4 +4x');
  querySelector('#runOpt')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-opt') as InputElement).value as String;
    var parser = Parser();
    var output = document.createElement('span');
    try {
      var term = parser.parse(termSrc);
      var termTeX = term.toTeXString();
      appendTeXImg(output, termTeX);
      var resultTeX = term.optimize().toTeXString();
      appendTeXImg(output, "=$resultTeX");
    } catch (e) {
      output.appendText(e.toString());
    }
    document.getElementById('opt-output')?.innerHtml = '';
    document.getElementById('opt-output')?.append(output);
  });

  // TERM DIFFERENTIATION
  setTextInput('term-diff', '4x^2 + sin(x)');
  setTextInput('term-diff-var', 'x');
  querySelector('#runDiff')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-diff') as InputElement).value as String;
    var varSrc =
        (querySelector('#term-diff-var') as InputElement).value as String;
    var parser = Parser();
    var output = document.createElement('span');
    try {
      var term = parser.parse(termSrc);
      var termTeX = term.toTeXString();
      appendTeXImg(output, termTeX);
      var result = term.diff(varSrc);
      var resultTeX = result.toTeXString();
      appendTeXImg(output, "=$resultTeX");
      var resultOptTeX = result.optimize().toTeXString();
      appendTeXImg(output, "=$resultOptTeX");
    } catch (e) {
      output.appendText(e.toString());
    }
    document.getElementById('diff-output')?.innerHtml = '';
    document.getElementById('diff-output')?.append(output);
  });

  // TERM COMPARISON
  setTextInput('term-compare-first', '2x');
  setTextInput('term-compare-second', 'x + x');
  querySelector('#runCompare')?.onClick.listen((event) {
    var term1src =
        (querySelector('#term-compare-first') as InputElement).value as String;
    var term2src =
        (querySelector('#term-compare-second') as InputElement).value as String;
    var parser = Parser();
    var output = document.createElement('span');
    try {
      var term1 = parser.parse(term1src);
      var term2 = parser.parse(term2src);
      var equal = term1.compareNumerically(term2) ? "~=~" : "~\\neq~";
      appendTeXImg(
          output, "${term1.toTeXString()}$equal${term2.toTeXString()}");
    } catch (e) {
      output.appendText(e.toString());
    }
    document.getElementById('compare-output')?.innerHtml = "";
    document.getElementById('compare-output')?.append(output);
  });

  // TERM TOKEN GENERATION
  setTextInput('term-tokens', '2cos(2x)+3');
  setTextInput('term-tokens-percentage', '50');
  querySelector('#runTermTokens')?.onClick.listen((event) {
    var termSrc =
        (querySelector('#term-tokens') as InputElement).value as String;
    var synthPercentage =
        (querySelector('#term-tokens-percentage') as InputElement).value
            as String;
    //print("XXX$synth");
    var output = document.createElement('span');
    try {
      var synthFactor = 1.0 + int.parse(synthPercentage) / 100.0;
      var parser = Parser();
      var term = parser.parse(termSrc);
      appendTeXImg(output, term.toTeXString(), border: true);
      appendTeXImg(output, "~\\rightarrow");
      var list = term.tokenizeAndSynthesize(
          synthFactor: synthFactor, depth: 2, removeDuplicates: true);
      output.append(document.createElement('br'));
      for (var item in list) {
        var tex = item.split("%%%")[1];
        appendTeXImg(output, tex, border: true);
      }
    } catch (e) {
      output.appendText(e.toString());
    }
    document.getElementById('term-tokens-output')?.innerHtml = "";
    document.getElementById('term-tokens-output')?.append(output);
  });
}

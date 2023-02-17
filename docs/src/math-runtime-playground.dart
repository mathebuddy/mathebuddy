/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:html';

import '../../lib/math-runtime/src/parse.dart';

import 'help.dart';

void mathRuntimePlayground() {
  // TERM PARSER
  setTextInput(
      'student-term', '{xy^2 + 4x + sin x * 3^(2+x) + sqrt(x) + |2x+1|, 2, 3}');
  querySelector('#runParser')?.onClick.listen((event) {
    var src = (querySelector('#student-term') as InputElement).value as String;
    var termHTML = '';
    var tokensHTML = '';
    try {
      var parser = new Parser();
      var term = parser.parse(src).toString();
      termHTML = term;
      var tokens = parser.getTokens();
      tokensHTML = '';
      for (var i = 0; i < tokens.length; i++) {
        var token = tokens[i];
        if (tokensHTML.length > 0) tokensHTML += ', ';
        tokensHTML += '"' + token + '"';
      }
      tokensHTML = '[' + tokensHTML + ']';
    } catch (e) {
      termHTML += e.toString();
    }
    document.getElementById('tokens')?.innerHtml = tokensHTML;
    document.getElementById('term')?.innerHtml = termHTML;
  });

  // TERM EVALUATION
  setTextInput('term-eval', '2^3 + 4 + sin pi');
  querySelector('#runEval')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-eval') as InputElement).value as String;
    var parser = new Parser();
    var output = '';
    try {
      var term = parser.parse(termSrc);
      output = 'Parsed ' + term.toString() + '<br/>';
      output += 'Evaluated to ' + term.eval({}).toString();
    } catch (e) {
      output += e.toString();
    }
    document.getElementById('eval-output')?.innerHtml = output;
  });

  // TERM OPTIMIZATION
  setTextInput('term-opt', '1*3 + 4 +4x');
  querySelector('#runOpt')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-opt') as InputElement).value as String;
    var parser = new Parser();
    var output = '';
    try {
      var term = parser.parse(termSrc);
      output = 'Parsed ' + term.toString() + '<br/>';
      var opt = term.optimize();
      output += 'Optimized to ' + opt.toString();
    } catch (e) {
      output += e.toString();
    }
    document.getElementById('opt-output')?.innerHtml = output;
  });

  // TERM DIFFERENTIATION
  setTextInput('term-diff', '4x^2 + sin(x)');
  setTextInput('term-diff-var', 'x');
  querySelector('#runDiff')?.onClick.listen((event) {
    var termSrc = (querySelector('#term-diff') as InputElement).value as String;
    var varSrc =
        (querySelector('#term-diff-var') as InputElement).value as String;
    var parser = new Parser();
    var output = '';
    try {
      var term = parser.parse(termSrc);
      output = 'Parsed ' + term.toString() + '<br/>';
      var diff = term.diff(varSrc);
      output += 'Differentiated to ' + diff.toString() + '<br/>';
      var opt = diff.optimize();
      output += 'Optimized to ' + opt.toString();
    } catch (e) {
      output += e.toString();
    }
    document.getElementById('diff-output')?.innerHtml = output;
  });

  // TERM COMPARISON
  setTextInput('term-compare-first', '2x');
  setTextInput('term-compare-second', 'x + x');
  querySelector('#runCompare')?.onClick.listen((event) {
    var term1src =
        (querySelector('#term-compare-first') as InputElement).value as String;
    var term2src =
        (querySelector('#term-compare-second') as InputElement).value as String;
    var parser = new Parser();
    var output = '';
    try {
      var term1 = parser.parse(term1src);
      var term2 = parser.parse(term2src);
      output = 'Comparing &nbsp; ' +
          term1.toString() +
          '&nbsp; with &nbsp;' +
          term2.toString() +
          '<br/>';
      var equal = term1.compareNumerically(term2);
      output += 'Result: ' + (equal ? 'EQUAL' : 'UNEQUAL');
    } catch (e) {
      output += e.toString();
    }
    document.getElementById('compare-output')?.innerHtml = output;
  });
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:html';

// ignore: avoid_relative_lib_imports
import '../../lib/smpl/src/interpreter.dart' as smpl_interpreter;
// ignore: avoid_relative_lib_imports
import '../../lib/smpl/src/parser.dart' as smpl_parser;
// ignore: avoid_relative_lib_imports
import '../../lib/smpl/src/node.dart' as smpl_node;

import 'help.dart';

// TODO: add more examples in (yet not existing) drop-down menu
/*var example = '''
let A:B = randZ<3,3>(-5,5)
let C = A * B
let d = det(C)
let f(x) = x^2
''';*/

var example = '''let a = rand(2,5)
let b = 1/2 + 2/4
let p(x) = 2x^2 + a x - 7
let k=3
while k > 0 {
  k = k - 1;
}
''';

void smplPlayground() {
  // get code
  setTextArea('smpl-editor', example);
  querySelector('#runSmpl')?.onClick.listen((event) {
    var src =
        (querySelector('#smpl-editor') as TextAreaElement).value as String;
    //print(src);
    runSmplCode(src);
  });
}

void runSmplCode(String src) {
  var parser = smpl_parser.Parser();
  try {
    // parse
    parser.parse(src);
    // get and show intermediate code (=: ic)
    var ast = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
    String astStr = ast.toString(0);
    showIntermediateCode(astStr);
    // get and show variable values
    var interpreter = smpl_interpreter.Interpreter();
    var symbols = interpreter.runProgram(ast);
    var output = '';
    for (var id in symbols.keys) {
      output += '@$id := ${symbols[id]?.term.toString()}\n';
      if (symbols[id]?.value != null) {
        output += '$id := ${symbols[id]?.value.toString()}\n';
      }
    }
    showOutput(output);
  } catch (e) {
    showOutput(e.toString());
  }
}

void showIntermediateCode(String o) {
  document.getElementById('smpl-ic')?.innerHtml = '<pre><code>$o</code></pre>';
}

void showOutput(String o) {
  document.getElementById('smpl-output')?.innerHtml =
      '<pre><code>$o</code></pre>';
}

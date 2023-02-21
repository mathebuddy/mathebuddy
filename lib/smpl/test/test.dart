/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:io';

import '../src/interpreter.dart';
import '../src/parser.dart';

void run(String src) {
  var parser = new Parser();
  AST_Node? ast = null;
  try {
    parser.parse(src);
    ast = parser.getAbstractSyntaxTree();
    print((ast as AST_Node).toString(0));
    var interpreter = new Interpreter();
    var symbols = interpreter.runProgram(ast);
    for (var id in symbols.keys) {
      print('@${id} := ${symbols[id]?.term.toString()}');
      if (symbols[id]?.value != null)
        print('${id} := ${symbols[id]?.value.toString()}');
    }
  } catch (e) {
    print('Error:' + e.toString());
    exit(-1);
  }
}

var src = '''
let a=3
let b = 1/2 + 2/4
let p(x) = 2x^2 + ax - 7
let k=3
while k > 0 {
  k = k - 1;
}

/*let A = rand<2,3>(-2,2)
let a:u = rand(2,4)
let b = 2 + a
let t = 1/2 {+|-} b/4
let v = 1/2 {+|-} @b/4
let k = 3
if k > 0 {
  k = k-1
} else {
  k = k + 1
}*/
''';

void main() {
  run(src);

  // TODO
  /*var path_list = glob.sync('examples/test_*.txt');
  for (var path of path_list) {
    print('--- ' + path + ' ---');
    var src = fs.readFileSync(path, 'utf-8');
    run(src);
    var bp = 1337;
  }*/
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:io';

import '../src/node.dart';
import '../src/interpreter.dart';
import '../src/parser.dart';

void run(String src) {
  var parser = Parser();
  AstNode? ast;
  parser.parse(src);
  ast = parser.getAbstractSyntaxTree();
  print((ast as AstNode).toString(0).trim());
  var interpreter = Interpreter();
  var symbols = interpreter.runProgram(ast);
  for (var id in symbols.keys) {
    if (symbols[id]?.value != null) {
      print('$id := ${symbols[id]?.value.toString()}');
      print('$id.tex := ${symbols[id]?.value.toTeXString()}');
    }
    print('@$id := ${symbols[id]?.term.toString()}');
    print('@$id.tex := ${symbols[id]?.term.toTeXString()}');
    print('@@$id := ${symbols[id]?.term.clone().optimize()}');
    print('@@$id.tex := ${symbols[id]?.term.clone().optimize().toTeXString()}');
    print('');
  }
}

/*var src = '''
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
''';*/

/*var src = '''
let f(x) = x^2
let g(x) = 2*x
figure {
  x_axis(-5, 5, "x")  % x-min, y-max, label
  y_axis(-5, 5, "y")
  function(f)
  function(g)
  circle(0, 0, 0.5)   % x, y, radius
  circle(2, 4, 0.5)
}
''';*/

/*var src = '''
let x = 1+2    >>> int >>> 3
''';*/

void main() {
  /*try {
    print("running the following src:\n%%%%%%%%\n$src\n%%%%%%%%\n");
    run(src);
  } catch (e) {
    print(e);
    exit(-1);
  }*/

  var allSrc = File("../../docs/tests/smpl-tests.txt").readAsStringSync();
  var lines = allSrc.replaceAll("\r", "").split("\n");
  var src = '';
  var stop = false;
  for (var line in lines) {
    if (line.trim().startsWith("%")) continue;
    if (line.startsWith("!STOP")) {
      stop = true;
      continue;
    }
    if (line.startsWith("---")) {
      src = src.trim();
      if (src.isNotEmpty) {
        print("----- running test -----");
        print(src);
        print("-----");

        try {
          run(src);
        } catch (e) {
          print(e);
          exit(-1);
        }

        src = "";

        if (stop) break;
      }
    } else if (!stop) {
      src += "$line\n";
    }
  }

  var bp = 1337;

  /*var dataSrc = File("test/data/smpl-tests.json").readAsStringSync();
  var data = jsonDecode(dataSrc)['programs'];
  var n = data.length as int;
  for (var i = 0; i < n; i++) {
    var title = data[i]['title'] as String;
    var code = data[i]['code'] as String;
    print('######## running test "$title" ########');
    print('--- code ---');
    print(code.trim());
    print('--- result ---');
    try {
      run(code);
    } catch (e) {
      print(e);
      exit(-1);
    }
    print('\n\n');
    var bp = 1337;
  }*/

  print('... end!');

  // TODO
  /*var path_list = glob.sync('examples/test_*.txt');
  for (var path of path_list) {
    print('--- ' + path + ' ---');
    var src = fs.readFileSync(path, 'utf-8');
    run(src);
    var bp = 1337;
  }*/
}

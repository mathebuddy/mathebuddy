/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../src/operand.dart';
import '../src/parse.dart';
import '../src/term.dart';

// TODO: add asserts

void main() {
  print('running MatheBuddy MATH RUNTIME tests ...');

  var parser = Parser();

  var xx = parser.parse("4i*(z-5i)^2");
  var yy = xx.toTeXString();

  var t = parser.parse("4*[1+10,2,3][1]");
  var v = t.eval({});

  // ---

  //var term = parser.parse("(((1/3)*(x^3))+(7*x)-2)");
  //var term = parser.parse("diff(sin(2x)+3x,x)");
  var term = parser.parse("2 cos(2x)+3");
  term = Term.evalFunction(term);

  //var tokens = Term.tokenize(term, 10);
  // var maxDepth = term.getMaxDepth();
  // for (var depth = 0; depth < maxDepth; depth++) {
  //   var tokens = term.tokenizeSubterm(depth);
  //   print("depth=$depth -> $tokens");
  // }
  var tokens = term.tokenizeAndSynthesize(
      removeDuplicates: true, depth: 2, synthFactor: 1.5);
  print(tokens);
  var bp = 1337;

  /*var summands = term.splitSummands();
  for (var i = 0; i < summands.length; i++) {
    print(summands[i]);
    summands[i].randomlyChangeIntegerOperands(2);
    print(summands[i]);
  }*/
  // try {
  //   var xx = term.generateCorrectAndIncorrectSummands(
  //       overheadFactor: 3, maxDelta: 5);
  //   var bp = 1337;
  // } catch (e) {
  //   print(e);
  // }

  // return;

//var term = parser.parse('randZ(-2,2)');
//var term = parser.parse('rand<2,3>(-2,2)');
//var term = parser.parse('abs(-3+4i)');
//var term = parser.parse('binomial(49,6)');
//var term = parser.parse('ceil(3.14)');
//var term = parser.parse('complex(3,4)');
//var term = parser.parse('fac(3)');
//var term = parser.parse('real(3+4i)');
//var term = parser.parse('imag(3+4i)');
//var term = parser.parse('{1,2,3}'); // set
//var term = parser.parse('[1+5,2,3]'); // vector
//var term = parser.parse('[[1+2*3,2],[3,4]]'); // matrix
//var term = parser.parse('(1/3) * [[1+2*3,2],[3,4]]+[[5,6],[7,8]]'); // TODO: without "()"
  //var term = parser.parse('sqrt(1/9)');
  //var term = parser.parse('cos(-pi)');
  //var term = parser.parse('((1/2)+((1/2)*(1*(0+i))))');
  //var term = parser.parse('1/3*i');
  term = parser.parse('1/3 i');

  var value = term.eval({});
  print(term.toString());
  print(value.toString());

  term = parser.parse('1/2 {+|-} 2/3');
  print(term.toString());
  value = term.eval({});
  print('eval: $value');
  assert(value.type == OperandType.rational);

  term = parser.parse('2 * (-3+4)');
  print(term.toString());
  value = term.eval({});
  print('eval: $value');
  assert(value.type == OperandType.int);
  assert(value.real == 2 * (-3 + 4));

  term = parser.parse('2(3+4.1)');
  print(term.toString());
  value = term.eval({});
  print('eval: $value');
  assert(value.type == OperandType.real);
  assert(value.real == 2 * (3 + 4.1));

  term = parser.parse('x y^2');
  print(term.toString());

  term = parser.parse('{1,2,3,x y}');
  print(term.toString());

  term = parser.parse('(2)i');
  print(term.toString());

  term = parser.parse('2i');
  print(term.toString());

  term = parser.parse('sin x cos y');
  print(term.toString());

  term = parser.parse('sin(x) * cos y + 3');
  print(term.toString());

  term = parser.parse('xy');
  print(term.toString());

  term = parser.parse('pi');
  print(term.toString());

  term = parser.parse('(((x^2)+(4*(2*(x^1))))+(1*cos(x)))');
  print(term.toString());
  term = term.optimize();
  print(term.toString());

  term = parser.parse('2 + 3i');
  print(term.toString());
  print(term.eval({}).toString());

  term = parser.parse('{1,2,3,1+2,2+2,2*sin(1)}');
  print(term.eval({}).toString());

  var t1 = parser.parse('1+1*1i+i');
  print(t1.toString());
  var t2 = parser.parse('(1+1)i+0+2-1');
  print(t2.toString());
  print(t1.compareNumerically(t2));
}

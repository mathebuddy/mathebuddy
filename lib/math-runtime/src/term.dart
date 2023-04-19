/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math' as math;

import 'diff.dart';
import 'eval.dart';
import "operand.dart";
import 'opt.dart';
import 'str.dart';

// TODO: configure all epsilons

/// Algebraic term.
///
/// Operations:
///   $     variable
///   #     operand (e.g. integer, real, rational, matrix, ...)
///   +     add (n-ary)
///   -     sub (n-ary)
///   *     mul (n-ary)
///   /     div (binary)
///   .-    unary minus
///   ^     pow
///   <     less than
///   <=    less or equal
///   >     greater than
///   >=    greater or equal
///   exp   exp
///   ln    ln
///   sin   sin
///   cos   cos
///   tan   tan
///   asin  arcus sin
///   acos  arcus acos
///   atan  arcus atan
class Term {
  // TODO: attributes should be private!
  String op =
      ''; // operation. Special operations: '$' := variable, '#' := scalar
  Operand value = Operand(); // used, if op=='#
  List<Term> o = []; // operands = sub-terms
  List<Term> dims =
      []; // dimensions (e.g. in "rand<2,3>(-3,4)" dimensions are [2,3])

  Term(this.op, this.o, this.dims);

  /// Creates a term with operation [op], operands [o] and dimensions [dims].
  static Term createOp(String op, List<Term> o, List<Term> dims) {
    return Term(op, o, dims);
  }

  static Term createConst(Operand o) {
    var t = Term('#', [], []);
    t.value = o;
    return t;
  }

  /// Creates a boolean constant (scalar).
  static Term createConstBoolean(bool value) {
    var t = Term('#', [], []);
    t.value = Operand.createBoolean(value);
    return t;
  }

  /// Creates an integral constant term (scalar).
  static Term createConstInt(num value) {
    var t = Term('#', [], []);
    t.value = Operand.createInt(value);
    return t;
  }

  /// Creates an real constant term (scalar).
  static Term createConstReal(num value) {
    var t = Term('#', [], []);
    t.value = Operand.createReal(value);
    return t;
  }

  // Creates a constant irrational number (scalar).
  static Term createConstIrrational(String irr) {
    var t = Term('#', [], []);
    t.value = Operand.createIrrational(irr);
    return t;
  }

  /// Creates an rational constant term (scalar).
  static Term createConstRational(num n, num d) {
    var t = Term('#', [], []);
    t.value = Operand.createRational(n, d);
    return t;
  }

  /// Creates an rational constant term (scalar).
  static Term createConstComplex(num re, num im) {
    var t = Term('#', [], []);
    t.value = Operand.createComplex(re, im);
    return t;
  }

  /// Creates a variable term
  static Term createVar(String id) {
    var t = Term('\$', [], []);
    t.value = Operand.createIdentifier(id);
    return t;
  }

  /// Creates an exact copy of the object.
  Term clone() {
    var c = Term(op, [], []);
    c.value = value.clone();
    for (var i = 0; i < o.length; i++) {
      var oi = o[i];
      c.o.add(oi.clone());
    }
    return c;
  }

  /// Evaluates the term or throws an exception, if any variable has an unknown
  /// value.
  ///
  /// [varValues] is the dictionary that substitutes variables by constants,
  /// e.g. {x:5,y:7}
  Operand eval(Map<String, Operand> varValues) {
    return evalTerm(this, varValues);
  }

  /// Symbolic differentiation by a derivation variable [varId]. The resulting
  /// term is not optimized.
  ///
  /// The caller should also call "opt()" after "diff(..)".
  Term diff(String varId) {
    return diffTerm(this, varId);
  }

  /// Integrates a definite integral numerically by a variable [varId] from
  /// lower bound [a] to upper bound [b] with step width [h].
  num integrate(String varId, num a, num b, [num h = 1e-12]) {
    // TODO: trapezoidal rule!
    num r = 0;
    for (var x = a; x <= b; x += h) {
      var y = eval({varId: Operand.createReal(x)});
      // TODO: check t.type!
      r += y.real;
    }
    return r / h;
  }

  /// Returns an optimized representation of the term that is algebraically
  /// equivalent (e.g. "x+2+3*4+5*x" -> "14+6*x").
  Term optimize() {
    return optTerm(this);
  }

  bool compareNumerically(Term t, [num epsilon = 1e-9]) {
    // TODO: only use variable values that result in "small" eval values
    Set<String> varIds = {};
    varIds.addAll(getVariableIDs());
    varIds.addAll(t.getVariableIDs());
    var n = varIds.isEmpty ? 1 : 10; // number of tests: TODO: customize!
    for (var k = 0; k < n; k++) {
      Map<String, Operand> varValues = {};
      // TODO: currently testing only real values here!!!!!!!!!!
      for (var varId in varIds) {
        varValues[varId] =
            Operand.createReal(math.Random().nextDouble()); // TODO: range!
      }
      var u = eval(varValues);
      var v = t.eval(varValues);
      if (Operand.compareEqual(u, v, epsilon) == false) {
        return false;
      }
    }
    return true;
  }

  void substituteVariableByOperand(String id, Operand o) {
    if (op == '\$' && value.text == id) {
      op = '#';
      value = o.clone();
    }
    for (var i = 0; i < this.o.length; i++) {
      var oi = this.o[i];
      oi.substituteVariableByOperand(id, o);
    }
  }

  void substituteVariableByTerm(String id, Term t) {
    if (op == '\$' && value.text == id) {
      op = t.op;
      o = t.o;
      value = t.value.clone();
    }
    for (var i = 0; i < o.length; i++) {
      var oi = o[i];
      oi.substituteVariableByTerm(id, t);
    }
  }

  /// Returns the set of variable IDs that are actually used in the term.
  Set<String> getVariableIDs() {
    Set<String> vars = {};
    if (op == '\$') vars.add(value.text);
    for (var i = 0; i < o.length; i++) {
      var oi = o[i];
      vars.addAll(oi.getVariableIDs());
    }
    return vars;
  }

  /// Splits the term into summands.
  ///
  /// Example: "2*x^2 + 5*x + 7"
  ///    is split into ["2*x^2", "5*x", "7"]
  List<Term> splitSummands() {
    List<Term> s = [];
    if (op == '+' || op == '-') {
      s = o;
    } else {
      s.add(this);
    }
    return s;
  }

  /// Generates a list of summands plus an overhead of incorrect summands.
  /// The resulting list does NOT contain two elements that are equal.
  ///
  /// Example: "2*x^2 + 5*x + 7" with overhead factor 1.5:
  ///
  /// Correct summands are ["2*x^2", "5*x", "7"], i.e. 3 summands.
  /// The result consists of round(3*1.5)=5 elements, for example
  /// ["2*x^2", "5*x", "7", "3*x^4", "6*x"];
  List<Term> generateCorrectAndIncorrectSummands(
      [double overheadFactor = 1.5, int maxDelta = 2]) {
    var maxIterations = 100;
    List<Term> correct = splitSummands();
    correct = Term.removeDuplicates(correct);
    var n = (correct.length * overheadFactor).round();
    List<Term> all = [];
    all.addAll(correct);
    var iteration = 0;
    while (all.length < n) {
      if (iteration > maxIterations) {
        throw Exception("generateCorrectAndIncorrectSummands "
            "exceeded max number of iterations");
      }
      for (var item in correct) {
        var newItem = item.clone();
        newItem.randomlyChangeIntegerOperands(maxDelta);
        all.add(newItem);
      }
      all = Term.removeDuplicates(all);
      iteration++;
    }
    all = all.sublist(0, n);
    return all;
  }

  static List<Term> removeDuplicates(List<Term> list) {
    List<Term> output = [];
    for (var item in list) {
      var found = false;
      for (var item2 in output) {
        if (item.compareNumerically(item2)) {
          found = true;
          break;
        }
      }
      if (!found) output.add(item);
    }
    return output;
  }

  void randomlyChangeIntegerOperands(int maxDelta) {
    _randomlyChangeIntegerOperandsRecursively(this, maxDelta);
  }

  void _randomlyChangeIntegerOperandsRecursively(Term term, int maxDelta) {
    for (var i = 0; i < term.o.length; i++) {
      _randomlyChangeIntegerOperandsRecursively(term.o[i], maxDelta);
      if (term.o[i].value.type == OperandType.int) {
        var rand = math.Random();
        term.o[i].value.real += rand.nextInt(maxDelta);
      }
    }
  }

  /// Converts the term object to a string.
  @override
  String toString() {
    return term2string(this);
  }
}

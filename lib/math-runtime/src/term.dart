/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library math_runtime;

import 'dart:math' as math;

import 'diff.dart';
import 'eval.dart';
import 'help.dart';
import "operand.dart";
import 'opt.dart';
import 'str.dart';

// TODO: configure all epsilons

/// Algebraic term.
///
/// Operations:
///   $     variable
///   #     operand (e.g. boolean, integer, real, rational, matrix, ...)
///   +     add (n-ary)
///   -     sub (n-ary)
///   *     mul (n-ary)
///   /     div (binary)
///   ^     pow
///   .-    unary minus
///   !     unary not
///   <     less than
///   <=    less or equal
///   >     greater than
///   >=    greater or equal
///   &&    logical and
///   ||    logical or
///   ==    equal
///   !=    not equal
///   index index of vector; first operand := term, second operand := index
///   abs   absolute value
///   ...   (refer to fct1 and fct2 in file parse.dart)
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

  // Creates v constant term, given by an operand.
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

  /// Creates an infinity constant.
  static Term createConstInfinity() {
    var t = Term('#', [], []);
    t.value = Operand.createInt(1 / 0);
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
    t.value =
        Operand.createComplex(Operand.createReal(re), Operand.createReal(im));
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

  /// Resolves diff, opt in functions .
  /// E.g. "let u = 3 + 4;  let f(x) = diff( term(u), x); ")
  ///      (however, term is useless in the example)
  static Term evalFunction(Term t) {
    // TODO: rename method to a better name!!
    for (var i = 0; i < t.o.length; i++) {
      t.o[i] = Term.evalFunction(t.o[i]);
    }
    if (t.op == "opt") {
      t = t.o[0].optimize();
    } else if (t.op == "diff") {
      var diffFun = t.o[0];
      var diffVar = t.o[1];
      if (diffVar.value.type != OperandType.identifier) {
        throw Exception("diff(..) requires a variable as second argument.");
      }
      var diffVarId = diffVar.value.text;
      t = diffFun.diff(diffVarId);
      t = t.optimize();
    }
    return t;
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

  Term substituteVariableByTermOrOperand(String id, Term t, Operand o) {
    if (op == "term" && this.o[0].op == '\$' && this.o[0].value.text == id) {
      return t;
    } else if (op == '\$' && value.text == id) {
      op = '#';
      value = o.clone();
    }
    for (var i = 0; i < this.o.length; i++) {
      this.o[i] = this.o[i].substituteVariableByTermOrOperand(id, t, o);
    }
    for (var i = 0; i < dims.length; i++) {
      dims[i] = dims[i].substituteVariableByTermOrOperand(id, t, o);
    }
    return this;
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
    for (var i = 0; i < dims.length; i++) {
      var d = dims[i];
      d.substituteVariableByTerm(id, t);
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
    for (var i = 0; i < dims.length; i++) {
      var d = dims[i];
      vars.addAll(d.getVariableIDs());
    }
    return vars;
  }

  /// TODO: description + integrate into method tokenizeSubterm
  void disturb() {
    if (op == '#') {
      value.disturb();
    }
    for (var oi in o) {
      oi.disturb();
    }
  }

  /// Tokenizes the term into stringified tokens.
  /// The output returns a list of stringified tokens in the format of the
  /// math runtime, as well as as TeX-notation. Both formats are encoded into
  /// one string, separated by "%%%".
  ///
  /// For example, "2*sin(2*x)+3" is split into tokens
  ///    ["+%%%+", "*%%%\cdot", "2%%%2", "cos(%%%\cos(", ")%%%)", "*%%%\cdot",
  ///     "2%%%2", "x%%%x", "3%%%3"].
  ///
  /// Parameter [depth] defines the depth of the term tree.
  /// For example, maxDepth=0 returns ["2*sin(2*x)+3"],
  ///              maxDepth=1 returns ["+", "(2*cos((2*x)))", "3"], ...
  ///
  /// If [removeDuplicates] is true, then all elements of the resulting
  /// list are distinct, i.e. the result is a set.
  ///
  /// If [synthFactor] is 1.0, then the resulting list contains exactly the
  /// set of tokens that is required to build the solution. It may contain
  /// duplicated, depending on parameter [removeDuplicated].
  ///
  /// If [synthFactor] is larger than 1, then the resulting list contains
  /// "artificial" tokens. The actual number of tokens may less than defined
  /// by [synthFactor], if randomization is not possible in a constrained
  /// range (e.g. the absolute value of altered integer constants is constrained
  /// by a maximum, that is defined in method [tokenizeSubterm]).
  ///
  /// For example, if 5 tokens are essential, and [synthFactor] is 1.5,
  /// then round(5*1.5)-5 = 4 extra tokens are generated.
  ///
  /// Automatically created tokens are derived from the existing ones, by e.g.
  /// adjusting constants (e.g. "2" -> "3") or changing operations
  /// (e.g. "sin" -> "cos").
  List<String> tokenizeAndSynthesize(
      {int depth = 99999,
      double synthFactor = 1.0,
      bool removeDuplicates = false}) {
    depth = math.min(depth, getMaxDepth());
    var tokens = tokenizeSubterm(depth);
    if (removeDuplicates) {
      tokens = tokens.toSet().toList();
    }
    var k = 0;
    if (synthFactor > 1) {
      int n = (tokens.length * synthFactor).round();
      while (tokens.length < n) {
        var artificialTokens = tokenizeSubterm(depth, randomize: true);
        var idx = math.Random().nextInt(artificialTokens.length);
        var artificialToken = artificialTokens[idx];
        tokens.add(artificialToken);
        if (removeDuplicates) {
          tokens = tokens.toSet().toList();
        }
        k++;
        if (k > 1000) break;
      }
    }
    return tokens;
  }

  int getMaxDepth() {
    if (op == '#' || op == '\$') return 1;
    int max = 1;
    for (var oi in o) {
      int d = oi.getMaxDepth() + 1;
      max = math.max(max, d);
    }
    return max;
  }

  /// Tokenizes the current term into a list of stringified tokens.
  /// Refer to descriptions in method [tokenizeAndSynthesize].
  /// The method may return same token twice or more.
  /// If [randomize] is true, then tokens are altered by coincidence.
  List<String> tokenizeSubterm(int depth, {bool randomize = false}) {
    // properties for randomization
    const fct = ['sin', 'cos', 'tan', 'exp', 'sqrt'];
    const changeFctProb = 2;
    const maxConstantAdjust = 5;
    // algorithm
    List<String> res = [];
    if (op == '#' || op == '\$' || depth <= 0) {
      var s = '';
      if (randomize && op == '#' && value.type == OperandType.int) {
        var v = value.real + math.Random().nextInt(maxConstantAdjust);
        s = '$v' + '%%%' + '$v';
      } else if (randomize &&
          fct.contains(op) &&
          math.Random().nextInt(changeFctProb) == 0) {
        var idx = math.Random().nextInt(fct.length);
        var c = clone();
        c.op = fct[idx];
        s = c.toString() + "%%%" + c.toTeXString();
      } else {
        s = toString() + "%%%" + toTeXString();
      }
      res.add(s.trim());
    } else {
      if (isAlpha(op)) {
        var s = op;
        res.add("$s(%%%\\$s(");
        res.add(")%%%)");
      } else {
        res.add(op + "%%%" + (op == "*" ? "\\cdot" : op));
      }
      for (var oi in o) {
        var sub = oi.tokenizeSubterm(depth - 1, randomize: randomize);
        res.addAll(sub);
      }
    }
    return res;
  }

  String toTeXString({bool needParentheses = false}) {
    var s = term2tex(this, needParentheses: needParentheses);
    // Terms of the form x-a-b-... are stored as n-ary addition x+(-a)+(-b)+...
    // In case of operators with same precedence (here + and -), no parenthesis
    // is set while stringifying the term. This results in "+-", which must
    // be replaced.
    s = s.replaceAll("+-", "-");
    return s;
  }

  /// Converts the term object to a string.
  @override
  String toString() {
    return term2string(this);
  }
}

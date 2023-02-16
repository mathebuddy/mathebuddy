/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:math' as math;

import 'diff.dart';
import 'eval.dart';
import "operand.dart";
import 'opt.dart';
import 'str.dart';

// TODO: configure all epsilons

/**
 * Algebraic term.
 *
 * Operations:
 *   $     variable
 *   #     operand (e.g. integer, real, rational, matrix, ...)
 *   +     add (n-ary)
 *   -     sub (n-ary)
 *   *     mul (n-ary)
 *   /     div (binary)
 *   .-    unary minus
 *   ^     pow
 *   <     less than
 *   <=    less or equal
 *   >     greater than
 *   >=    greater or equal
 *   exp   exp
 *   ln    ln
 *   sin   sin
 *   cos   cos
 *   tan   tan
 *   asin  arcus sin
 *   acos  arcus acos
 *   atan  arcus atan
 */
class Term {
  // TODO: attributes should be private!
  String op =
      ''; // operation. Special operations: '$' := variable, '#' := scalar
  Operand value = new Operand(); // used, if op=='#
  List<Term> o = []; // operands = sub-terms
  List<Term> dims =
      []; // dimensions (e.g. in "rand<2,3>(-3,4)" dimensions are [2,3])

  Term(String op, List<Term> o, List<Term> dims) {
    this.op = op;
    this.o = o;
    this.dims = dims;
  }

  /**
   * Creates a term with operation op and operands o
   * @param op operation, e.g. '+'
   * @param o operands
   * @returns a new term
   */
  static Term Op(String op, List<Term> o, List<Term> dims) {
    return new Term(op, o, dims);
  }

  static Term Const(Operand o) {
    var t = new Term('#', [], []);
    t.value = o;
    return t;
  }

  /**
   * Creates an integral constant term (scalar)
   * @param value constant value
   * @returns a new term
   */
  static Term ConstInt(num value) {
    var t = new Term('#', [], []);
    t.value = Operand.createInt(value);
    return t;
  }

  /**
   * Creates an real constant term (scalar)
   * @param value constant value
   * @returns a new term
   */
  static Term ConstReal(num value) {
    var t = new Term('#', [], []);
    t.value = Operand.createReal(value);
    return t;
  }

  static Term ConstIrrational(String irr) {
    var t = new Term('#', [], []);
    t.value = Operand.createIrrational(irr);
    return t;
  }

  /**
   * Creates an rational constant term (scalar)
   * @param n numerator
   * @param d denominator
   * @returns a new term
   */
  static Term ConstRational(num n, num d) {
    var t = new Term('#', [], []);
    t.value = Operand.createRational(n, d);
    return t;
  }

  /**
   * Creates an rational constant term (scalar)
   * @param n numerator
   * @param d denominator
   * @returns a new term
   */
  static Term ConstComplex(num re, num im) {
    var t = new Term('#', [], []);
    t.value = Operand.createComplex(re, im);
    return t;
  }

  /**
   * Creates a variable term
   * @param id variable identifier
   * @returns
   */
  static Term Var(String id) {
    var t = new Term('\$', [], []);
    t.value = Operand.createIdentifier(id);
    return t;
  }

  /**
   * Creates an exact copy of this
   * @returns clone
   */
  Term clone() {
    var c = new Term(this.op, [], []);
    c.value = this.value;
    for (var i = 0; i < this.o.length; i++) {
      var oi = this.o[i];
      c.o.add(oi.clone());
    }
    return c;
  }

  /**
   * Evaluates the term or throws an exception, if any variable has an unknown
   * value
   * @param varValues dictionary that substitutes variables by constants, e.g. {x:5,y:7}
   * @returns the numeric evaluated result
   */
  Operand eval(Map<String, Operand> varValues) {
    return evalTerm(this, varValues);
  }

  num getBuiltInValue(String id) {
    switch (id) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
      default:
        throw new Exception('getBuildInValue(..): unimplemented symbol ' + id);
    }
  }

  /**
   * Symbolic differentiation. The resulting term is not optimized.
   * The caller should also call "opt()" after "diff(..)".
   * @param varId derivation variable
   * @returns symbolic differentiated term
   */
  Term diff(String varId) {
    return diffTerm(this, varId);
  }

  /**
   * Integrates a definite integral numerically
   * @param varId variable identifier
   * @param a lower bound
   * @param b upper bound
   * @param h step width
   * @returns approximated integral
   */
  num integrate(String varId, num a, num b, [num h = 1e-12]) {
    // TODO: trapezoidal rule!
    num r = 0;
    for (var x = a; x <= b; x += h) {
      var y = this.eval({varId: Operand.createReal(x)});
      // TODO: check t.type!
      r += y.real;
    }
    return r / h;
  }

  /**
   * Returns an optimized representation of the term that is algebraically
   * equivalent (e.g. "x+2+3*4+5*x" -> "14+6*x").
   * @returns optimized representation of the term
   */
  Term optimize() {
    return optTerm(this);
  }

  bool compareNumerically(Term t, [num epsilon = 1e-12]) {
    // TODO: only use variable values that result in "small" eval values
    var varIds = new Set<String>();
    varIds.addAll(this.getVariableIDs());
    varIds.addAll(t.getVariableIDs());
    var n = varIds.length == 0 ? 1 : 10; // number of tests: TODO: customize!
    for (var k = 0; k < n; k++) {
      Map<String, Operand> varValues = {};
      // TODO: currently testing only real values here!!!!!!!!!!
      for (var varId in varIds)
        varValues[varId] =
            Operand.createReal(math.Random().nextDouble()); // TODO: range!
      var u = this.eval(varValues);
      var v = t.eval(varValues);
      if (Operand.compareEqual(u, v, epsilon) == false) {
        return false;
      }
    }
    return true;
  }

  void substituteVariableByOperand(String id, Operand o) {
    if (this.op == '\$' && this.value.id == id) {
      this.op = '#';
      this.value = o.clone();
    }
    for (var i = 0; i < this.o.length; i++) {
      var oi = this.o[i];
      oi.substituteVariableByOperand(id, o);
    }
  }

  void substituteVariableByTerm(String id, Term t) {
    if (this.op == '\$' && this.value.id == id) {
      this.op = t.op;
      this.o = t.o;
      this.value = t.value.clone();
    }
    for (var i = 0; i < this.o.length; i++) {
      var oi = this.o[i];
      oi.substituteVariableByTerm(id, t);
    }
  }

  /**
   * Returns the set of variable IDs that are actually used in the term.
   * @returns variable IDs a string
   */
  Set<String> getVariableIDs() {
    var vars = new Set<String>();
    if (this.op == '\$') vars.add(this.value.id);
    for (var i = 0; i < this.o.length; i++) {
      var oi = this.o[i];
      vars = new Set<String>();
      vars.addAll(vars);
      vars.addAll(oi.getVariableIDs());
    }
    return vars;
  }

  /**
   * Converts the term object to a string.
   * @returns stringified representation of term
   */
  @override
  String toString() {
    return term2string(this);
  }
}

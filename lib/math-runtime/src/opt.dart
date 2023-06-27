/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'operand.dart';
import 'tab.dart';
import 'term.dart';

Term optTerm(Term term) {
  // TODO: reorder operands before optimization!
  // return only cloned versions of term
  var t = term.clone();
  // run recursively
  for (var i = 0; i < t.o.length; i++) {
    t.o[i] = t.o[i].optimize();
  }
  // algebraic simplifications
  if (term.op == '+') {
    // aggregate all constant values
    List<Term> oNew = [];
    num c = 0;
    for (var i = 0; i < t.o.length; i++) {
      var oi = t.o[i];
      // TODO: RATIONAL
      if (oi.op == '#' &&
          (oi.value.type == OperandType.int ||
              oi.value.type == OperandType.real)) {
        c += oi.value.real;
      } else {
        oNew.add(oi);
      }
    }
    if (c.abs() > 1e-12) oNew.add(Term.createConstReal(c));
    if (oNew.length == 1) {
      return oNew[0];
    } else {
      return Term.createOp('+', oNew, []);
    }
  } else if (term.op == '*') {
    // aggregate all constant values
    List<Term> oNew = [];
    num c = 1;
    for (var i = 0; i < t.o.length; i++) {
      var oi = t.o[i];
      // T
      if (oi.op == '#' &&
          (oi.value.type == OperandType.int ||
              oi.value.type == OperandType.real)) {
        c *= oi.value.real;
      } else {
        oNew.add(oi);
      }
    }
    if (c.abs() < 1e-12) {
      // c == 0 -> return 0
      return Term.createConstInt(0);
    }
    var negative = false;
    if ((c + 1).abs() < 1e-12) {
      // c == -1 -> return -rest
      negative = true;
      // return TODO;
    } else if ((c - 1).abs() > 1e-12) {
      // c != 1 -> c * rest (otherwise: keep only rest)
      oNew.insert(0, Term.createConstReal(c));
    }
    Term? res;
    if (oNew.length == 1) {
      // only one operand
      res = oNew[0];
    } else {
      // two ore more operands -> create multiplication operation
      res = Term.createOp('*', oNew, []);
    }
    if (negative) {
      // '.-' := unary minus
      res = Term.createOp('.-', [res], []);
    }
    return res;
  } else if (term.op == '^' && term.o.length == 2) {
    // x^0 = 1
    if (term.o[1].op == '#' &&
        Operand.compareEqual(term.o[1].value, Operand.createInt(0))) {
      return Term.createConstInt(1);
    }
    // x^1 = x
    if (term.o[1].op == '#' &&
        Operand.compareEqual(term.o[1].value, Operand.createInt(1))) {
      return term.o[0];
    }
  } else if (term.op == 'sin' ||
      term.op == 'cos' ||
      term.op == 'tan' ||
      term.op == 'arg') {
    var arg = term.eval({}).real;
    var newTerm = number2Term(arg);
    if (newTerm != null) return newTerm;
  }
  // try to evaluate term
  try {
    // result is constant, if all operands are constant
    var v = t.eval({});
    if (v.type == OperandType.int || v.type == OperandType.rational) {
      return Term.createConst(v);
    }
  } catch (e) {
    // if t contains variables, an error is thrown.
    // In this case, the evaluation result is dismissed.
  }
  // return result
  return t;
}

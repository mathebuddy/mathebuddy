/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library math_runtime;

import 'dart:math' as math;

import 'operand.dart';
import 'term.dart';

// TODO: move all core implementations to operand.dart where possible

num rand(num min, num max, [bool excludeZero = false]) {
  var v = (math.Random().nextDouble() * (max - min + 1) + min).floor();
  while (excludeZero && v == 0) {
    v = (math.Random().nextDouble() * (max - min + 1) + min).floor();
  }
  return v;
}

Operand applyOperationPerItem(
    String op, Operand x_, Map<String, Operand> varValues) {
  for (var i = 0; i < x_.items.length; i++) {
    x_.items[i] =
        Term.createOp(op, [Term.createConst(x_.items[i])], []).eval(varValues);
  }
  return x_;
}

Operand evalTerm(Term term, Map<String, Operand> varValues) {
  switch (term.op) {
    case '+':
    case '-':
      {
        var res = term.o[0].eval(varValues);
        for (var i = 1; i < term.o.length; i++) {
          var o = term.o[i].eval(varValues);
          res = Operand.addSub(term.op, res, o);
        }
        return res;
      }
    case '*':
    case '/':
      {
        var res = term.o[0].eval(varValues);
        for (var i = 1; i < term.o.length; i++) {
          var o = term.o[i].eval(varValues);
          res = Operand.mulDiv(term.op, res, o);
        }
        return res;
      }
    case '.-':
      return Operand.unaryMinus(term.o[0].eval(varValues));
    case '!':
      return Operand.logicalNot(term.o[0].eval(varValues));
    case '^':
      return Operand.pow(term.o[0].eval(varValues), term.o[1].eval(varValues));
    case '==':
    case '!=':
    case '<':
    case '<=':
    case '>':
    case '>=':
      return Operand.relationalOrEqual(
        term.op,
        term.o[0].eval(varValues),
        term.o[1].eval(varValues),
      );
    case '&&':
      return Operand.logicalAnd(
          term.o[0].eval(varValues), term.o[1].eval(varValues));
    case '||':
      return Operand.logicalOr(
          term.o[0].eval(varValues), term.o[1].eval(varValues));
    case '#':
      return term.value;
    case 'arg':
      {
        // TODO: must reimplment more dynamically...
        var o = term.o[0].eval(varValues);
        var eps = 1e-12; // TODO
        switch (o.type) {
          case OperandType.int:
          case OperandType.real:
          case OperandType.rational:
          case OperandType.irrational:
            return Operand.createInt(0);
          case OperandType.complex:
            var x = o.items[0]; // real
            var y = o.items[1]; // imag
            num xValue = 0.0;
            num yValue = 0.0;
            // TODO: vector, matrix, ...
            switch (x.type) {
              case OperandType.int:
              case OperandType.real:
              case OperandType.irrational:
                xValue = x.real;
                break;
              case OperandType.rational:
                xValue = x.real / x.denominator;
                break;
              default:
                throw Exception('function "arg" has invalid real part.');
            }
            switch (y.type) {
              case OperandType.int:
              case OperandType.real:
              case OperandType.irrational:
                yValue = y.real;
                break;
              case OperandType.rational:
                yValue = y.real / y.denominator;
                break;
              default:
                throw Exception('function "arg" has invalid imaginary part.');
            }
            var xZero = xValue.abs() < eps;
            var yZero = yValue.abs() < eps;
            var phi = 0.0;
            if (xZero && yZero) {
              throw Exception('function "arg" is undefined for value 0.');
            } else {
              phi = math.atan2(yValue, xValue);
              return Operand.createReal(phi);
            }
          default:
            throw Exception('argument of "arg" must be complex');
        }
      }
    case 'conj':
      {
        var o = term.o[0].eval(varValues);
        if (o.type == OperandType.complex) {
          //return Operand.createComplex(o.real, -o.imag);
          return Operand.createComplex(
              o.items[0], Operand.unaryMinus(o.items[1]));
        } else {
          return o;
        }
      }
    case 'sin':
    case 'cos':
    case 'tan':
    case 'asin':
    case 'acos':
    case 'atan':
    case 'exp':
    case 'ln':
      {
        var o = term.o[0].eval(varValues);

        if (o.type == OperandType.complex && term.op == 'exp') {
          // TODO: the following code is partly a duplicate in this file...
          var x = o.items[0]; // real
          var y = o.items[1]; // imag
          num xValue = 0.0;
          num yValue = 0.0;
          // TODO: vector, matrix, ...
          switch (x.type) {
            case OperandType.int:
            case OperandType.real:
            case OperandType.irrational:
              xValue = x.real;
              break;
            case OperandType.rational:
              xValue = x.real / x.denominator;
              break;
            default:
              throw Exception('function "arg" has invalid real part.');
          }
          switch (y.type) {
            case OperandType.int:
            case OperandType.real:
            case OperandType.irrational:
              yValue = y.real;
              break;
            case OperandType.rational:
              yValue = y.real / y.denominator;
              break;
            default:
              throw Exception('function "arg" has invalid imaginary part.');
          }
          return Operand.createComplex(
              // e^z = e^x*cos(y) + i * e^x*sin(y)
              Operand.createReal(math.exp(xValue) * math.cos(yValue)),
              Operand.createReal(math.exp(xValue) * math.sin(yValue)));
        }

        num v = 0;
        if (o.type == OperandType.int || o.type == OperandType.real) {
          v = o.real;
        } else if (o.type == OperandType.rational) {
          v = o.real / o.denominator;
        } else if (o.type == OperandType.irrational) {
          v = Operand.getBuiltInValue(o.text);
        } else {
          throw Exception(
              'Cannot apply type ${o.type.name} for function ${term.op}.');
        }
        switch (term.op) {
          case 'sin':
            return Operand.createReal(math.sin(v));
          case 'cos':
            return Operand.createReal(math.cos(v));
          case 'tan':
            return Operand.createReal(math.tan(v));
          case 'asin':
            return Operand.createReal(math.asin(v));
          case 'acos':
            return Operand.createReal(math.acos(v));
          case 'atan':
            return Operand.createReal(math.atan(v));
          case 'exp':
            return Operand.createReal(math.exp(v));
          case 'ln':
            return Operand.createReal(math.log(v));
          default:
            throw Exception('Unimplemented eval for ${term.op}.');
        }
      }
    case 'len':
      {
        var x = term.o[0].eval(varValues);
        switch (x.type) {
          case OperandType.set:
          case OperandType.vector:
            return Operand.createInt(x.items.length);
          default:
            throw Exception(
              'Argument type "${x.type}" of "${term.op}" is invalid.',
            );
        }
      }
    case 'rows':
    case 'cols':
      {
        var x = term.o[0].eval(varValues);
        switch (x.type) {
          case OperandType.matrix:
            {
              if (term.op == 'rows') {
                return Operand.createInt(x.rows);
              } else {
                return Operand.createInt(x.cols);
              }
            }
          default:
            throw Exception(
              'Argument type "${x.type}" of "${term.op}" is invalid.',
            );
        }
      }
    case 'min':
    case 'max':
      {
        // TODO: vector, matrix, ...
        var x = term.o[0].eval(varValues);
        switch (x.type) {
          case OperandType.set:
            {
              num mVal = term.op == 'min' ? double.infinity : -double.infinity;
              var m = Operand.createReal(mVal);
              for (var k = 0; k < x.items.length; k++) {
                var i = x.items[k];
                switch (i.type) {
                  case OperandType.int:
                  case OperandType.real:
                  case OperandType.rational:
                    {
                      var value = i.real;
                      if (i.type == OperandType.rational) {
                        value /= i.denominator;
                      }
                      if (term.op == 'max' && value > mVal) {
                        mVal = value;
                        m = i;
                      } else if (term.op == 'min' && value < mVal) {
                        mVal = value;
                        m = i;
                      }
                      break;
                    }
                  default:
                    throw Exception(
                      'Not allowed to calculate "${term.op}" for'
                      ' type ${i.type}.',
                    );
                }
              }
              return m.clone();
            }
          default:
            throw Exception(
              'Argument type "${x.type}" of "${term.op}" is invalid.',
            );
        }
      }
    case 'sqrt':
      {
        // TODO: algebraic solutions; e.g. sqrt(8) = 2*sqrt(2)
        // TODO: always(!) store algebraic and numeric solution
        var x = term.o[0].eval(varValues);
        switch (x.type) {
          case OperandType.int:
          case OperandType.real:
            if (x.real >= 0) {
              return Operand.createReal(math.sqrt(x.real));
            } else {
              return Operand.createSet([
                Operand.createComplex(Operand.createInt(0),
                    Operand.createReal(-math.sqrt(-x.real))),
                Operand.createComplex(Operand.createInt(0),
                    Operand.createReal(math.sqrt(-x.real)))
              ]);
            }
          case OperandType.rational:
            {
              // TODO: negative
              num numerator = math.sqrt(x.real);
              num denominator = math.sqrt(x.denominator);
              var isNumeratorIntegral =
                  numerator is int || numerator == numerator.roundToDouble();
              var isDenominatorIntegral = denominator is int ||
                  denominator == denominator.roundToDouble();
              if (isNumeratorIntegral && isDenominatorIntegral) {
                return Operand.createRational(numerator, denominator);
              } else {
                return Operand.createReal(numerator / denominator);
              }
            }
          default:
            throw Exception(
              'Argument type "${x.type}" of "${term.op}" is invalid.',
            );
        }
      }
    case 'abs':
      {
        var v = term.o[0].eval({});
        switch (v.type) {
          case OperandType.int:
            return Operand.createInt(v.real.abs());
          case OperandType.real:
            return Operand.createReal(v.real.abs());
          case OperandType.complex:
            {
              var x = v.items[0]; // real
              var y = v.items[1]; // imag
              num xValue = 0.0;
              num yValue = 0.0;
              // TODO: vector, matrix, ...
              switch (x.type) {
                case OperandType.int:
                case OperandType.real:
                case OperandType.irrational:
                  xValue = x.real;
                  break;
                case OperandType.rational:
                  xValue = x.real / x.denominator;
                  break;
                default:
                  throw Exception('function "abs" has invalid real part.');
              }
              switch (y.type) {
                case OperandType.int:
                case OperandType.real:
                case OperandType.irrational:
                  yValue = y.real;
                  break;
                case OperandType.rational:
                  yValue = y.real / y.denominator;
                  break;
                default:
                  throw Exception('function "abs" has invalid imaginary part.');
              }
              return Operand.createReal(
                  math.sqrt(xValue * xValue + yValue * yValue));
            }
          /**/
          default:
            throw Exception(
                'Function "abs(..)" invalid for type "${v.type.name}".');
        }
      }
    case 'binomial':
      {
        var n_ = term.o[0].eval(varValues);
        var k_ = term.o[1].eval(varValues);
        if (n_.type != OperandType.int || n_.type != OperandType.int) {
          throw Exception('Arguments of "${term.op}" must be integral.');
        }
        num n = n_.real;
        num k = k_.real;
        num b = 1;
        for (var i = n; i > n - k; i--) {
          b *= i;
        }
        for (var i = 1; i <= k; i++) {
          b /= i;
        }
        return Operand.createInt(b);
      }
    case 'fac':
      {
        var x_ = term.o[0].eval(varValues);
        if (x_.type != OperandType.int) {
          throw Exception('Arguments of "${term.op}" must be integral.');
        }
        var x = x_.real;
        var y = 1;
        for (var i = 1; i <= x; i++) {
          y *= i;
        }
        return Operand.createInt(y);
      }
    case 'ceil':
    case 'floor':
    case 'round':
      {
        var x_ = term.o[0].eval(varValues);
        if (x_.type == OperandType.vector || x_.type == OperandType.matrix) {
          return applyOperationPerItem(term.op, x_, varValues);
        } else if (x_.type != OperandType.int && x_.type != OperandType.real) {
          throw Exception('Argument of "${term.op}" must be integral or real,'
              ' but is of type "${x_.type}".');
        }
        var x = x_.real;
        switch (term.op) {
          case 'ceil':
            return Operand.createInt(x.ceil());
          case 'floor':
            return Operand.createInt(x.floor());
          case 'round':
            return Operand.createInt(x.round());
          default:
            throw Exception('unimplemented');
        }
      }
    case 'complex':
      {
        var x = term.o[0].eval(varValues);
        var y = term.o[1].eval(varValues);
        return Operand.createComplex(x, y);
      }
    case 'real':
    case 'imag':
      {
        var c = term.o[0].eval(varValues);
        if (c.type == OperandType.complex) {
          if (term.op == 'real') {
            return c.items[0];
          } else {
            return c.items[1];
          }
        }
        return c;
      }
    case 'eye':
      {
        if (term.dims.length != 1) {
          throw Exception('eye requires a dimension, e.g. "eye<3>()".');
        }
        var n = term.dims[0].eval(varValues);
        if (n.type != OperandType.int) {
          throw Exception('eye dimension must be integral.');
        }
        if (n.real < 1 || n.real > 100) {
          throw Exception('eye dimension must be in range 1..100.');
        }
        return Operand.eye(n.real.toInt());
      }
    case 'rand':
    case 'randZ':
    case 'zeros':
    case 'ones':
      {
        // rand(set)
        if (term.op != 'zeros' && term.op != 'ones' && term.o.length == 1) {
          var arg = term.o[0].eval(varValues);
          if (arg.type == OperandType.set) {
            var index = rand(0, arg.items.length - 1) as int;
            return arg.items[index];
          } else {
            throw Exception('argument of "${term.op}" must be a set.');
          }
        }
        //
        var min = Operand.createInt(0);
        var max = Operand.createInt(0);
        if (term.op == 'zeros') {
          // do nothing
        } else if (term.op == 'ones') {
          min = Operand.createInt(1);
          max = Operand.createInt(1);
        } else {
          // rand(min,max)
          min = term.o[0].eval(varValues);
          max = term.o[1].eval(varValues);
          if (min.type != OperandType.int || max.type != OperandType.int) {
            throw Exception('arguments of "${term.op}" must be integral.');
          }
          if (max.real < min.real) {
            throw Exception(
                'arguments of "${term.op}" must be in order (MIN,MAX).');
          }
        }
        // get and check dimension values
        var dimValues = [];
        for (var i = 0; i < term.dims.length; i++) {
          var n = term.dims[i].eval(varValues);
          if (n.type != OperandType.int) {
            throw Exception('rand dimension must be integral.');
          }
          if (n.real < 1 || n.real > 100) {
            throw Exception('rand dimensions must be in range 1..100.');
          }
          dimValues.add(n);
        }
        // eval
        switch (dimValues.length) {
          case 0:
            {
              return Operand.createInt(
                rand(min.real, max.real, term.op == 'randZ'),
              );
            }
          case 1:
            {
              var n = dimValues[0].real as int;
              List<Operand> operands = [];
              for (var i = 0; i < n; i++) {
                operands.add(Operand.createInt(
                  rand(min.real, max.real, term.op == 'randZ'),
                ));
              }
              var o = Operand.createVector(operands);
              return o;
            }
          case 2:
            {
              var rows = dimValues[0];
              var cols = dimValues[1];
              var o = Operand.createMatrix(rows.real as int, cols.real as int);
              var n = rows.real * cols.real;
              for (var i = 0; i < n; i++) {
                o.items[i] = Operand.createInt(
                  rand(min.real, max.real, term.op == 'randZ'),
                );
              }
              return o;
            }
          default:
            throw Exception('rand(..) permits no more than two dimensions.');
        }
      }
    case '\$':
      {
        if (varValues.containsKey(term.value.text)) {
          return varValues[term.value.text] as Operand;
        } else {
          throw Exception('eval(..): unset variable "${term.value}".');
        }
      }
    case 'set':
      {
        List<Operand> elements = [];
        for (var i = 0; i < term.o.length; i++) {
          var oi = term.o[i];
          elements.add(oi.eval(varValues));
        }
        var s = Operand.createSet(elements);
        return s;
      }
    case 'vec':
      {
        List<Operand> elements = [];
        for (var i = 0; i < term.o.length; i++) {
          var oi = term.o[i];
          elements.add(oi.eval(varValues));
        }
        var v = Operand.createVector(elements);
        return v;
      }
    case 'matrix':
      {
        List<Operand> rows = [];
        for (var i = 0; i < term.o.length; i++) {
          var oi = term.o[i];
          rows.add(oi.eval(varValues));
        }
        var numRows = rows.length;
        var numCols = -1;
        for (var i = 0; i < rows.length; i++) {
          var row = rows[i];
          if (numCols == -1) {
            numCols = row.items.length;
          } else if (numCols != row.items.length) {
            throw Exception('eval(..): rows have different lengths.');
          }
        }
        var m = Operand.createMatrix(numRows, numCols);
        m.items = [];
        for (var i = 0; i < rows.length; i++) {
          var row = rows[i];
          for (var j = 0; j < row.items.length; j++) {
            var e = row.items[j];
            m.items.add(e);
          }
        }
        return m;
      }
    case 'index1':
      {
        // 1-dim index
        var o = term.o[0].eval(varValues);
        var idx = term.o[1].eval(varValues);
        if (idx.type != OperandType.int) {
          throw Exception('eval(..): index must be integral.');
        }
        var idxValue = idx.real.toInt();
        if (o.type == OperandType.vector) {
          // get vector element
          if (idxValue < 0 || idxValue >= o.items.length) {
            throw Exception('eval(..): invalid index $idxValue.');
          }
          return o.items[idxValue];
        } else if (o.type == OperandType.matrix) {
          // get matrix row
          if (idxValue < 0 || idxValue >= o.rows) {
            throw Exception('eval(..): invalid index $idxValue.');
          }
          List<Operand> elements = [];
          for (var j = 0; j < o.cols; j++) {
            elements.add(o.items[idxValue * o.cols + j]);
          }
          return Operand.createVector(elements);
        } else {
          throw Exception('eval(..): type ${o.type} is not indexable.');
        }
      }
    case 'index2':
      {
        // 2-dim index
        var o = term.o[0].eval(varValues);
        var idx1 = term.o[1].eval(varValues);
        var idx2 = term.o[2].eval(varValues);
        if (idx1.type != OperandType.int || idx2.type != OperandType.int) {
          throw Exception('eval(..): index must be integral.');
        }
        var idx1Value = idx1.real.toInt();
        var idx2Value = idx2.real.toInt();
        if (o.type == OperandType.matrix) {
          // get matrix element
          if (idx1Value < 0 ||
              idx1Value >= o.rows ||
              idx2Value < 0 ||
              idx2Value >= o.cols) {
            throw Exception('eval(..): invalid index $idx1Value,$idx2Value.');
          }
          return o.items[idx1Value * o.cols + idx2Value];
        } else {
          throw Exception('eval(..): type ${o.type} is not indexable.');
        }
      }
    case 'col':
    case 'row':
      {
        var mat = term.o[0].eval(varValues);
        var idx = term.o[1].eval(varValues);
        if (term.op == 'col') {
          return Operand.col(mat, idx);
        } else {
          return Operand.row(mat, idx);
        }
      }
    case 'transpose':
      {
        var o = term.o[0].eval(varValues);
        return Operand.transpose(o);
      }
    case 'dot':
      {
        var u = term.o[0].eval(varValues);
        var v = term.o[1].eval(varValues);
        return Operand.dot(u, v);
      }
    case 'cross':
      {
        var u = term.o[0].eval(varValues);
        var v = term.o[1].eval(varValues);
        return Operand.cross(u, v);
      }
    case 'det':
      {
        var o = term.o[0].eval(varValues);
        return Operand.det(o);
      }
    case 'shuffle':
      {
        var o = term.o[0].eval(varValues);
        return Operand.shuffle(o);
      }
    case 'triu':
      {
        var o = term.o[0].eval(varValues);
        return Operand.triu(o);
      }
    case 'is_zero':
      {
        var o = term.o[0].eval(varValues);
        return Operand.createBoolean(Operand.isZero(o));
      }
    case 'is_symmetric':
      {
        var o = term.o[0].eval(varValues);
        return Operand.createBoolean(Operand.isSymmetric(o));
      }
    case 'is_invertible':
      {
        var o = term.o[0].eval(varValues);
        return Operand.createBoolean(Operand.isInvertible(o));
      }
    case 'norm':
      {
        var o = term.o[0].eval(varValues);
        return Operand.norm(o);
      }
    default:
      throw Exception('eval(..): unimplemented operator "${term.op}".');
  }
}

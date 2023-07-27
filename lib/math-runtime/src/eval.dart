/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math' as math;

import 'operand.dart';
import 'term.dart';

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
            return Operand.createInt(x.items.length);
          default:
            throw Exception(
              'Argument type "${x.type}" of "${term.op}" is invalid.',
            );
        }
      }
    case 'min':
    case 'max':
      {
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
            return Operand.createReal(math.sqrt(x.real));
          case OperandType.rational:
            {
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
        /*if ((x_.type != OperandType.int && x_.type != OperandType.real) ||
            (y_.type != OperandType.int && y_.type != OperandType.real)) {
          throw Exception(
              'Arguments of "${term.op}" must be integral or real.');
        }
        var x = x_.real;
        var y = y_.real;
        return Operand.createComplex(x, y);*/
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
        /*if (c.type != OperandType.complex) {
          throw Exception(
              'arguments of "${term.op}" must be integral or real.');
        }
        switch (term.op) {
          case 'real':
            return Operand.createReal(c.real);
          case 'imag':
            return Operand.createReal(c.imag);
          default:
            throw Exception('unimplemented');
        }*/
      }
    case 'rand':
    case 'randZ':
      {
        if (term.o.length == 1) {
          // rand(set)
          var arg = term.o[0].eval(varValues);
          if (arg.type == OperandType.set) {
            var index = rand(0, arg.items.length - 1) as int;
            return arg.items[index];
          } else {
            throw Exception('argument of "${term.op}" must be a set.');
          }
        } else {
          // rand(min,max)
          var min = term.o[0].eval(varValues);
          var max = term.o[1].eval(varValues);
          if (min.type != OperandType.int || max.type != OperandType.int) {
            throw Exception('arguments of "${term.op}" must be integral.');
          }
          if (max.real < min.real) {
            throw Exception(
                'arguments of "${term.op}" must be in order (MIN,MAX).');
          }
          switch (term.dims.length) {
            case 0:
              {
                return Operand.createInt(
                  rand(min.real, max.real, term.op == 'randZ'),
                );
              }
            case 1:
              {
                throw Exception('rand with 1 dims is unimplemented.');
              }
            case 2:
              {
                var rows = term.dims[0].eval(varValues);
                if (rows.type != OperandType.int) {
                  throw Exception('rand dimensions must be integral.');
                }
                var cols = term.dims[1].eval(varValues);
                if (cols.type != OperandType.int) {
                  throw Exception('rand dimensions must be integral.');
                }
                var o =
                    Operand.createMatrix(rows.real as int, cols.real as int);
                var n = rows.real * cols.real;
                for (var i = 0; i < n; i++) {
                  o.items[i] = Operand.createInt(
                    rand(min.real, max.real, term.op == 'randZ'),
                  );
                }
                return o;
              }
            default:
              throw Exception('rand requires max two dimensions.');
          }
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
    default:
      throw Exception('eval(..): unimplemented operator "${term.op}".');
  }
}

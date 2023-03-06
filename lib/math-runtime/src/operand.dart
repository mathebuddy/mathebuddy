/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math' as math;

import 'algo.dart';

enum OperandType {
  boolean,
  int,
  rational,
  real,
  irrational,
  complex,
  vector,
  matrix,
  set,
  identifier
}

class Operand {
  OperandType type = OperandType.real;
  num real =
      0; // also used for type BOOLEAN, then 0 is false and true otherwise
  num denominator = 1; // used for type RATIONAL
  num imag = 0;
  int rows = 1;
  int cols = 1;
  String id = ''; // used for IDENTIFIER and IRRATIONAL ("pi","e",...)
  List<Operand> items = []; // vector, set, matrix elements

  Operand clone() {
    var c = Operand();
    c.type = type;
    c.real = real;
    c.denominator = denominator;
    c.imag = imag;
    c.rows = rows;
    c.cols = cols;
    c.id = id;
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      c.items.add(item.clone());
    }
    return c;
  }

  static bool compareEqual(Operand x, Operand y, [num epsilon = 1e-12]) {
    // TODO: improve implementation of this method mathematically!
    if ((x.type == OperandType.int ||
            x.type == OperandType.real ||
            x.type == OperandType.complex) &&
        (y.type == OperandType.int ||
            y.type == OperandType.real ||
            y.type == OperandType.complex)) {
      if ((x.real - y.real).abs() > epsilon) return false;
      if ((x.imag - y.imag).abs() > epsilon) return false;
      return true;
    } else if (x.type != y.type) {
      return false;
    }
    switch (x.type) {
      case OperandType.set:
        if (x.items.length != y.items.length) return false;
        for (var i = 0; i < x.items.length; i++) {
          var found = false;
          for (var j = 0; j < y.items.length; j++) {
            if (Operand.compareEqual(x.items[i], y.items[j])) {
              found = true;
              break;
            }
          }
          if (found == false) return false;
        }
        break;
      case OperandType.matrix:
        if (x.rows != y.rows || x.cols != y.cols) return false;
        for (var i = 0; i < x.items.length; i++) {
          if (Operand.compareEqual(x.items[i], y.items[i]) == false) {
            return false;
          }
        }
        break;
      default:
        throw Exception(
          'Operand.compareEqual(..): unimplemented type ${x.type.name}',
        );
    }
    return true;
  }

  static Operand createInt(num x) {
    // TODO: check, if x is integral
    var o = Operand();
    o.type = OperandType.int;
    o.real = x;
    return o;
  }

  static Operand createReal(num x) {
    if (x is int || x == x.roundToDouble()) return Operand.createInt(x);
    var o = Operand();
    o.type = OperandType.real;
    o.real = x;
    return o;
  }

  static Operand createIrrational(String irr) {
    var o = Operand();
    o.type = OperandType.irrational;
    if (['pi', 'e'].contains(irr) == false) {
      throw Exception('Operand.createIrrational(..): unknown symbol $irr');
    }
    o.id = irr;
    return o;
  }

  static Operand createIrrationalE() {
    var o = Operand();
    o.type = OperandType.irrational;
    o.id = 'e';
    return o;
  }

  static Operand createRational(num n, num d) {
    var o = Operand();
    o.type = OperandType.rational;
    o.real = n;
    o.denominator = d;
    o._reduce();
    return o;
  }

  static Operand createMatrix(int rows, int cols) {
    var o = Operand();
    o.type = OperandType.matrix;
    o.rows = rows;
    o.cols = cols;
    var n = rows * cols;
    for (var i = 0; i < n; i++) {
      o.items.add(Operand.createInt(0));
    }
    return o;
  }

  void _reduce() {
    if (type != OperandType.rational) return;
    num d = gcd(real.round(), denominator.round());
    real /= d;
    denominator /= d;
    if (denominator < 0) {
      real = -real;
      denominator = -denominator;
    }
    if (denominator == 1) type = OperandType.int;
  }

  static Operand createComplex(num x, num y) {
    var o = Operand();
    o.type = OperandType.complex;
    o.real = x;
    o.imag = y;
    return o;
  }

  static Operand createSet(List<Operand> elements) {
    var o = Operand();
    o.type = OperandType.set;
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      var found = false;
      for (var j = 0; j < o.items.length; j++) {
        var item = o.items[j];
        if (Operand.compareEqual(element, item)) {
          found = true;
          break;
        }
      }
      if (!found) o.items.add(element);
    }
    return o;
  }

  static Operand createVector(List<Operand> element) {
    var o = Operand();
    o.type = OperandType.vector;
    o.items = [...element];
    return o;
  }

  static Operand createIdentifier(String str) {
    var o = Operand();
    o.type = OperandType.identifier;
    o.id = str;
    return o;
  }

  static Operand addSub(String operator, Operand x, Operand y) {
    if (['+', '-'].contains(operator) == false) {
      throw Exception('invalid operator $operator for addSub(..)');
    }
    var o = Operand();
    if (x.type == OperandType.int && y.type == OperandType.int) {
      o.type = OperandType.int;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
    } else if ((x.type == OperandType.int || x.type == OperandType.rational) &&
        (y.type == OperandType.int || y.type == OperandType.rational)) {
      o.type = OperandType.rational;
      if (operator == '+') {
        o.real = x.real * y.denominator + y.real * x.denominator;
      } else {
        o.real = x.real * y.denominator - y.real * x.denominator;
      }
      o.denominator = x.denominator * y.denominator;
      o._reduce();
    } else if ((x.type == OperandType.int || x.type == OperandType.real) &&
        (y.type == OperandType.int || y.type == OperandType.real)) {
      o.type = OperandType.real;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
    } else if ((x.type == OperandType.int ||
            x.type == OperandType.real ||
            x.type == OperandType.complex) &&
        (y.type == OperandType.int ||
            y.type == OperandType.real ||
            y.type == OperandType.complex)) {
      o.type = OperandType.complex;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
      o.imag = x.imag + (operator == '+' ? y.imag : -y.imag);
    } else if (x.type == OperandType.matrix && y.type == OperandType.matrix) {
      o.type = OperandType.matrix;
      if (x.rows != y.rows || x.cols != y.cols) {
        throw Exception('matrix dimensions not matching for +');
      }
      o.rows = x.rows;
      o.cols = x.cols;
      for (var i = 0; i < x.items.length; i++) {
        o.items.add(Operand.addSub(operator, x.items[i], y.items[i]));
      }
    } else {
      throw Exception(
          'cannot apply $operator on ${x.type.name} and ${y.type.name}');
    }
    return o;
  }

  static Operand unaryMinus(Operand x) {
    var o = x.clone();
    switch (x.type) {
      case OperandType.int:
      case OperandType.real:
      case OperandType.rational:
        o.real = -o.real;
        break;
      case OperandType.complex:
        o.real = -o.real;
        o.imag = -o.imag;
        break;
      case OperandType.matrix:
        for (var i = 0; i < o.items.length; i++) {
          o.items[i] = Operand.unaryMinus(o.items[i]);
        }
        break;
      default:
        throw Exception('cannot apply unary - on ${x.type.name}');
    }
    return o;
  }

  static Operand mulDiv(String operator, Operand x, Operand y) {
    if (['*', '/'].contains(operator) == false) {
      throw Exception('invalid operator $operator for mulDiv(..)');
    }
    var o = Operand();
    if (x.type == OperandType.int && y.type == OperandType.int) {
      o.type = OperandType.int;
      if (operator == '*') {
        o.real = x.real * y.real;
      } else {
        o = Operand.createRational(x.real, y.real);
      }
    } else if ((x.type == OperandType.int || x.type == OperandType.rational) &&
        (y.type == OperandType.int || y.type == OperandType.rational)) {
      o.type = OperandType.rational;
      if (operator == '*') {
        o.real = x.real * y.real;
        o.denominator = x.denominator * y.denominator;
      } else {
        o.real = x.real * y.denominator;
        o.denominator = x.denominator * y.real;
      }
      o._reduce();
    } else if ((x.type == OperandType.int || x.type == OperandType.real) &&
        (y.type == OperandType.int || y.type == OperandType.real)) {
      o.type = OperandType.real;
      if (operator == '*') {
        o.real = x.real * y.real;
      } else {
        o.real = x.real / y.real;
      }
    } else if (operator == '*' &&
        (x.type == OperandType.int ||
            x.type == OperandType.rational ||
            x.type == OperandType.real ||
            x.type == OperandType.complex) &&
        y.type == OperandType.matrix) {
      o.type = OperandType.matrix;
      o.rows = y.rows;
      o.cols = y.cols;
      for (var i = 0; i < y.items.length; i++) {
        o.items.add(Operand.mulDiv('*', x, y.items[i]));
      }
    } else if (operator == '*' &&
        x.type == OperandType.matrix &&
        (y.type == OperandType.int ||
            y.type == OperandType.rational ||
            y.type == OperandType.real ||
            y.type == OperandType.complex)) {
      o.type = OperandType.matrix;
      o.rows = y.rows;
      o.cols = y.cols;
      for (var i = 0; i < x.items.length; i++) {
        o.items.add(Operand.mulDiv('*', x.items[i], y));
      }
    } else if ((x.type == OperandType.int ||
            x.type == OperandType.real ||
            x.type == OperandType.complex) &&
        (y.type == OperandType.int ||
            y.type == OperandType.real ||
            y.type == OperandType.complex)) {
      o.type = OperandType.complex;
      if (operator == '*') {
        o.real = x.real * y.real - x.imag * y.imag;
        o.imag = x.real * y.imag + x.imag * y.real;
      } else {
        var n = Operand.mulDiv(
          '*',
          x,
          Operand.createComplex(y.real, -y.imag),
        );
        var d = y.real * y.real + y.imag * y.imag;
        o.real = n.real / d;
        o.imag = n.imag / d;
      }
    } else {
      throw Exception(
          'cannot apply $operator on ${x.type.name} and ${y.type.name}');
    }
    return o;
  }

  static Operand pow(Operand x, Operand y) {
    var o = Operand();
    if (x.type == OperandType.int && y.type == OperandType.int) {
      o.type = OperandType.int;
      o.real = math.pow(x.real, y.real);
    } else if (x.type == OperandType.rational && y.type == OperandType.int) {
      o.type = OperandType.rational;
      o.real = math.pow(x.real, y.real);
      o.denominator = math.pow(x.denominator, y.real);
      o._reduce();
    } else if ((x.type == OperandType.real || x.type == OperandType.complex) &&
        (y.type == OperandType.real || y.type == OperandType.complex)) {
      throw Exception('unimplemented');
    } else {
      throw Exception(
        'cannot apply ^ on ${x.type.name} and ${y.type.name}',
      );
    }
    return o;
  }

  static Operand relational(String op, Operand x, Operand y) {
    if (['<', '<=', '>', '>='].contains(op) == false) {
      throw Exception('invalid operator $op for relational(..)');
    }
    var o = Operand();
    o.type = OperandType.boolean;
    if ((x.type == OperandType.int ||
            x.type == OperandType.real ||
            x.type == OperandType.rational) &&
        (y.type == OperandType.int ||
            y.type == OperandType.real ||
            y.type == OperandType.rational)) {
      var u = x.real;
      var v = y.real;
      if (x.type == OperandType.rational) u /= x.denominator;
      if (y.type == OperandType.rational) v /= y.denominator;
      switch (op) {
        case '<':
          o.real = u < v ? 1 : 0;
          break;
        case '<=':
          o.real = u <= v ? 1 : 0;
          break;
        case '>':
          o.real = u >= v ? 1 : 0;
          break;
        case '>=':
          o.real = u >= v ? 1 : 0;
          break;
      }
    } else {
      throw Exception(
        'cannot apply $op on ${x.type.name} and ${y.type.name}',
      );
    }
    return o;
  }

  @override
  String toString() {
    switch (type) {
      case OperandType.boolean:
        return real == 0 ? 'false' : 'true';
      case OperandType.int:
      case OperandType.real:
        return real.toString();
      case OperandType.rational:
        return '${real.round()}/${denominator.round()}';
      case OperandType.complex:
        if (imag >= 0) {
          return '$real+${imag}i';
        } else {
          return '$real-${-imag}i';
        }
      case OperandType.set:
        return '{${items.map((x) => x.toString()).join(',')}}';
      case OperandType.identifier:
      case OperandType.irrational:
        return id;
      case OperandType.vector:
        {
          var s = '[';
          for (var i = 0; i < items.length; i++) {
            if (i > 0) s += ',';
            s += items[i].toString();
          }
          s += ']';
          return s;
        }
      case OperandType.matrix:
        {
          var s = '[';
          for (var i = 0; i < rows; i++) {
            if (i > 0) s += ',';
            s += '[';
            for (var j = 0; j < cols; j++) {
              if (j > 0) s += ',';
              s += items[i * cols + j].toString();
            }
            s += ']';
          }
          s += ']';
          return s;
        }
      default:
        throw Exception(
          'unimplemented Operand.toString() for type ${type.name}',
        );
    }
  }
}

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
  identifier,
  string,
}

class Operand {
  OperandType type = OperandType.real;
  num real =
      0; // also used for type BOOLEAN, then 0 is false and true otherwise
  num denominator = 1; // used for type RATIONAL
  num imag = 0;
  int rows = 1;
  int cols = 1;
  String text = ''; // used for IDENTIFIER and IRRATIONAL ("pi","e",...)
  List<Operand> items = []; // vector, set, matrix elements

  Operand clone() {
    var c = Operand();
    c.type = type;
    c.real = real;
    c.denominator = denominator;
    c.imag = imag;
    c.rows = rows;
    c.cols = cols;
    c.text = text;
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      c.items.add(item.clone());
    }
    return c;
  }

  static bool compareEqual(Operand x, Operand y, [num epsilon = 1e-12]) {
    // TODO: improve implementation of this method mathematically!

    if ((x.type == OperandType.boolean ||
            x.type == OperandType.int ||
            x.type == OperandType.real ||
            x.type == OperandType.complex) &&
        (y.type == OperandType.boolean ||
            y.type == OperandType.int ||
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
          'Operand.compareEqual(..): unimplemented type "${x.type.name}".',
        );
    }
    return true;
  }

  static Operand createBoolean(bool value) {
    var o = Operand(); // o := output
    o.type = OperandType.boolean;
    o.real = value ? 1 : 0;
    return o;
  }

  static Operand createInt(num x) {
    // TODO: check, if x is integral
    var o = Operand(); // o := output
    o.type = OperandType.int;
    o.real = x;
    return o;
  }

  static Operand createReal(num x) {
    var eps = 1e-14; // TODO
    if (x is int || (x - x.round()).abs() < eps) {
      return Operand.createInt(x.round());
    }
    var o = Operand(); // o := output
    o.type = OperandType.real;
    o.real = x;
    return o;
  }

  static Operand createIrrational(String irr) {
    var o = Operand(); // o := output
    o.type = OperandType.irrational;
    if (['pi', 'e'].contains(irr) == false) {
      throw Exception('Operand.createIrrational(..): unknown symbol "$irr".');
    }
    o.text = irr;
    return o;
  }

  static Operand createIrrationalE() {
    var o = Operand(); // o := output
    o.type = OperandType.irrational;
    o.text = 'e';
    return o;
  }

  static Operand createRational(num n, num d) {
    var o = Operand(); // o := output
    o.type = OperandType.rational;
    o.real = n;
    o.denominator = d;
    o._reduce();
    return o;
  }

  static Operand createMatrix(int rows, int cols) {
    var o = Operand(); // o := output
    o.type = OperandType.matrix;
    o.rows = rows;
    o.cols = cols;
    var n = rows * cols;
    for (var i = 0; i < n; i++) {
      o.items.add(Operand.createInt(0));
    }
    return o;
  }

  static Operand createString(String text) {
    var o = Operand(); // o := output
    o.type = OperandType.string;
    o.text = text;
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
    // TODO: create int or real, if applicable!
    var o = Operand(); // o := output
    o.type = OperandType.complex;
    o.real = x;
    o.imag = y;
    return o;
  }

  static Operand createSet(List<Operand> elements) {
    var o = Operand(); // o := output
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
    var o = Operand(); // o := output
    o.type = OperandType.vector;
    o.items = [...element];
    return o;
  }

  static Operand createIdentifier(String str) {
    var o = Operand(); // o := output
    o.type = OperandType.identifier;
    o.text = str;
    return o;
  }

  static Operand addSub(String operator, Operand x, Operand y) {
    if (['+', '-'].contains(operator) == false) {
      throw Exception('Invalid operator "$operator" for addSub(..).');
    }
    var o = Operand(); // o := output
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
    } else if (operator == '+' &&
        x.type == OperandType.rational &&
        y.type == OperandType.complex) {
      o = Operand.addSub(
          operator, Operand.createReal(o.real / o.denominator), y);
    } else if (x.type == OperandType.matrix && y.type == OperandType.matrix) {
      o.type = OperandType.matrix;
      if (x.rows != y.rows || x.cols != y.cols) {
        throw Exception('Matrix dimensions not matching for operator "+".');
      }
      o.rows = x.rows;
      o.cols = x.cols;
      for (var i = 0; i < x.items.length; i++) {
        o.items.add(Operand.addSub(operator, x.items[i], y.items[i]));
      }
    } else {
      throw Exception('Cannot apply operator "$operator" on'
          ' ${x.type.name} and ${y.type.name}.');
    }
    return o;
  }

  static Operand unaryMinus(Operand x) {
    var o = x.clone(); // o := output
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
      case OperandType.irrational:
        // TODO: this is not symbolic...
        o.type = OperandType.real;
        o.real = -Operand.getBuiltInValue(o.text);
        break;
      default:
        throw Exception('Cannot apply operator "unary -" on ${x.type.name}.');
    }
    return o;
  }

  static Operand mulDiv(String operator, Operand x, Operand y) {
    if (['*', '/'].contains(operator) == false) {
      throw Exception('Invalid operator "$operator" for mulDiv(..).');
    }
    var o = Operand(); // o := output
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
        x.type == OperandType.rational &&
        y.type == OperandType.complex) {
      o = Operand.mulDiv(
          operator, Operand.createReal(o.real / o.denominator), y);
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
      o.rows = x.rows;
      o.cols = x.cols;
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
    } else if (x.type == OperandType.matrix && y.type == OperandType.matrix) {
      o.type = OperandType.matrix;
      if (x.cols != y.rows) {
        throw Exception('Matrix dimensions not matching for operator "*".');
      }
      o.rows = x.rows;
      o.cols = y.cols;
      for (var i = 0; i < o.rows; i++) {
        for (var j = 0; j < o.cols; j++) {
          var idx = i * o.cols + j;
          o.items.add(Operand.createInt(0));
          for (var k = 0; k < x.cols; k++) {
            int a = i * x.cols + k;
            int b = k * y.cols + j;
            o.items[idx] = Operand.addSub(
                '+', o.items[idx], Operand.mulDiv('*', x.items[a], y.items[b]));
          }
        }
      }
    } else {
      throw Exception('Cannot apply operator "$operator" on "${x.type.name}"'
          ' and "${y.type.name}".');
    }
    return o;
  }

  static Operand pow(Operand x, Operand y) {
    var o = Operand(); // o := output
    if (x.type == OperandType.int && y.type == OperandType.int) {
      o.type = OperandType.int;
      o.real = math.pow(x.real, y.real).round();
    } else if (x.type == OperandType.rational && y.type == OperandType.int) {
      o.type = OperandType.rational;
      o.real = math.pow(x.real, y.real);
      o.denominator = math.pow(x.denominator, y.real);
      o._reduce();
    } else if ((x.type == OperandType.int || x.type == OperandType.real) &&
        (y.type == OperandType.int || y.type == OperandType.real)) {
      o.type = OperandType.real;
      o.real = math.pow(x.real, y.real);
    } else if (x.type == OperandType.complex &&
        (y.type == OperandType.int || y.type == OperandType.real)) {
      var r = math.sqrt(x.real * x.real + x.imag * x.imag);
      var phi = math.atan2(x.imag, x.real);
      r = math.pow(r, y.real).toDouble();
      phi *= y.real;
      var re = r * math.cos(phi);
      var im = r * math.sin(phi);
      o = Operand.createComplex(re, im);
    } else {
      throw Exception(
        'Cannot apply operator "^" on "${x.type.name}" and "${y.type.name}".',
      );
    }
    return o;
  }

  static Operand relational(String op, Operand x, Operand y) {
    if (['<', '<=', '>', '>='].contains(op) == false) {
      throw Exception('Invalid operator $op for relational(..).');
    }
    var o = Operand(); // o := output
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
        'Cannot apply $op on ${x.type.name} and ${y.type.name}.',
      );
    }
    return o;
  }

  static double getBuiltInValue(String id) {
    switch (id) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
      default:
        throw Exception('getBuildInValue(..): unimplemented symbol $id');
    }
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
        {
          var imagAbsStr = imag.abs().toString();
          if (imagAbsStr == "1") imagAbsStr = "";
          if (imag >= 0) {
            return '$real+${imagAbsStr}i';
          } else {
            return '$real-${imagAbsStr}i';
          }
        }
      case OperandType.set:
        return '{${items.map((x) => x.toString()).join(',')}}';
      case OperandType.identifier:
      case OperandType.irrational:
        return text;
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
      case OperandType.string:
        {
          return '"$text"';
        }
      default:
        throw Exception(
          'Unimplemented Operand.toString() for type ${type.name}.',
        );
    }
  }
}

/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:math' as math;

import 'algo.dart';

enum OperandType {
  BOOLEAN,
  INT,
  RATIONAL,
  REAL,
  IRRATIONAL,
  COMPLEX,
  VECTOR,
  MATRIX,
  SET,
  IDENTIFIER
}

class Operand {
  OperandType type = OperandType.REAL;
  num real =
      0; // also used for type BOOLEAN, then 0 is false and true otherwise
  num denominator = 1; // used for type RATIONAL
  num imag = 0;
  int rows = 1;
  int cols = 1;
  String id = ''; // used for IDENTIFIER and IRRATIONAL ("pi","e",...)
  List<Operand> items = []; // vector, set, matrix elements

  Operand clone() {
    var c = new Operand();
    c.type = this.type;
    c.real = this.real;
    c.denominator = this.denominator;
    c.imag = this.imag;
    c.rows = this.rows;
    c.cols = this.cols;
    c.id = this.id;
    for (var i = 0; i < this.items.length; i++) {
      var item = this.items[i];
      c.items.add(item.clone());
    }
    return c;
  }

  static bool compareEqual(Operand x, Operand y, [num epsilon = 1e-12]) {
    // TODO: improve implementation of this method mathematically!
    if ((x.type == OperandType.INT ||
            x.type == OperandType.REAL ||
            x.type == OperandType.COMPLEX) &&
        (y.type == OperandType.INT ||
            y.type == OperandType.REAL ||
            y.type == OperandType.COMPLEX)) {
      if ((x.real - y.real).abs() > epsilon) return false;
      if ((x.imag - y.imag).abs() > epsilon) return false;
      return true;
    } else if (x.type != y.type) {
      return false;
    }
    switch (x.type) {
      case OperandType.SET:
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
      case OperandType.MATRIX:
        if (x.rows != y.rows || x.cols != y.cols) return false;
        for (var i = 0; i < x.items.length; i++) {
          if (Operand.compareEqual(x.items[i], y.items[i]) == false)
            return false;
        }
        break;
      default:
        throw new Exception(
          'Operand.compareEqual(..): unimplemented type ' + x.type.name,
        );
    }
    return true;
  }

  static Operand createInt(num x) {
    // TODO: check, if x is integral
    var o = new Operand();
    o.type = OperandType.INT;
    o.real = x;
    return o;
  }

  static Operand createReal(num x) {
    if (x is int || x == x.roundToDouble()) return Operand.createInt(x);
    var o = new Operand();
    o.type = OperandType.REAL;
    o.real = x;
    return o;
  }

  static Operand createIrrational(String irr) {
    var o = new Operand();
    o.type = OperandType.IRRATIONAL;
    if (['pi', 'e'].contains(irr) == false)
      throw new Exception(
          'Operand.createIrrational(..): unknown symbol ' + irr);
    o.id = irr;
    return o;
  }

  static Operand createIrrationalE() {
    var o = new Operand();
    o.type = OperandType.IRRATIONAL;
    o.id = 'e';
    return o;
  }

  static Operand createRational(num n, num d) {
    var o = new Operand();
    o.type = OperandType.RATIONAL;
    o.real = n;
    o.denominator = d;
    o._reduce();
    return o;
  }

  static Operand createMatrix(int rows, int cols) {
    var o = new Operand();
    o.type = OperandType.MATRIX;
    o.rows = rows;
    o.cols = cols;
    var n = rows * cols;
    for (var i = 0; i < n; i++) {
      o.items.add(Operand.createInt(0));
    }
    return o;
  }

  void _reduce() {
    if (this.type != OperandType.RATIONAL) return;
    num d = gcd(this.real.round(), this.denominator.round());
    this.real /= d;
    this.denominator /= d;
    if (this.denominator < 0) {
      this.real = -this.real;
      this.denominator = -this.denominator;
    }
    if (this.denominator == 1) this.type = OperandType.INT;
  }

  static Operand createComplex(num x, num y) {
    var o = new Operand();
    o.type = OperandType.COMPLEX;
    o.real = x;
    o.imag = y;
    return o;
  }

  static Operand createSet(List<Operand> elements) {
    var o = new Operand();
    o.type = OperandType.SET;
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
    var o = new Operand();
    o.type = OperandType.VECTOR;
    o.items = [...element];
    return o;
  }

  static Operand createIdentifier(String str) {
    var o = new Operand();
    o.type = OperandType.IDENTIFIER;
    o.id = str;
    return o;
  }

  static Operand addSub(String operator, Operand x, Operand y) {
    if (['+', '-'].contains(operator) == false)
      throw new Exception('invalid operator ' + operator + ' for addSub(..)');
    var o = new Operand();
    if (x.type == OperandType.INT && y.type == OperandType.INT) {
      o.type = OperandType.INT;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
    } else if ((x.type == OperandType.INT || x.type == OperandType.RATIONAL) &&
        (y.type == OperandType.INT || y.type == OperandType.RATIONAL)) {
      o.type = OperandType.RATIONAL;
      if (operator == '+')
        o.real = x.real * y.denominator + y.real * x.denominator;
      else
        o.real = x.real * y.denominator - y.real * x.denominator;
      o.denominator = x.denominator * y.denominator;
      o._reduce();
    } else if ((x.type == OperandType.INT || x.type == OperandType.REAL) &&
        (y.type == OperandType.INT || y.type == OperandType.REAL)) {
      o.type = OperandType.REAL;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
    } else if ((x.type == OperandType.INT ||
            x.type == OperandType.REAL ||
            x.type == OperandType.COMPLEX) &&
        (y.type == OperandType.INT ||
            y.type == OperandType.REAL ||
            y.type == OperandType.COMPLEX)) {
      o.type = OperandType.COMPLEX;
      o.real = x.real + (operator == '+' ? y.real : -y.real);
      o.imag = x.imag + (operator == '+' ? y.imag : -y.imag);
    } else if (x.type == OperandType.MATRIX && y.type == OperandType.MATRIX) {
      o.type = OperandType.MATRIX;
      if (x.rows != y.rows || x.cols != y.cols)
        throw new Exception('matrix dimensions not matching for +');
      o.rows = x.rows;
      o.cols = x.cols;
      for (var i = 0; i < x.items.length; i++)
        o.items.add(Operand.addSub(operator, x.items[i], y.items[i]));
    } else {
      throw new Exception(
        'cannot apply ' +
            operator +
            ' on ' +
            x.type.name +
            ' and ' +
            y.type.name,
      );
    }
    return o;
  }

  static Operand unaryMinus(Operand x) {
    var o = x.clone();
    switch (x.type) {
      case OperandType.INT:
      case OperandType.REAL:
      case OperandType.RATIONAL:
        o.real = -o.real;
        break;
      case OperandType.COMPLEX:
        o.real = -o.real;
        o.imag = -o.imag;
        break;
      case OperandType.MATRIX:
        for (var i = 0; i < o.items.length; i++)
          o.items[i] = Operand.unaryMinus(o.items[i]);
        break;
      default:
        throw new Exception('cannot apply unary - on ' + x.type.name);
    }
    return o;
  }

  static Operand mulDiv(String operator, Operand x, Operand y) {
    if (['*', '/'].contains(operator) == false)
      throw new Exception('invalid operator ' + operator + ' for mulDiv(..)');
    var o = new Operand();
    if (x.type == OperandType.INT && y.type == OperandType.INT) {
      o.type = OperandType.INT;
      if (operator == '*')
        o.real = x.real * y.real;
      else
        o = Operand.createRational(x.real, y.real);
    } else if ((x.type == OperandType.INT || x.type == OperandType.RATIONAL) &&
        (y.type == OperandType.INT || y.type == OperandType.RATIONAL)) {
      o.type = OperandType.RATIONAL;
      if (operator == '*') {
        o.real = x.real * y.real;
        o.denominator = x.denominator * y.denominator;
      } else {
        o.real = x.real * y.denominator;
        o.denominator = x.denominator * y.real;
      }
      o._reduce();
    } else if ((x.type == OperandType.INT || x.type == OperandType.REAL) &&
        (y.type == OperandType.INT || y.type == OperandType.REAL)) {
      o.type = OperandType.REAL;
      if (operator == '*')
        o.real = x.real * y.real;
      else
        o.real = x.real / y.real;
    } else if (operator == '*' &&
        (x.type == OperandType.INT ||
            x.type == OperandType.RATIONAL ||
            x.type == OperandType.REAL ||
            x.type == OperandType.COMPLEX) &&
        y.type == OperandType.MATRIX) {
      o.type = OperandType.MATRIX;
      o.rows = y.rows;
      o.cols = y.cols;
      for (var i = 0; i < y.items.length; i++)
        o.items.add(Operand.mulDiv('*', x, y.items[i]));
    } else if (operator == '*' &&
        x.type == OperandType.MATRIX &&
        (y.type == OperandType.INT ||
            y.type == OperandType.RATIONAL ||
            y.type == OperandType.REAL ||
            y.type == OperandType.COMPLEX)) {
      o.type = OperandType.MATRIX;
      o.rows = y.rows;
      o.cols = y.cols;
      for (var i = 0; i < x.items.length; i++)
        o.items.add(Operand.mulDiv('*', x.items[i], y));
    } else if ((x.type == OperandType.INT ||
            x.type == OperandType.REAL ||
            x.type == OperandType.COMPLEX) &&
        (y.type == OperandType.INT ||
            y.type == OperandType.REAL ||
            y.type == OperandType.COMPLEX)) {
      o.type = OperandType.COMPLEX;
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
      throw new Exception(
        'cannot apply ' +
            operator +
            ' on ' +
            x.type.name +
            ' and ' +
            y.type.name,
      );
    }
    return o;
  }

  static Operand pow(Operand x, Operand y) {
    var o = new Operand();
    if (x.type == OperandType.INT && y.type == OperandType.INT) {
      o.type = OperandType.INT;
      o.real = math.pow(x.real, y.real);
    } else if (x.type == OperandType.RATIONAL && y.type == OperandType.INT) {
      o.type = OperandType.RATIONAL;
      o.real = math.pow(x.real, y.real);
      o.denominator = math.pow(x.denominator, y.real);
      o._reduce();
    } else if ((x.type == OperandType.REAL || x.type == OperandType.COMPLEX) &&
        (y.type == OperandType.REAL || y.type == OperandType.COMPLEX)) {
      throw new Exception('unimplemented');
    } else {
      throw new Exception(
        'cannot apply ' + '^' + ' on ' + x.type.name + ' and ' + y.type.name,
      );
    }
    return o;
  }

  static Operand relational(String op, Operand x, Operand y) {
    if (['<', '<=', '>', '>='].contains(op) == false)
      throw new Exception('invalid operator ' + op + ' for relational(..)');
    var o = new Operand();
    o.type = OperandType.BOOLEAN;
    if ((x.type == OperandType.INT ||
            x.type == OperandType.REAL ||
            x.type == OperandType.RATIONAL) &&
        (y.type == OperandType.INT ||
            y.type == OperandType.REAL ||
            y.type == OperandType.RATIONAL)) {
      var u = x.real;
      var v = y.real;
      if (x.type == OperandType.RATIONAL) u /= x.denominator;
      if (y.type == OperandType.RATIONAL) v /= y.denominator;
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
      throw new Exception(
        'cannot apply ' + op + ' on ' + x.type.name + ' and ' + y.type.name,
      );
    }
    return o;
  }

  @override
  String toString() {
    switch (this.type) {
      case OperandType.BOOLEAN:
        return '' + (this.real == 0 ? 'false' : 'true');
      case OperandType.INT:
      case OperandType.REAL:
        return '' + this.real.toString();
      case OperandType.RATIONAL:
        return this.real.round().toString() +
            '/' +
            this.denominator.round().toString();
      case OperandType.COMPLEX:
        if (this.imag >= 0)
          return '' + this.real.toString() + '+' + this.imag.toString() + 'i';
        else
          return '' +
              this.real.toString() +
              '-' +
              (-this.imag).toString() +
              'i';
      case OperandType.SET:
        return '{' + this.items.map((x) => x.toString()).join(',') + '}';
      case OperandType.IDENTIFIER:
      case OperandType.IRRATIONAL:
        return this.id;
      case OperandType.VECTOR:
        {
          var s = '[';
          for (var i = 0; i < this.items.length; i++) {
            if (i > 0) s += ',';
            s += this.items[i].toString();
          }
          s += ']';
          return s;
        }
      case OperandType.MATRIX:
        {
          var s = '[';
          for (var i = 0; i < this.rows; i++) {
            if (i > 0) s += ',';
            s += '[';
            for (var j = 0; j < this.cols; j++) {
              if (j > 0) s += ',';
              s += this.items[i * this.cols + j].toString();
            }
            s += ']';
          }
          s += ']';
          return s;
        }
      default:
        throw new Exception(
          'unimplemented Operand.toString() for type ' + this.type.name,
        );
    }
  }
}

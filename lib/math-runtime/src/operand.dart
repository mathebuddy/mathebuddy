/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// NOTE: Symbolic computing is limited in the math engine.
///       Only constants (like PI) may have type IRRATIONAL.
///       All numeric computations result in type REAL instead of IRRATIONAL.
///       For symbolic computing, we use type TERM (e.g. "2*PI") or just
///       the approximate value 6.2831853072.

import 'dart:math' as math;

import 'algo.dart';
import 'help.dart';

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
  //num imag = 0;
  int rows = 1; // used for type MATRIX
  int cols = 1; // used for type MATRIX
  String text = ''; // used for IDENTIFIER and IRRATIONAL ("pi","e",...)
  List<Operand> items = []; // vector, set, matrix elements; real+imag for cmplx

  Operand clone() {
    var c = Operand();
    c.type = type;
    c.real = real;
    c.denominator = denominator;
    //c.imag = imag;
    c.rows = rows;
    c.cols = cols;
    c.text = text;
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      c.items.add(item.clone());
    }
    return c;
  }

  static bool compareEqual(Operand x, Operand y, [num epsilon = 1e-9]) {
    // TODO: improve implementation of this method mathematically!

    if ((x.type == OperandType.boolean ||
            x.type == OperandType.int ||
            x.type == OperandType.rational ||
            x.type == OperandType.real ||
            //x.type == OperandType.complex ||
            x.type == OperandType.irrational) &&
        (y.type == OperandType.boolean ||
            y.type == OperandType.int ||
            y.type == OperandType.rational ||
            y.type == OperandType.real ||
            //y.type == OperandType.complex ||
            x.type == OperandType.irrational)) {
      var xReal = x.real;
      //var xImag = x.imag;
      var yReal = y.real;
      //var yImag = y.imag;
      if (x.type == OperandType.rational) {
        xReal /= x.denominator;
      }
      if (y.type == OperandType.rational) {
        yReal /= y.denominator;
      }
      if ((xReal - yReal).abs() > epsilon) return false;
      //if ((xImag - yImag).abs() > epsilon) return false;
      return true;
    } else if (x.type != y.type) {
      return false;
    }
    switch (x.type) {
      case OperandType.set:
        {
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
        }
      case OperandType.complex:
      case OperandType.vector:
        {
          if (x.items.length != y.items.length) return false;
          for (var i = 0; i < x.items.length; i++) {
            if (Operand.compareEqual(x.items[i], y.items[i]) == false) {
              return false;
            }
          }
          break;
        }
      case OperandType.matrix:
        {
          if (x.rows != y.rows || x.cols != y.cols) return false;
          for (var i = 0; i < x.items.length; i++) {
            if (Operand.compareEqual(x.items[i], y.items[i]) == false) {
              return false;
            }
          }
          break;
        }
      default:
        {
          throw Exception(
            'Operand.compareEqual(..): unimplemented type "${x.type.name}".',
          );
        }
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
    if (isInteger(x)) {
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
    o.real = getBuiltInValue(o.text);
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

  /*static Operand createComplex(num x, num y) {
    // TODO: create int or real, if applicable!
    var o = Operand(); // o := output
    o.type = OperandType.complex;
    o.real = x;
    o.imag = y;
    return o;
  }*/

  static Operand createComplex(Operand x, Operand y) {
    // TODO: create int or real, if applicable!
    var o = Operand(); // o := output
    o.type = OperandType.complex;
    o.items.add(x);
    o.items.add(y);
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

  static void _binOpError(String operator, Operand x, Operand y) {
    throw Exception('Cannot apply operator "$operator" on types'
        ' "${x.type.name}" and "${y.type.name}" with values "$x" and "$y"');
  }

  static Operand logicalAnd(Operand x, Operand y) {
    if (x.type != OperandType.boolean || y.type != OperandType.boolean) {
      _binOpError("&&", x, y);
    }
    return Operand.createBoolean(x.real == 1 && y.real == 1);
  }

  static Operand logicalOr(Operand x, Operand y) {
    if (x.type != OperandType.boolean || y.type != OperandType.boolean) {
      _binOpError("||", x, y);
    }
    return Operand.createBoolean(x.real == 1 || y.real == 1);
  }

  static Operand logicalNot(Operand x) {
    if (x.type != OperandType.boolean) {
      throw Exception('Cannot apply operator "!" on type ' '${x.type.name}.');
    }
    return Operand.createBoolean(x.real == 0);
  }

  static Operand addSub(String operator, Operand x, Operand y) {
    if (['+', '-'].contains(operator) == false) {
      throw Exception('Invalid operator "$operator" for addSub(..).');
    }
    var o = Operand(); // o := output

    if (x.type != OperandType.complex && y.type == OperandType.complex) {
      // * OP complex -> complex
      o = y.clone();
      o.items[0] = Operand.addSub(operator, x, y.items[0]);
      if (operator == '-') {
        o.items[1] = Operand.unaryMinus(y.items[1]);
      }
      return o;
    } else if (x.type == OperandType.complex && y.type != OperandType.complex) {
      // complex OP * -> complex
      o = x.clone();
      o.items[0] = Operand.addSub(operator, x.items[0], y);
      return o;
    } else if (x.type == OperandType.complex && y.type == OperandType.complex) {
      // complex OP complex -> complex
      o.type = OperandType.complex;
      o.items.add(Operand.addSub(operator, x.items[0], y.items[0]));
      o.items.add(Operand.addSub(operator, x.items[1], y.items[1]));
      return o;
    }

    switch (x.type) {
      // -- first operator is int --
      case OperandType.int:
        switch (y.type) {
          case OperandType.int:
            // int OP int -> int
            o.type = OperandType.int;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          case OperandType.rational:
            // int OP rational -> rational
            o.type = OperandType.rational;
            if (operator == '+') {
              o.real = x.real * y.denominator + y.real * x.denominator;
            } else {
              o.real = x.real * y.denominator - y.real * x.denominator;
            }
            o.denominator = x.denominator * y.denominator;
            o._reduce();
            break;
          case OperandType.real:
          case OperandType.irrational:
            // int OP real -> real
            // int OP REAL(irrational) -> real
            o.type = OperandType.real;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is rational --
      case OperandType.rational:
        switch (y.type) {
          case OperandType.int:
          case OperandType.rational:
            // rational OP int -> rational
            // rational OP rational -> rational
            o.type = OperandType.rational;
            if (operator == '+') {
              o.real = x.real * y.denominator + y.real * x.denominator;
            } else {
              o.real = x.real * y.denominator - y.real * x.denominator;
            }
            o.denominator = x.denominator * y.denominator;
            o._reduce();
            break;
          case OperandType.real:
          case OperandType.irrational:
            // rational OP real -> real
            // rational OP REAL(irrational) -> real
            o.type = OperandType.real;
            o.real =
                x.real / x.denominator + (operator == '+' ? y.real : -y.real);
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is real --
      case OperandType.real:
        switch (y.type) {
          case OperandType.int:
            // real OP int -> real
            o.type = OperandType.real;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          case OperandType.rational:
            // real OP rational -> real
            o.type = OperandType.real;
            o.real = x.real +
                (operator == '+'
                    ? y.real / y.denominator
                    : -y.real / y.denominator);
            break;
          case OperandType.real:
          case OperandType.irrational:
            // real OP real -> real
            // real OP REAL(irrational) -> real
            o.type = OperandType.real;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is irrational --
      case OperandType.irrational:
        switch (y.type) {
          case OperandType.int:
            // REAL(irrational) OP int -> real
            o.type = OperandType.real;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          case OperandType.rational:
            // REAL(irrational) OP rational -> real
            o.type = OperandType.real;
            o.real = x.real +
                (operator == '+'
                    ? y.real / y.denominator
                    : -y.real / y.denominator);
            break;
          case OperandType.real:
          case OperandType.irrational:
            // REAL(irrational) OP real -> real
            // REAL(irrational) OP REAL(irrational) -> real
            o.type = OperandType.real;
            o.real = x.real + (operator == '+' ? y.real : -y.real);
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is vector --
      case OperandType.vector:
        switch (y.type) {
          case OperandType.vector:
            // vector OP vector -> vector
            o.type = OperandType.vector;
            if (x.items.length != y.items.length) {
              throw Exception(
                  'Vector dimensions not matching for operator "$operator".');
            }
            for (var i = 0; i < x.items.length; i++) {
              o.items.add(Operand.addSub(operator, x.items[i], y.items[i]));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is matrix --
      case OperandType.matrix:
        switch (y.type) {
          case OperandType.matrix:
            // matrix OP matrix -> matrix
            o.type = OperandType.matrix;
            if (x.rows != y.rows || x.cols != y.cols) {
              throw Exception(
                  'Matrix dimensions not matching for operator "$operator".');
            }
            o.rows = x.rows;
            o.cols = x.cols;
            for (var i = 0; i < x.items.length; i++) {
              o.items.add(Operand.addSub(operator, x.items[i], y.items[i]));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- other --
      default:
        _binOpError(operator, x, y);
    }
    if (o.type == OperandType.real) {
      // change type real to type int, if applicable
      o = Operand.createReal(o.real);
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
        o.items[0] = Operand.unaryMinus(o.items[0]); // real
        o.items[1] = Operand.unaryMinus(o.items[1]); // imag
        break;
      case OperandType.vector:
      case OperandType.matrix:
        for (var i = 0; i < o.items.length; i++) {
          o.items[i] = Operand.unaryMinus(o.items[i]);
        }
        break;
      case OperandType.irrational:
        // - REAL(irrational) -> real
        o.type = OperandType.real;
        o.real = -Operand.getBuiltInValue(o.text);
        break;
      default:
        throw Exception(
            'Cannot apply operator "unary -" on type ' '${x.type.name}.');
    }
    if (o.type == OperandType.real) {
      // change type real to type int, if applicable
      o = Operand.createReal(o.real);
    }
    return o;
  }

  static Operand mulDiv(String operator, Operand x, Operand y) {
    if (['*', '/'].contains(operator) == false) {
      throw Exception('Invalid operator "$operator" for mulDiv(..).');
    }
    var o = Operand(); // o := output

    if (x.type != OperandType.complex && y.type == OperandType.complex) {
      // * OP complex -> complex
      o.type = OperandType.complex;
      if (operator == '*') {
        // o.real = x * y.real
        // o.imag = x * y.imag
        o.items.add(Operand.mulDiv('*', x, y.items[0]));
        o.items.add(Operand.mulDiv('*', x, y.items[1]));
      } else {
        throw Exception("eval complex division is unimplemented");
        // TODO
      }
      return o;
    } else if (x.type == OperandType.complex && y.type != OperandType.complex) {
      // complex OP * -> complex
      o.type = OperandType.complex;
      if (operator == '*') {
        // o.real = x.real * y
        // o.imag = x.imag * y
        o.items.add(Operand.mulDiv('*', x.items[0], y));
        o.items.add(Operand.mulDiv('*', x.items[1], y));
      } else {
        throw Exception("eval complex division is unimplemented");
        // TODO
      }
      return o;
    } else if (x.type == OperandType.complex && y.type == OperandType.complex) {
      // complex OP complex -> complex
      o.type = OperandType.complex;
      if (operator == '*') {
        // o.real = x.real * y.real - x.imag * y.imag;
        // o.imag = x.real * y.imag + x.imag * y.real;
        o.items.add(Operand.addSub(
            '-', //
            Operand.mulDiv('*', x.items[0], y.items[0]),
            Operand.mulDiv('*', x.items[1], y.items[1])));
        o.items.add(Operand.addSub(
            '+', //
            Operand.mulDiv('*', x.items[0], y.items[1]),
            Operand.mulDiv('*', x.items[1], y.items[0])));
      } else {
        throw Exception("eval complex division is unimplemented");
        // TODO
      }
      return o;
    }

    switch (x.type) {
      // -- first operator is int --
      case OperandType.int:
        switch (y.type) {
          case OperandType.int:
            // int * int -> int
            // int / int -> rational
            o.type = OperandType.int;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o = Operand.createRational(x.real, y.real);
            }
            break;
          case OperandType.rational:
            // int OP rational -> rational
            o.type = OperandType.rational;
            if (operator == '*') {
              o.real = x.real * y.real;
              o.denominator = x.denominator * y.denominator;
            } else {
              o.real = x.real * y.denominator;
              o.denominator = x.denominator * y.real;
            }
            o._reduce();
            break;
          case OperandType.real:
          case OperandType.irrational:
            // int OP real -> real
            // int OP REAL(irrational) -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o.real = x.real / y.real;
            }
            break;
          case OperandType.vector:
            // int OP vector -> vector
            o.type = OperandType.vector;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          case OperandType.matrix:
            // int OP matrix -> matrix
            o.type = OperandType.matrix;
            o.rows = y.rows;
            o.cols = y.cols;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is rational --
      case OperandType.rational:
        switch (y.type) {
          case OperandType.int:
          case OperandType.rational:
            // rational OP int -> rational
            // rational OP rational -> rational
            o.type = OperandType.rational;
            if (operator == '*') {
              o.real = x.real * y.real;
              o.denominator = x.denominator * y.denominator;
            } else {
              o.real = x.real * y.denominator;
              o.denominator = x.denominator * y.real;
            }
            o._reduce();
            break;
          case OperandType.real:
          case OperandType.irrational:
            // rational OP real -> real
            // rational OP REAL(irrational) -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = (x.real / x.denominator) * y.real;
            } else {
              o.real = (x.real / x.denominator) / y.real;
            }
            break;
          case OperandType.vector:
            // int OP vector -> vector
            o.type = OperandType.vector;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          case OperandType.matrix:
            // int OP matrix -> matrix
            o.type = OperandType.matrix;
            o.rows = y.rows;
            o.cols = y.cols;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is real --
      case OperandType.real:
        switch (y.type) {
          case OperandType.int:
            // real OP int -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o.real = x.real / y.real;
            }
            break;
          case OperandType.rational:
            // real OP rational -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real / y.denominator;
            } else {
              o.real = x.real * y.denominator / y.real;
            }
            break;
          case OperandType.real:
          case OperandType.irrational:
            // real OP real -> real
            // real OP REAL(irrational) -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o.real = x.real / y.real;
            }
            break;
          case OperandType.vector:
            // int OP vector -> vector
            o.type = OperandType.vector;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          case OperandType.matrix:
            // int OP matrix -> matrix
            o.type = OperandType.matrix;
            o.rows = y.rows;
            o.cols = y.cols;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is irrational --
      case OperandType.irrational:
        switch (y.type) {
          case OperandType.int:
            // REAL(irrational) OP int -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o.real = x.real / y.real;
            }
            break;
          case OperandType.rational:
            // REAL(irrational) OP rational -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real / y.denominator;
            } else {
              o.real = x.real * y.denominator / y.real;
            }
            break;
          case OperandType.real:
          case OperandType.irrational:
            // REAL(irrational) OP real -> real
            // REAL(irrational) OP REAL(irrational) -> real
            o.type = OperandType.real;
            if (operator == '*') {
              o.real = x.real * y.real;
            } else {
              o.real = x.real / y.real;
            }
            break;
          case OperandType.vector:
            // int OP vector -> vector
            o.type = OperandType.vector;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          case OperandType.matrix:
            // int OP matrix -> matrix
            o.type = OperandType.matrix;
            o.rows = y.rows;
            o.cols = y.cols;
            for (var item in y.items) {
              o.items.add(Operand.mulDiv(operator, x, item));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is vector --
      case OperandType.vector:
        switch (y.type) {
          case OperandType.int:
          case OperandType.rational:
          case OperandType.real:
          case OperandType.irrational:
            // int OP vector -> vector
            // rational OP vector -> vector
            // real OP vector -> vector
            // irrational OP vector -> vector
            o.type = OperandType.vector;
            for (var item in x.items) {
              o.items.add(Operand.mulDiv(operator, item, y));
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- first operator is matrix --
      case OperandType.matrix:
        switch (y.type) {
          case OperandType.matrix:
            // matrix OP matrix -> matrix
            if (operator == '/') {
              throw Exception('Matrix division is not allowed.');
            }
            o.type = OperandType.matrix;
            if (x.cols != y.rows) {
              throw Exception(
                  'Matrix dimensions not matching for operator "*".');
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
                  o.items[idx] = Operand.addSub('+', o.items[idx],
                      Operand.mulDiv('*', x.items[a], y.items[b]));
                }
              }
            }
            break;
          default:
            _binOpError(operator, x, y);
        }
        break;
      // -- other --
      default:
        _binOpError(operator, x, y);
    }
    if (o.type == OperandType.real) {
      // change type real to type int, if applicable
      o = Operand.createReal(o.real);
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
      throw Exception("TODO: pow with complex");
      /*var r = math.sqrt(x.real * x.real + x.imag * x.imag);
      var phi = math.atan2(x.imag, x.real);
      r = math.pow(r, y.real).toDouble();
      phi *= y.real;
      var re = r * math.cos(phi);
      var im = r * math.sin(phi);
      o = Operand.createComplex(re, im);*/
    } else {
      throw Exception(
        'Cannot apply operator "^" on "${x.type.name}" and "${y.type.name}".',
      );
    }
    if (o.type == OperandType.real) {
      // change type real to type int, if applicable
      o = Operand.createReal(o.real);
    }
    return o;
  }

  static Operand relationalOrEqual(String op, Operand x, Operand y) {
    if (['<', '<=', '>', '>=', '==', '!='].contains(op) == false) {
      throw Exception('Invalid operator $op for relationalOrEqual(..).');
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
        case '==':
          o.real = u == v ? 1 : 0;
          break;
        case '!=':
          o.real = u != v ? 1 : 0;
          break;
        case '<':
          o.real = u < v ? 1 : 0;
          break;
        case '<=':
          o.real = u <= v ? 1 : 0;
          break;
        case '>':
          o.real = u > v ? 1 : 0;
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

  String _num2String(num real) {
    var str = real.toStringAsFixed(13); // TODO!!
    while (str.endsWith('0')) {
      str = str.substring(0, str.length - 1);
    }
    if (str.endsWith('.')) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  @override
  String toString() {
    switch (type) {
      case OperandType.boolean:
        return real == 0 ? 'false' : 'true';
      case OperandType.int:
      case OperandType.real:
        return _num2String(real);
      case OperandType.rational:
        return '${_num2String(real)}/${_num2String(denominator)}';
      case OperandType.complex:
        {
          // TODO!!
          var s = '';
          s +=
              "(" + items[0].toString() + ') + (' + items[1].toString() + ')*i';
          return s;
          /*var realPart = _num2String(real);
          var imagPart = _num2String(imag);
          if (imagPart == "1") {
            imagPart = "";
          } else if (imagPart == "-1") {
            imagPart = "-";
          }
          if (imagPart == "0") {
            return realPart;
          } else if (realPart == "0" || realPart == "-0") {
            return '${imagPart}i';
          } else if (imag > 0) {
            return '$realPart+${imagPart}i';
          } else {
            return '$realPart${imagPart}i';
          }*/
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

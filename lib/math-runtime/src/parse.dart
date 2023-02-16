/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:math' as math;

import 'term.dart';

// this file implements robust parsing of math string provided by students
// line comments "***" indicate semantical useless lines that prevent linter warnings

// TODO: add playground of mathebuddy-math-runtime on github.io + denote links on website(s)

class Parser {
  List<String> _tokens = [];
  int _tokenIdx = 0;
  String _token = '';

  Parser() {
    //
  }

  List<String> getTokens() {
    return this._tokens;
  }

  Term parse(String src) {
    this._tokens = [];
    this._tokenIdx = 0;
    // scanning (lexing)
    var tk = ''; // token
    for (var i = 0; i < src.length; i++) {
      var ch = src[i];
      if (' \t\n'.contains(ch)) {
        if (tk.length > 0) {
          this._tokens.add(tk);
          tk = '';
        }
      } else if ('+-*/()^{},|[]<>='.contains(ch)) {
        // TODO: "<=", ... (all 2+ character tokens)
        if (tk.length > 0) {
          this._tokens.add(tk);
          tk = '';
        }
        this._tokens.add(ch);
      } else {
        tk += ch;
      }
    }
    if (tk.length > 0) this._tokens.add(tk);
    this._tokens.add('§');
    // post-process tokens
    List<String> procTokens = [];
    for (var k = 0; k < this._tokens.length; k++) {
      var token = this._tokens[k];
      if (this._isIdentifier(token) &&
          this._isFct1(token) == false &&
          this._isFct2(token) == false &&
          this._isBuiltIn(token) == false) {
        // split variables (e.g. "xy" -> "x y")
        for (var i = 0; i < token.length; i++) {
          var char = token[i];
          procTokens.add(char);
        }
      } else if (token.length >= 2 &&
          this._isNum0(token[0]) &&
          this._isAlpha(token[1])) {
        // split factors (e.g. "3x" -> "3 x")
        var value = '';
        var id = '';
        for (var i = 0; i < token.length; i++) {
          var ch = token[i];
          if (id.length == 0 && this._isNum0(ch))
            value += ch;
          else
            id += ch;
        }
        procTokens.add(value);
        procTokens.add(id); // TODO: split variables!!!!!
      } else {
        // no post-processing
        procTokens.add(token);
      }
    }
    this._tokens = procTokens;
    // resolve randomized token selection, e.g. "1{+|-}2" -> "1+2" or "1-2"
    procTokens = [];
    for (var i = 0; i < this._tokens.length; i++) {
      if (this._tokens[i] == '{') {
        List<String> op = [];
        var valid = true;
        var k;
        for (k = i + 1; k < this._tokens.length; k++) {
          if (this._tokens[k] == '}') break;
          if ('+-*/'.contains(this._tokens[k]) == false) {
            valid = false;
            break;
          }
          op.add(this._tokens[k]);
          k++;
          if (k >= this._tokens.length) {
            valid = false;
            break;
          }
          if (this._tokens[k] != '|' && this._tokens[k] != '}') {
            valid = false;
            break;
          }
          if (this._tokens[k] == '}') break;
        }
        if (valid) {
          i = k;
          procTokens.add(
            op[(math.Random().nextDouble() * op.length).floor()],
          );
        } else {
          procTokens.add('{');
        }
      } else {
        procTokens.add(this._tokens[i]);
      }
    }
    this._tokens = procTokens;
    // parsing
    this._next();
    var term = this._parseTerm();
    if (this._token != '§') throw new Exception('unexpected:end');
    return term;
  }

  //G term = relational;
  Term _parseTerm() {
    return this._parseRelational();
  }

  //G relational = add [ ("<"|"<="|">"|">=") add ];
  Term _parseRelational() {
    var res = this._parseAdd();
    if (['<', '<=', '>', '>='].contains(this._token)) {
      var op = this._token;
      this._next();
      res = Term.Op(op, [res, this._parseAdd()], []);
    }
    return res;
  }

  //G add = mul { ("+"|"-") mul };
  Term _parseAdd() {
    List<Term> operands = [];
    List<String> operators = [];
    operands.add(this._parseMul());
    while (this._token == '+' || this._token == '-') {
      operators.add(this._token);
      this._next();
      operands.add(this._parseMul());
    }
    if (operators.length == 1 && operators[0] == '-') {
      // form: "o[0] - o[1]"
      return Term.Op('-', operands, []);
    } else if (operators.length > 0) {
      // form: "o[0] op[0] b[1] op[1] ..."
      // -> "o[0] + o[1] + ..."  with o[i+1] := -o[i+1] for op[i]=='-'
      for (var i = 0; i < operators.length; i++) {
        if (operators[i] == '-')
          operands[i + 1] = Term.Op('.-', [operands[i + 1]], []);
      }
      return Term.Op('+', operands, []);
    } else {
      // form: "o[0]"
      return operands[0];
    }
  }

  //G mul = pow { ("*"|"/"|!fill"*"!) pow };
  Term _parseMul() {
    List<Term> operands = [];
    List<String> operators = [];
    operands.add(this._parsePow());
    while (this._token == '*' ||
        this._token == '/' ||
        (this._token != '§' &&
            (this._isIdentifier(this._token) || this._token == '('))) {
      var op = this._token == '/' ? '/' : '*';
      operators.add(op);
      if (this._token == '*' || this._token == '/') this._next();
      operands.add(this._parsePow());
    }
    if (operands.length == 1) {
      return operands[0];
    } else if (operators.length == 1 && operators[0] == '/') {
      return Term.Op('/', operands, []);
    } else if (operators.contains('/')) {
      throw new Exception('mixed * and / are unimplemented');
      // TODO: "/" (push binary operations in a sequence!!!!)
    } else
      return Term.Op('*', operands, []);
  }

  //G pow = unary [ "^" unary ];
  Term _parsePow() {
    List<Term> operands = [];
    operands.add(this._parseUnary());
    if (this._token == '^') {
      this._next();
      operands.add(this._parseUnary());
      return Term.Op('^', operands, []);
    } else
      return operands[0];
  }

  //G unary = [prefix] infix [postfix];
  //G prefix = "-";
  //G postfix = "i";
  Term _parseUnary() {
    var isUnaryMinus = false;
    if (this._token == '-') {
      this._next();
      isUnaryMinus = true;
    }
    var term = this._parseInfix();
    if (isUnaryMinus) term = Term.Op('.-', [term], []);
    if (this._token == 'i') {
      this._next();
      term = Term.Op('*', [term, Term.ConstComplex(0, 1)], []);
    }
    return term;
  }

  /*G infix = IMAG | REAL | INT | builtin
      | fct1 unary
      | fct "<" unary {"," unary} ">" "(" term {"," term} ")"
      | ID
      | "|" term "|"
      | matrixOrVector | set;
  */
  Term _parseInfix() {
    if (this._isImag(this._token)) {
      var tk = this._token;
      this._next();
      if (tk == 'i') tk = '1i';
      var im = num.parse(tk.substring(0, tk.length - 1));
      return Term.ConstComplex(0, im);
    } else if (this._isInteger(this._token)) {
      var value = int.parse(this._token);
      this._next();
      return Term.ConstInt(value);
    } else if (this._isReal(this._token)) {
      var value = num.parse(this._token);
      this._next();
      return Term.ConstReal(value);
    } else if (this._isBuiltIn(this._token)) {
      var id = this._token;
      this._next();
      return Term.ConstIrrational(id);
    } else if (this._isFct1(this._token) || this._isFct2(this._token)) {
      var fctId = this._token;
      var numParams = this._isFct1(this._token) ? 1 : 2;
      List<Term> params = [];
      List<Term> dims = [];
      this._next();
      if (this._token == '<') {
        this._next();
        dims.add(this._parseUnary());
        this._token += ''; // ***
        while (this._token == ',') {
          this._next();
          dims.add(this._parseUnary());
        }
        if (this._token == '>')
          this._next();
        else
          throw new Exception('expected ">"');
      }
      if (this._token == '(') {
        this._token += ''; // ***
        this._next();
        params.add(this._parseTerm());
        while (this._token == ',') {
          this._next();
          params.add(this._parseTerm());
        }
        if (this._token == ')')
          this._next();
        else
          throw new Exception('expected ")"');
        return Term.Op(fctId, params, dims);
      } else if (numParams == 1 && dims.length == 0) {
        params.add(this._parseUnary());
        return Term.Op(fctId, params, dims);
      } else
        throw new Exception('expected "(" or unary function');
    } else if (this._token == '@' || this._isIdentifier(this._token)) {
      var isTerm = false;
      if (this._token == '@') {
        isTerm = true;
        this._next();
        if (this._isIdentifier(this._token) == false)
          throw new Exception('expected:ID');
      }
      var id = (isTerm ? '@' : '') + this._token;
      this._next();
      return Term.Var(id);
    } else if (this._token == '(') {
      this._token += ''; // ***
      this._next();
      var t = this._parseTerm();
      if (this._token == ')')
        this._next();
      else
        throw new Exception('expected: ")"');
      return t;
    } else if (this._token == '|') {
      this._token += ''; // ***
      this._next();
      var t = this._parseTerm();
      if (this._token == '|')
        this._next();
      else
        throw new Exception('expected:"|"');
      return Term.Op('abs', [t], []);
    } else if (this._token == '[') {
      return this._parseMatrixOrVector();
    } else if (this._token == '{') {
      return this._parseSet();
    } else {
      throw new Exception('unexpected:' + this._token);
    }
  }

  //G vector = "[" [ term { "," term } ] "]";
  Term _parseVector([bool parseLeftBracket = true]) {
    if (parseLeftBracket) {
      if (this._token == '[')
        this._next();
      else
        throw new Exception('expected "["');
    }
    this._token += ''; // ***
    List<Term> elements = [];
    if (this._token != ']') {
      elements.add(this._parseTerm());
      while (this._token == ',') {
        this._next();
        elements.add(this._parseTerm());
      }
    }
    if (this._token == ']')
      this._next();
    else
      throw new Exception('expected "]"');
    return Term.Op('vec', elements, []);
  }

  //G matrixOrVector = vector | "[" [ vector { "," vector } ] "]";
  Term _parseMatrixOrVector() {
    if (this._token == '[')
      this._next();
    else
      throw new Exception('expected "["');
    if (this._token != '[') {
      return this._parseVector(false);
    }
    this._token += ''; // ***
    List<Term> elements = [];
    if (this._token != ']') {
      elements.add(this._parseVector());
      while (this._token == ',') {
        this._next();
        elements.add(this._parseVector());
      }
    }
    if (this._token == ']')
      this._next();
    else
      throw new Exception('expected "]"');
    return Term.Op('matrix', elements, []);
  }

  //G set = "{" [ term { "," term } ] "}";
  Term _parseSet() {
    // TODO: allow empty sets
    if (this._token == '{')
      this._next();
    else
      throw new Exception('expected "{"');
    this._token += ''; // ***
    List<Term> elements = [];
    elements.add(this._parseTerm());
    while (this._token == ',') {
      this._next();
      elements.add(this._parseTerm());
    }
    if (this._token == '}')
      this._next();
    else
      throw new Exception('expected "}"');
    return Term.Op('set', elements, []);
  }

  /*G fct1 = "abs" | "ceil" | "cos" | "exp" | "imag" | "int" | "fac" | "floor"
      | "max" | "min" | "len" | "ln" | "real" | "round" | "sin" | "sqrt" | "tan"; */
  bool _isFct1(String tk) {
    var fct1 = [
      'abs',
      'ceil',
      'cos',
      'exp',
      'imag',
      'int',
      'fac',
      'floor',
      'max',
      'min',
      'len',
      'ln',
      'real',
      'round',
      'sin',
      'sqrt',
      'tan',
    ];
    return fct1.contains(tk);
  }

  //G fct2 = "binomial" | "complex" | "rand" | "randZ";
  bool _isFct2(String tk) {
    var fct2 = ['binomial', 'complex', 'rand', 'randZ'];
    return fct2.contains(tk);
  }

  //G builtin = "pi" | "e";
  bool _isBuiltIn(String tk) {
    var builtin = ['pi', 'e'];
    return builtin.contains(tk);
  }

  //G IMAG = REAL "i";
  bool _isImag(String tk) {
    if (tk.endsWith('i') == false) return false;
    var x = tk.substring(0, tk.length - 1);
    if (this._isReal(x) == false && this._isInteger(x) == false) return false;
    return true;
  }

  //G REAL = INT "." { NUM0 };
  bool _isReal(String tk) {
    var tokens = tk.split('.');
    if (tokens.length != 2) return false;
    if (this._isInteger(tokens[0]) == false) return false;
    for (var i = 0; i < tokens[1].length; i++) {
      var ch = tokens[1][i];
      if (this._isNum0(ch) == false) return false;
    }
    return true;
  }

  //G INT = "0" | NUM1 { NUM0 };
  bool _isInteger(String tk) {
    if (tk == '0') return true;
    for (var i = 0; i < tk.length; i++) {
      var ch = tk[i];
      if (i == 0 && this._isNum1(ch) == false)
        return false;
      else if (i > 0 && this._isNum0(ch) == false) return false;
    }
    return true;
  }

  bool _isNum0(String tk) {
    return tk.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        tk.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isNum1(String tk) {
    return tk.codeUnitAt(0) >= '1'.codeUnitAt(0) &&
        tk.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isAlpha(String tk) {
    return tk.codeUnitAt(0) == '_'.codeUnitAt(0) ||
        (tk.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            tk.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        (tk.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            tk.codeUnitAt(0) <= 'z'.codeUnitAt(0));
  }

  //G ID = ALPHA { (ALPHA | NUM0) };
  bool _isIdentifier(String tk) {
    var n = tk.length;
    for (var i = 0; i < n; i++) {
      var ch = tk[i];
      if (i == 0 && !this._isAlpha(ch))
        return false;
      else if (!this._isAlpha(ch) && !this._isNum0(ch)) return false;
    }
    return true;
  }

  void _next() {
    if (this._tokenIdx >= this._tokens.length) {
      this._token = '§';
      return;
    }
    this._token = this._tokens[this._tokenIdx++];
  }
}

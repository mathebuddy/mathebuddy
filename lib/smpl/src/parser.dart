/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../../ext/multila-lexer/src/lex.dart';
import '../../../ext/multila-lexer/src/token.dart';

// Note: terms are parsed at runtime.
// This is (much) slower than parsing offline, but increases dynamics.

String spaces(int n) {
  var s = '';
  for (var i = 0; i < n; i++) s += '  ';
  return s;
}

abstract class AST_Node {
  int row = -1; // src location
  AST_Node(this.row);

  String toString([int indent = 0]);
}

class StatementList extends AST_Node {
  List<AST_Node> statements = [];
  bool createScope;

  StatementList(super.row, this.createScope);

  String toString([int indent = 0]) {
    var s = spaces(indent) +
        'STATEMENT_LIST:createScope=' +
        this.createScope.toString() +
        ',statements=[\n';
    s += this.statements.map((x) => x.toString(indent + 1)).join('');
    s += spaces(indent) + '];\n';
    return s;
  }
}

class Assignment extends AST_Node {
  bool createSymbol = true;
  String lhs = '';
  String rhs = '';
  List<String> vars = []; // e.g. "f(x,y)" -> vars = ["x","y"]
  List<String> independentTo = [];

  Assignment(super.row);

  String toString([int indent = 0]) {
    return (spaces(indent) +
        'ASSIGNMENT:create=${this.createSymbol},' +
        'lhs="${this.lhs}",' +
        'rhs="${this.rhs}",' +
        'vars=[${this.vars.join(',')}],' +
        'independentTo=[${this.independentTo.join(',')}];\n');
  }
}

class IfCond extends AST_Node {
  String condition = '';
  StatementList? statementsTrue = null;
  StatementList? statementsFalse = null;

  IfCond(super.row);

  String toString([int indent = 0]) {
    var sT = this.statementsTrue?.toString(indent + 1);
    var sF = this.statementsFalse == null
        ? ''
        : this.statementsFalse?.toString(indent + 1);
    return (spaces(indent) +
        'IF_COND:condition="${this.condition}",statementsTrue=[\n${sT}' +
        spaces(indent) +
        '],statementsFalse=[\n${sF}' +
        spaces(indent) +
        '];\n');
  }
}

class WhileLoop extends AST_Node {
  String condition = '';
  StatementList? statements = null;

  WhileLoop(super.row);

  String toString([int indent = 0]) {
    var s = this.statements?.toString(indent + 1);
    return (spaces(indent) +
        'WHILE_LOOP:condition="${this.condition}",statements=[\n${s}' +
        spaces(indent) +
        '];\n');
  }
}

class Parser {
  Lexer _lexer = new Lexer();
  AST_Node? _program = null;

  void parse(String src) {
    this._lexer = new Lexer();
    this._lexer.enableEmitNewlines(true);
    this._lexer.configureSingleLineComments('%');
    this._lexer.configureMultiLineComments('/*', '*/');
    this._lexer.enableEmitIndentation(false);
    this._lexer.enableBackslashLineBreaks(false);
    this._lexer.setTerminals(['&&', '||', '==', '!=', '>=', '<=', '++', '--']);
    this._lexer.pushSource('FILE', src);
    this._program = this._parseProgram();
  }

  AST_Node? getAbstractSyntaxTree() {
    return this._program;
  }

  //G program = { statement };
  StatementList _parseProgram() {
    var p = new StatementList(1, false);
    while (this._lexer.isNotEND()) {
      if (this._lexer.isTER('\n'))
        this._lexer.next();
      else
        p.statements.add(this._parseStatement());
    }
    return p;
  }

  //G statement = assignment | ifCond | whileLoop;
  AST_Node _parseStatement() {
    while (this._lexer.isTER('\n')) this._lexer.next();
    switch (this._lexer.getToken().token) {
      case 'let':
        return this._parseAssignment();
      case 'if':
        return this._parseIfCond();
      case 'while':
        return this._parseWhileLoop();
    }
    if (this._lexer.isID()) return this._parseAssignment();
    this._error(
      'unexpected token "${this._lexer.getToken().token}"',
      this._lexer.getToken(),
    );
    throw Exception(); // just to suppress DART warnings...
  }

  //G assignment = ["let"] ID { (":"|"/") ID } ["(" ID { "," ID } ")"] "=" term (";"|"\n");
  AST_Node _parseAssignment() {
    var row = this._lexer.getToken().row;
    var isDeclaration = false;
    if (this._lexer.isTER('let')) {
      isDeclaration = true;
      this._lexer.next();
    }
    List<String> lhsList = [];
    lhsList.add(this._lexer.ID());
    var lhsDelimiter =
        ''; // ":" or "/" (the latter forces variable values to be different)
    while (this._lexer.isTER(':') || this._lexer.isTER('/')) {
      if (lhsDelimiter == '')
        lhsDelimiter = this._lexer.getToken().token;
      else if (lhsDelimiter != this._lexer.getToken().token)
        this._error('mixing ":" and "/" is forbidden');
      this._lexer.next();
      lhsList.add(this._lexer.ID());
    }
    List<String> variables = [];
    if (this._lexer.isTER('(')) {
      this._lexer.next();
      variables.add(this._lexer.ID());
      while (this._lexer.isTER(',')) {
        this._lexer.next();
        variables.add(this._lexer.ID());
      }
      this._lexer.TER(')');
    }
    this._lexer.TER('=');
    var term = '';
    while (this._lexer.isNotEND() &&
        this._lexer.isNotTER('\n') &&
        this._lexer.isNotTER(';')) {
      term += this._lexer.getToken().token + ' ';
      this._lexer.next();
    }
    if (this._lexer.isTER(';')) this._lexer.next();
    this._consumeEOL();
    // create AST node
    List<Assignment> assignments = [];
    for (var i = 0; i < lhsList.length; i++) {
      var lhs = lhsList[i];
      var a = new Assignment(row);
      assignments.add(a);
      a.lhs = lhs;
      a.vars = [...variables];
      a.rhs = term.trim();
      a.createSymbol = isDeclaration;
      if (lhsDelimiter == '/') {
        for (var j = 0; j < i; j++) {
          a.independentTo.add(lhsList[j]);
        }
      }
    }
    if (assignments.length == 1) return assignments[0];
    var s = new StatementList(row, false);
    s.statements = assignments;
    return s;
  }

  //G ifCond = "if" cond block [ "else" block ];
  IfCond _parseIfCond() {
    // TODO: "elif"
    var i = new IfCond(this._lexer.getToken().row);
    this._lexer.TER('if');
    while (this._lexer.isNotEND() &&
        this._lexer.isNotTER('\n') &&
        this._lexer.isNotTER('{')) {
      i.condition += this._lexer.getToken().token + ' ';
      this._lexer.next();
    }
    i.condition = i.condition.trim();
    this._consumeEOL();
    i.statementsTrue = this._parseBlock();
    if (this._lexer.isTER('else')) {
      this._lexer.next();
      this._consumeEOL();
      i.statementsFalse = this._parseBlock();
    }
    return i;
  }

  //G whileLoop = "while" term block;
  WhileLoop _parseWhileLoop() {
    var w = new WhileLoop(this._lexer.getToken().row);
    this._lexer.TER('while');
    while (this._lexer.isNotEND() &&
        this._lexer.isNotTER('\n') &&
        this._lexer.isNotTER('{')) {
      w.condition += this._lexer.getToken().token + ' ';
      this._lexer.next();
    }
    w.condition = w.condition.trim();
    this._consumeEOL();
    w.statements = this._parseBlock();
    return w;
  }

  // block = "{" { statement } "}";
  StatementList _parseBlock() {
    var block = new StatementList(this._lexer.getToken().row, true);
    this._lexer.TER('{');
    while (this._lexer.isNotEND() && this._lexer.isNotTER('}')) {
      this._consumeEOL();
      block.statements.add(this._parseStatement());
      this._consumeEOL();
    }
    this._consumeEOL();
    this._lexer.TER('}');
    this._consumeEOL();
    return block;
  }

  void _consumeEOL() {
    while (this._lexer.isTER('\n')) this._lexer.next();
  }

  void _error(String message, [LexerToken? token = null]) {
    var location = '';
    if (token == null)
      location = '' +
          this._lexer.getToken().row.toString() +
          ':' +
          this._lexer.getToken().col.toString() +
          ':';
    else
      location = '' + token.row.toString() + ':' + token.col.toString() + ':';
    throw new Exception(location + message);
  }
}

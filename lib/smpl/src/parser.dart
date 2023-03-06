/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

// Note: terms are parsed at runtime.
// This is (much) slower than parsing offline, but increases dynamics.

String spaces(int n) {
  var s = '';
  for (var i = 0; i < n; i++) {
    s += '  ';
  }
  return s;
}

abstract class AstNode {
  int row = -1; // src location
  AstNode(this.row);

  @override
  String toString([int indent = 0]);
}

class StatementList extends AstNode {
  List<AstNode> statements = [];
  bool createScope;

  StatementList(super.row, this.createScope);

  @override
  String toString([int indent = 0]) {
    var s = '${spaces(indent)}STATEMENT_LIST:'
        'createScope={$createScope},statements=[\n';
    s += statements.map((x) => x.toString(indent + 1)).join('');
    s += '${spaces(indent)}];\n';
    return s;
  }
}

class Assignment extends AstNode {
  bool createSymbol = true;
  String lhs = '';
  String rhs = '';
  List<String> vars = []; // e.g. "f(x,y)" -> vars = ["x","y"]
  List<String> independentTo = [];

  Assignment(super.row);

  @override
  String toString([int indent = 0]) {
    return ('${spaces(indent)}'
        'ASSIGNMENT:create=$createSymbol,'
        'lhs="$lhs",'
        'rhs="$rhs",'
        'vars=[${vars.join(',')}],'
        'independentTo=[${independentTo.join(',')}];\n');
  }
}

class IfCond extends AstNode {
  String condition = '';
  StatementList? statementsTrue;
  StatementList? statementsFalse;

  IfCond(super.row);

  @override
  String toString([int indent = 0]) {
    var sT = statementsTrue?.toString(indent + 1);
    var sF =
        statementsFalse == null ? '' : statementsFalse?.toString(indent + 1);
    return ('${spaces(indent)}'
        'IF_COND:condition="$condition",statementsTrue=[\n$sT'
        '${spaces(indent)}'
        '],statementsFalse=[\n$sF'
        '${spaces(indent)}'
        '];\n');
  }
}

class WhileLoop extends AstNode {
  String condition = '';
  StatementList? statements;

  WhileLoop(super.row);

  @override
  String toString([int indent = 0]) {
    var s = statements?.toString(indent + 1);
    return ('${spaces(indent)}'
        'WHILE_LOOP:condition="$condition",statements=[\n$s'
        '${spaces(indent)}'
        '];\n');
  }
}

class Parser {
  Lexer _lexer = Lexer();
  AstNode? _program;

  void parse(String src) {
    _lexer = Lexer();
    _lexer.enableEmitNewlines(true);
    _lexer.configureSingleLineComments('%');
    _lexer.configureMultiLineComments('/*', '*/');
    _lexer.enableEmitIndentation(false);
    _lexer.enableBackslashLineBreaks(false);
    _lexer.setTerminals(['&&', '||', '==', '!=', '>=', '<=', '++', '--']);
    _lexer.pushSource('FILE', src);
    _program = _parseProgram();
  }

  AstNode? getAbstractSyntaxTree() {
    return _program;
  }

  //G program = { statement };
  StatementList _parseProgram() {
    var p = StatementList(1, false);
    while (_lexer.isNotEnd()) {
      if (_lexer.isTerminal('\n')) {
        _lexer.next();
      } else {
        p.statements.add(_parseStatement());
      }
    }
    return p;
  }

  //G statement = assignment | ifCond | whileLoop;
  AstNode _parseStatement() {
    while (_lexer.isTerminal('\n')) {
      _lexer.next();
    }
    switch (_lexer.getToken().token) {
      case 'let':
        return _parseAssignment();
      case 'if':
        return _parseIfCond();
      case 'while':
        return _parseWhileLoop();
    }
    if (_lexer.isIdentifier()) return _parseAssignment();
    _error(
      'unexpected token "${_lexer.getToken().token}"',
      _lexer.getToken(),
    );
    throw Exception(); // just to suppress DART warnings...
  }

  //G assignment = ["let"] ID { (":"|"/") ID } ["(" ID { "," ID } ")"] "=" term (";"|"\n");
  AstNode _parseAssignment() {
    var row = _lexer.getToken().row;
    var isDeclaration = false;
    if (_lexer.isTerminal('let')) {
      isDeclaration = true;
      _lexer.next();
    }
    List<String> lhsList = [];
    lhsList.add(_lexer.identifier());
    var lhsDelimiter =
        ''; // ":" or "/" (the latter forces variable values to be different)
    while (_lexer.isTerminal(':') || _lexer.isTerminal('/')) {
      if (lhsDelimiter == '') {
        lhsDelimiter = _lexer.getToken().token;
      } else if (lhsDelimiter != _lexer.getToken().token) {
        _error('mixing ":" and "/" is forbidden');
      }
      _lexer.next();
      lhsList.add(_lexer.identifier());
    }
    List<String> variables = [];
    if (_lexer.isTerminal('(')) {
      _lexer.next();
      variables.add(_lexer.identifier());
      while (_lexer.isTerminal(',')) {
        _lexer.next();
        variables.add(_lexer.identifier());
      }
      _lexer.terminal(')');
    }
    _lexer.terminal('=');
    var term = '';
    while (_lexer.isNotEnd() &&
        _lexer.isNotTerminal('\n') &&
        _lexer.isNotTerminal(';')) {
      term += '${_lexer.getToken().token} ';
      _lexer.next();
    }
    if (_lexer.isTerminal(';')) _lexer.next();
    _consumeEOL();
    // create AST node
    List<Assignment> assignments = [];
    for (var i = 0; i < lhsList.length; i++) {
      var lhs = lhsList[i];
      var a = Assignment(row);
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
    var s = StatementList(row, false);
    s.statements = assignments;
    return s;
  }

  //G ifCond = "if" cond block [ "else" block ];
  IfCond _parseIfCond() {
    // TODO: "elif"
    var i = IfCond(_lexer.getToken().row);
    _lexer.terminal('if');
    while (_lexer.isNotEnd() &&
        _lexer.isNotTerminal('\n') &&
        _lexer.isNotTerminal('{')) {
      i.condition += '${_lexer.getToken().token} ';
      _lexer.next();
    }
    i.condition = i.condition.trim();
    _consumeEOL();
    i.statementsTrue = _parseBlock();
    if (_lexer.isTerminal('else')) {
      _lexer.next();
      _consumeEOL();
      i.statementsFalse = _parseBlock();
    }
    return i;
  }

  //G whileLoop = "while" term block;
  WhileLoop _parseWhileLoop() {
    var w = WhileLoop(_lexer.getToken().row);
    _lexer.terminal('while');
    while (_lexer.isNotEnd() &&
        _lexer.isNotTerminal('\n') &&
        _lexer.isNotTerminal('{')) {
      w.condition += '${_lexer.getToken().token} ';
      _lexer.next();
    }
    w.condition = w.condition.trim();
    _consumeEOL();
    w.statements = _parseBlock();
    return w;
  }

  // block = "{" { statement } "}";
  StatementList _parseBlock() {
    var block = StatementList(_lexer.getToken().row, true);
    _lexer.terminal('{');
    while (_lexer.isNotEnd() && _lexer.isNotTerminal('}')) {
      _consumeEOL();
      block.statements.add(_parseStatement());
      _consumeEOL();
    }
    _consumeEOL();
    _lexer.terminal('}');
    _consumeEOL();
    return block;
  }

  void _consumeEOL() {
    while (_lexer.isTerminal('\n')) {
      _lexer.next();
    }
  }

  void _error(String message, [LexerToken? token]) {
    var location = '';
    if (token == null) {
      location = '${_lexer.getToken().row}:${_lexer.getToken().col}:';
    } else {
      location = '${token.row}:${token.col}:';
    }
    throw Exception(location + message);
  }
}

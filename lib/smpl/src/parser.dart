/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import 'node.dart';

/// The SMPL parser.
/// Note: terms are parsed at runtime and NOT in this parser.
///       This is (much) slower than parsing offline, but increases dynamics.
/// EOL := end of line (line break or ";")
///
/// <GRAMMAR>
///   program =
///     { (statement EOL | EOL) };
///   statement =
///       declareOrAssign
///     | ifCond
///     | whileLoop
///     | doWhileLoop
///     | forLoop
///     | figure
///     | print;
///   declareOrAssign =
///     ID ["[" TERM [","TERM] "]"]   # variable ID, opt.: 1-dim or 2-dim idx
///     ( {":" ID} | {"/" ID} )   # additional variable ID(s), '/' := distinct
///     ["(" ID { "," ID } ")"]   # function parameters
///     "=" TERM                  # assign right-hand side
///     [">>>" ID ">>>" TERM [">>>" TERM]]     # TESTS: expected: type, value,
///     (";"|"\n");                            #                     stringified
///   ifCond =
///     "if" TERM block { "elif" TERM block } [ "else" block ];
///   whileLoop =
///     "while" TERM block;
///   doWhileLoop =
///     "do" BLOCK "while" TERM;
///   forLoop =
///     "for" ID "from" TERM "to" TERM block;
///   block =
///     "{" { statement EOL } "}";
///   figure =
///     "figure" "{" { figureStatement } "}";
///   figureStatement =
///       ("x_axis"|"y_axis") "(" num "," num "," STR ")"
///     | "function" "(" ID ")"
///     | "circle" "(" num "," num "," num ")";
///   print =
///       "print" TERM EOL;
///   num =
///       ["-"] INT
///     | ["-"] REAL;
/// </GRAMMAR>
class Parser {
  Lexer _lexer = Lexer();
  AstNode? _program;

  void parse(String src) {
    _lexer = Lexer();
    _lexer.enableEmitBigint(false);
    _lexer.enableEmitNewlines(true);
    _lexer.configureSingleLineComments('%');
    _lexer.configureMultiLineComments('/*', '*/');
    _lexer.enableEmitIndentation(false);
    _lexer.enableBackslashLineBreaks(false);
    _lexer.setTerminals(
        ['>>>', '&&', '||', '==', '!=', '>=', '<=', '++', '--', '@@']);
    _lexer.pushSource('FILE', src);
    _program = _parseProgram();
  }

  AstNode? getAbstractSyntaxTree() {
    return _program;
  }

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

  AstNode _parseStatement() {
    while (_lexer.isTerminal('\n')) {
      // TODO: redundant???
      _lexer.next();
    }
    switch (_lexer.getToken().token) {
      case 'let':
        _error('Keyword "let" is not allowed anymore. Just remove it :-) ');
        break;
      case 'if':
        return _parseIfCond();
      case 'while':
        return _parseWhileLoop();
      case 'do':
        return _parseDoWhileLoop();
      case 'for':
        return _parseForLoop();
      case 'figure':
        return _parseFigure();
      case 'print':
        return _parsePrint();
    }
    if (_lexer.isIdentifier()) {
      return _parseAssign();
    }
    _error(
      'unexpected token "${_lexer.getToken().token}"',
      _lexer.getToken(),
    );
    throw Exception(); // just to suppress DART warnings...
  }

  String _parseTerm(
      {bool fillSpaces = true,
      String additionalStopTerminal = "",
      String additionalStopTerminal2 = ""}) {
    var term = '';
    //TODO: _lexer.enableEmitSpaces();
    while (_lexer.isNotEnd() &&
        _lexer.isNotTerminal('\n') &&
        _lexer.isNotTerminal(';') &&
        _lexer.isNotTerminal('=') &&
        _lexer.isNotTerminal('>>>')) {
      if (additionalStopTerminal.isNotEmpty &&
          _lexer.isTerminal(additionalStopTerminal)) break;
      if (additionalStopTerminal2.isNotEmpty &&
          _lexer.isTerminal(additionalStopTerminal2)) break;
      // TODO: remove space, as soon as when emitSpaces is active
      term += _lexer.getToken().token;
      if (fillSpaces) term += ' ';
      _lexer.next();
    }
    return term.trim();
  }

  AstNode _parseAssign() {
    var row = _lexer.getToken().row;
    List<String> lhsList = [];
    lhsList.add(_lexer.identifier());
    var index1Term = '';
    var index2Term = '';
    if (_lexer.isTerminal("[")) {
      _lexer.next();
      index1Term =
          _parseTerm(additionalStopTerminal: "]", additionalStopTerminal2: ",");
      if (_lexer.isTerminal(",")) {
        _lexer.next();
        index2Term = _parseTerm(additionalStopTerminal: "]");
      }
      _lexer.terminal("]");
    }
    var lhsDelimiter =
        ''; // ":" or "/" (the latter forces variable values to be different)
    while (index1Term.isEmpty &&
        (_lexer.isTerminal(':') || _lexer.isTerminal('/'))) {
      if (lhsDelimiter == '') {
        lhsDelimiter = _lexer.getToken().token;
      } else if (lhsDelimiter != _lexer.getToken().token) {
        _error('mixing ":" and "/" is forbidden');
      }
      _lexer.next();
      lhsList.add(_lexer.identifier());
    }
    List<String> variables = [];
    var isFunction = false;
    if (_lexer.isTerminal('(')) {
      isFunction = true;
      _lexer.next();
      variables.add(_lexer.identifier());
      while (_lexer.isTerminal(',')) {
        _lexer.next();
        variables.add(_lexer.identifier());
      }
      _lexer.terminal(')');
    }
    _lexer.terminal('=');
    var term = _parseTerm();
    var expectedType = '';
    var expectedRhs = '';
    var expectedStringifiedTerm = '';
    if (_lexer.isTerminal('>>>')) {
      _lexer.next();
      expectedType = _lexer.identifier();
      _lexer.terminal('>>>');
      expectedRhs = _parseTerm();
      if (_lexer.isTerminal('>>>')) {
        _lexer.next();
        expectedStringifiedTerm = _parseTerm(fillSpaces: false);
      }
    }
    if (_lexer.isTerminal(';')) {
      _lexer.next();
    }
    _consumeEOL();
    // create AST node
    List<Assignment> assignments = [];
    for (var i = 0; i < lhsList.length; i++) {
      var lhs = lhsList[i];
      var a = Assignment(row);
      assignments.add(a);
      a.lhs = lhs;
      a.lhsIndex1 = index1Term;
      a.lhsIndex2 = index2Term;
      a.isFunction = isFunction;
      a.vars = [...variables];
      a.rhs = term.trim();
      //a.createSymbol = isDeclaration;
      a.expectedType = expectedType;
      a.expectedRhs = expectedRhs;
      a.expectedStringifiedTerm = expectedStringifiedTerm;
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

  IfCond _parseIfCond() {
    var ifCond = IfCond(_lexer.getToken().row);
    _lexer.terminal('if');
    ifCond.conditions.add(_parseTerm(additionalStopTerminal: "{"));
    _consumeEOL();
    ifCond.blocks.add(_parseBlock());
    while (_lexer.isTerminal("elif")) {
      _lexer.next();
      ifCond.conditions.add(_parseTerm(additionalStopTerminal: "{"));
      _consumeEOL();
      ifCond.blocks.add(_parseBlock());
    }
    if (_lexer.isTerminal('else')) {
      _lexer.next();
      _consumeEOL();
      ifCond.conditions.add("true");
      ifCond.blocks.add(_parseBlock());
    }
    return ifCond;
  }

  WhileLoop _parseWhileLoop() {
    var w = WhileLoop(_lexer.getToken().row);
    _lexer.terminal('while');
    w.condition = _parseTerm(additionalStopTerminal: "{");
    _consumeEOL();
    w.statements = _parseBlock();
    return w;
  }

  DoWhileLoop _parseDoWhileLoop() {
    var d = DoWhileLoop(_lexer.getToken().row);
    _lexer.terminal('do');
    d.statements = _parseBlock();
    _lexer.terminal('while');
    d.condition = _parseTerm();
    _consumeEOL();
    return d;
  }

  ForLoop _parseForLoop() {
    var f = ForLoop(_lexer.getToken().row);
    _lexer.terminal('for');
    f.variableId = _lexer.identifier();
    if (f.variableId == 'i') {
      _error("Complex 'i' can not be used as variable name in for-loops "
          "(e.g. use 'k').");
    }
    _lexer.terminal('from');
    f.lowerBound = _parseTerm(additionalStopTerminal: "to");
    _lexer.terminal('to');
    f.upperBound = _parseTerm(additionalStopTerminal: "{");
    _consumeEOL();
    f.statements = _parseBlock();
    return f;
  }

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

  Figure _parseFigure() {
    var figure = Figure(_lexer.getToken().row);
    _lexer.terminal("figure");
    _lexer.terminal("{");
    while (_lexer.isNotEnd() && _lexer.isNotTerminal('}')) {
      _consumeEOL();
      _parseFigureStatement(figure);
      _consumeEOL();
    }
    _consumeEOL();
    _lexer.terminal("}");
    _consumeEOL();
    return figure;
  }

  void _parseFigureStatement(Figure figure) {
    // TODO: line, rectangle, triangle, ...
    switch (_lexer.getToken().token) {
      case "x_axis":
      case "y_axis":
        {
          // TODO: check for valid values! min < max, width > 0, ...
          var isX = _lexer.getToken().token == "x_axis";
          _lexer.next();
          _lexer.terminal("(");
          var min = _parseRealNumber();
          _lexer.terminal(",");
          var max = _parseRealNumber();
          _lexer.terminal(",");
          var label = _lexer.string();
          _lexer.terminal(")");
          _consumeEOL();
          if (isX) {
            figure.minX = min;
            figure.maxX = max;
            figure.xLabel = label;
          } else {
            figure.minY = min;
            figure.maxY = max;
            figure.yLabel = label;
          }
          break;
        }
      case "function":
        {
          var plot = FigurePlot(FigurePlotType.function);
          figure.plots.add(plot);
          _lexer.next();
          _lexer.terminal("(");
          plot.functionId = _lexer.identifier();
          _lexer.terminal(")");
          _consumeEOL();
          break;
        }
      case "circle":
        {
          var plot = FigurePlot(FigurePlotType.circle);
          figure.plots.add(plot);
          _lexer.next();
          _lexer.terminal("(");
          plot.x = _parseRealNumber();
          _lexer.terminal(",");
          plot.y = _parseRealNumber();
          _lexer.terminal(",");
          plot.radius = _parseRealNumber();
          _lexer.terminal(")");
          _consumeEOL();
          break;
        }
      default:
        {
          _error(
            'unexpected token "${_lexer.getToken().token}"',
            _lexer.getToken(),
          );
        }
    }
  }

  Print _parsePrint() {
    var p = Print(_lexer.getToken().row);
    _lexer.terminal('print');
    p.term = _parseTerm();
    _consumeEOL();
    return p;
  }

  double _parseRealNumber() {
    var negative = false;
    if (_lexer.isTerminal("-")) {
      _lexer.next();
      negative = true;
    }
    double num = 0.0;
    if (_lexer.isInteger()) {
      num = _lexer.integer().toDouble();
    } else {
      num = _lexer.realNumber() as double;
    }
    return negative ? -num : num;
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

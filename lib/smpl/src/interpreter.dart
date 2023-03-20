/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../math-runtime/src/operand.dart';
import '../../math-runtime/src/term.dart';
import '../../math-runtime/src/parse.dart' as term_parser;

import 'node.dart';

class InterpreterSymbol {
  String id = '';
  Term term = Term.createConst(Operand.createInt(0));
  Operand value = Operand.createInt(0);
}

class Interpreter {
  /// Symbol table. The map maps identifiers to values. The list represents
  /// scopes. Initially, there is one global scope.
  /// For example, the declarations within a loop represent an own scope,
  /// that is valid until the end of the loop.
  List<Map<String, InterpreterSymbol>> _symbolTable = [];

  final term_parser.Parser _termParser = term_parser.Parser();

  bool _verbose = false;

  Interpreter({verbose = false}) {
    // TODO: term parser splits variable names of length > 1
    _verbose = verbose;
  }

  Map<String, InterpreterSymbol> runProgram(AstNode program) {
    // init
    _symbolTable = [];
    _symbolTable.add({}); // open a new scope
    // run
    _run(program);
    return _symbolTable[0];
  }

  void _run(AstNode node) {
    if (node is StatementList) {
      // ----- statement list -----
      var statementList = node;
      if (statementList.createScope) _symbolTable.add({}); // open a new scope
      for (var i = 0; i < statementList.statements.length; i++) {
        var statement = statementList.statements[i];
        _run(statement);
      }
      if (statementList.createScope) _symbolTable.removeLast(); // close scope
    } else if (node is Assignment) {
      // ----- assignment -----
      var assignment = node;
      InterpreterSymbol? symbol;
      if (assignment.createSymbol) {
        symbol = _addSymbol(assignment.lhs);
      } else {
        symbol = _getSymbol(assignment.lhs);
      }
      if (symbol == null) {
        _error('symbol "${assignment.lhs}" is unknown.'); // TODO: location
      } else {
        symbol.term = _processTerm(assignment.rhs, assignment.vars);
        if (assignment.vars.isEmpty) {
          var isOK = true;
          var k = 0;
          do {
            symbol.value = symbol.term.eval({}); // TODO: error handling
            isOK = true;
            for (var i = 0; i < assignment.independentTo.length; i++) {
              var indTo = assignment.independentTo[i];
              var s2 = _getSymbol(indTo);
              if (Operand.compareEqual(symbol.value, s2?.value as Operand)) {
                isOK = false;
                break;
              }
            }
            k++;
            if (k >= 50) {
              _error(
                'failed to create different variable values for "${symbol.id}"',
              );
            }
          } while (isOK == false);
          if (_verbose) {
            print(
              '>> assigned ${symbol.id}'
              ' := ${symbol.value} (${symbol.value.type.name})',
            );
          }
        }
      }
    } else if (node is WhileLoop) {
      // ----- while loop -----
      var whileLoop = node;
      for (;;) {
        var condition = _processTerm(whileLoop.condition, [])
            .eval({}); // TODO: error handling
        if (condition.type != OperandType.boolean) {
          _error('while loop expects a boolean condition'); // TODO: location
        }
        if (condition.real == 0) break;
        _run(whileLoop.statements as StatementList);
      }
    } else if (node is IfCond) {
      // ----- if condition -----
      var ifCond = node;
      var condition =
          _processTerm(ifCond.condition, []).eval({}); // TODO: error handling
      if (condition.type != OperandType.boolean) {
        _error('while loop expects a boolean condition'); // TODO: location
      }
      if (condition.real != 0) {
        _run(ifCond.statementsTrue as StatementList);
      } else if (ifCond.statementsFalse != null) {
        _run(ifCond.statementsFalse as StatementList);
      }
    } else if (node is Figure) {
      // ----- figure -----
      var figure = node;
      var functionIDs = figure.getReferencesFunctionIDs();
      Map<String, InterpreterSymbol> functionSymbols = {};
      for (var functionID in functionIDs) {
        var symbol = _getSymbol(functionID);
        if (symbol == null) {
          _error('figure accesses unknown function $functionID');
        } else {
          functionSymbols[functionID] = symbol;
        }
      }
      InterpreterSymbol? figureSymbol;
      figureSymbol = _addSymbol('__figure');
      var svg = figure.generateSVG(functionSymbols);
      figureSymbol.value = Operand.createString(svg);
    } else {
      throw Exception('unimplemented AstNode type ${node.runtimeType}');
    }
  }

  InterpreterSymbol _addSymbol(String id) {
    var scope = _symbolTable[_symbolTable.length - 1];
    if (scope.containsKey(id)) {
      _error('symbol "$id" already exists.'); // TODO: location
    }
    var symbol = InterpreterSymbol();
    symbol.id = id;
    scope[id] = symbol;
    return symbol;
  }

  InterpreterSymbol? _getSymbol(String id) {
    if (id.startsWith('@')) id = id.substring(1);
    var n = _symbolTable.length; // number of scopes
    for (var i = n - 1; i >= 0; i--) {
      var scope = _symbolTable[i];
      if (scope.containsKey(id)) return scope[id];
    }
    return null;
  }

  Term _processTerm(String src, List<String> keepVariables) {
    Term? term;
    try {
      term = _termParser.parse(src, splitIdentifiers: false);
    } catch (e) {
      _error('error in term "$src":$e'); // TODO: location
    }
    term = term as Term;
    var variables = term.getVariableIDs();
    for (var id in variables) {
      if (keepVariables.contains(id)) continue;
      var symbol = _getSymbol(id);
      if (symbol == null) {
        _error(
            'error in term "$src": variable $id is unknown!'); // TODO: location
      } else {
        if (id.startsWith('@')) {
          term.substituteVariableByTerm(id, symbol.term.clone());
        } else {
          term.substituteVariableByOperand(id, symbol.value.clone());
        }
      }
    }
    if (_verbose) {
      print('>> ${term.toString()}');
    }
    return term;
  }

  void _error(String message) {
    throw Exception(message); // TODO: location
  }
}

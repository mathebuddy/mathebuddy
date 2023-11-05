/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../math-runtime/src/operand.dart';
import '../../math-runtime/src/term.dart';
import '../../math-runtime/src/opt.dart';
import '../../math-runtime/src/parse.dart' as term_parser;

import 'node.dart';

class InterpreterSymbol {
  String id = '';
  Term term = Term.createConst(Operand.createInt(0));
  Operand value = Operand.createInt(0);
  bool isFunction = false; // e.g. f(x) = x^2

  String toString() {
    var s = "$id;$term;$value;$isFunction";
    return s;
  }
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
      _statementList(node);
    } else if (node is Assignment) {
      _assignment(node);
    } else if (node is WhileLoop) {
      _whileLoop(node);
    } else if (node is DoWhileLoop) {
      _doWhileLoop(node);
    } else if (node is ForLoop) {
      _forLoop(node);
    } else if (node is IfCond) {
      _ifCondition(node);
    } else if (node is Figure) {
      _figure(node);
    } else if (node is Print) {
      _print(node);
    } else {
      throw Exception('unimplemented AstNode type ${node.runtimeType}.');
    }
  }

  void _statementList(StatementList sl) {
    if (sl.createScope) _symbolTable.add({}); // open a new scope
    for (var i = 0; i < sl.statements.length; i++) {
      var statement = sl.statements[i];
      _run(statement);
    }
    if (sl.createScope) _symbolTable.removeLast(); // close scope
  }

  void _assignment(Assignment assignment) {
    var symbol = _getSymbol(assignment.lhs);
    symbol ??= _addSymbol(assignment.lhs, assignment.row);
    var oldTerm = symbol.term;
    var newTerm = _processTerm(assignment.rhs, assignment.vars, assignment.row);
    symbol.term = newTerm;
    if (assignment.isFunction) {
      symbol.isFunction = true; // TODO: also OK for indexing??
      // resolve diff, opt
      symbol.term = Term.evalFunction(symbol.term);
    } else if (assignment.rhs.replaceAll(" ", "").contains("opt(") ||
        assignment.rhs.replaceAll(" ", "").contains("term(")) {
      _error(
          assignment.row,
          '"opt(..)" and "term(..)" can ONLY be used, '
          'if variable on left-hand side is a function (e.g. "f(x)")');
    }
    if (assignment.vars.isEmpty) {
      var isOK = true;
      var k = 0;
      do {
        if (assignment.lhsIndex1.isEmpty) {
          symbol.value = symbol.term.eval({}); // TODO: error handling
        } else {
          var index1Term = _processTerm(
              assignment.lhsIndex1, assignment.vars, assignment.row);
          var index1Operand = index1Term.eval({});
          var index1Value = index1Operand.real.toInt();
          if (assignment.lhsIndex2.isNotEmpty) {
            var index2Term = _processTerm(
                assignment.lhsIndex2, assignment.vars, assignment.row);
            var index2Operand = index2Term.eval({});
            var index2Value = index2Operand.real.toInt();
            // 2-dim index
            if (symbol.value.type != OperandType.matrix) {
              _error(assignment.row, 'only matrices can be 2-dim indexed.');
            }
            if (index1Value < 0 || index1Value >= symbol.value.rows) {
              _error(assignment.row, 'index value $index1Value is invalid.');
            }
            if (index2Value < 0 || index2Value >= symbol.value.cols) {
              _error(assignment.row, 'index value $index2Value is invalid.');
            }
            symbol.value.items[index1Value * symbol.value.cols + index2Value] =
                symbol.term.eval({});
            if (oldTerm.op == "matrix") {
              symbol.term = oldTerm;
              symbol.term.o[index1Value * symbol.value.cols + index2Value] =
                  newTerm;
            } else {
              // hack (e.g. for "zeros")
              symbol.term = Term.createConst(symbol.value);
            }
          } else {
            // 1-dim index
            if (symbol.value.type != OperandType.vector) {
              _error(assignment.row, 'only vectors can be indexed.');
            }
            if (index1Value < 0 || index1Value >= symbol.value.items.length) {
              _error(assignment.row, 'index value $index1Value is invalid.');
            }
            symbol.value.items[index1Value] = symbol.term.eval({});
            if (oldTerm.op == "vec") {
              symbol.term = oldTerm;
              symbol.term.o[index1Value] = newTerm;
            } else {
              // hack (e.g. for "zeros")
              symbol.term = Term.createConst(symbol.value);
            }
          }
        }
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
            assignment.row,
            'failed to create different variable values for "${symbol.id}".',
          );
        }
      } while (isOK == false);
      if (_verbose) {
        print(
          '>> assigned ${symbol.id}'
          ' := ${symbol.value} (${symbol.value.type.name})',
        );
      }
      if (assignment.expectedRhs.isNotEmpty) {
        var expectedType = OperandType.int;
        try {
          expectedType = OperandType.values.byName(assignment.expectedType);
        } catch (e) {
          _error(assignment.row,
              'unknown/unimplemented type "${assignment.expectedType}".');
        }
        if (symbol.value.type != expectedType) {
          _error(
              assignment.row,
              'TEST FAILED: expected type "${expectedType.name}",'
              ' but got type "${symbol.value.type.name}".');
        }
        Operand? expectedValue;
        try {
          var expectedTerm = _termParser.parse(assignment.expectedRhs,
              splitIdentifiers: false);
          expectedValue = expectedTerm.eval({});
        } catch (e) {
          _error(assignment.row,
              'error in expected-term "$assignment.expectedRhs":$e.');
        }
        if (Operand.compareEqual(expectedValue!, symbol.value) == false) {
          _error(
              assignment.row,
              'expected value "${expectedValue.toString()}",'
              ' but got value "${symbol.value.toString()}".');
        }
        if (assignment.expectedStringifiedTerm.isNotEmpty) {
          var expected = assignment.expectedStringifiedTerm;
          var actual = symbol.term.toString();
          if (expected.replaceAll(' ', '') != actual.replaceAll(' ', '')) {
            _error(
                assignment.row,
                'expected stringified term "$expected",'
                ' but got "$actual"');
          }
        }
      }
    }
  }

  void _whileLoop(WhileLoop whileLoop) {
    for (;;) {
      var condition = _processTerm(whileLoop.condition, [], whileLoop.row)
          .eval({}); // TODO: error handling
      if (condition.type != OperandType.boolean) {
        _error(whileLoop.row, 'while-loop expects a boolean condition.');
      }
      if (condition.real == 0 /* 0 := false */) break;
      _run(whileLoop.statements as StatementList);
    }
  }

  void _doWhileLoop(DoWhileLoop doWhileLoop) {
    for (;;) {
      _run(doWhileLoop.statements as StatementList);
      var condition = _processTerm(doWhileLoop.condition, [], doWhileLoop.row)
          .eval({}); // TODO: error handling
      if (condition.type != OperandType.boolean) {
        _error(doWhileLoop.row, 'while-loop expects a boolean condition.');
      }
      if (condition.real == 0 /* 0 := false */) break;
    }
  }

  void _forLoop(ForLoop forLoop) {
    // TODO: error handling;
    var lowerBound = _processTerm(forLoop.lowerBound, [], forLoop.row).eval({});
    if (lowerBound.type != OperandType.int) {
      _error(forLoop.row, 'lower bound in for-loop must be integral.');
    }
    var upperBound = _processTerm(forLoop.upperBound, [], forLoop.row).eval({});
    if (upperBound.type != OperandType.int) {
      _error(forLoop.row, 'upper bound in for-loop must be integral.');
    }
    if (upperBound.real - lowerBound.real > 1e6) {
      _error(forLoop.row, 'for-loop range is too large.');
    }
    var loopVar = _addSymbol(forLoop.variableId, forLoop.row);
    loopVar.term = Term.createConstInt(lowerBound.real);
    loopVar.value = loopVar.term.eval({});
    for (;;) {
      if (loopVar.value.real > upperBound.real) {
        break;
      }
      _run(forLoop.statements as StatementList);
      loopVar.value.real++;
      loopVar.term = Term.createConstInt(loopVar.value.real);
    }
    // TODO: remove loopVar from symbol table after loop!
  }

  void _ifCondition(IfCond ifCond) {
    for (var k = 0; k < ifCond.conditions.length; k++) {
      var condSrc = ifCond.conditions[k];
      var condition = _processTerm(condSrc, [], ifCond.row)
          .eval({}); // TODO: error handling
      if (condition.type != OperandType.boolean) {
        _error(ifCond.row, 'if-statement expects a boolean conditions.');
      }
      if (condition.real != 0) {
        _run(ifCond.blocks[k]);
        break;
      }
    }
  }

  void _figure(Figure figure) {
    var functionIDs = figure.getReferencesFunctionIDs();
    Map<String, InterpreterSymbol> functionSymbols = {};
    for (var functionID in functionIDs) {
      var symbol = _getSymbol(functionID);
      if (symbol == null) {
        _error(figure.row, 'figure accesses unknown function $functionID.');
      } else {
        functionSymbols[functionID] = symbol;
      }
    }
    InterpreterSymbol? figureSymbol;
    figureSymbol = _addSymbol('__figure', figure.row);
    var svg = figure.generateSVG(functionSymbols);
    figureSymbol.value = Operand.createString(svg);
  }

  void _print(Print p) {
    var term = _processTerm(p.term, [], p.row).eval({}); // TODO: error handling
    print(">>> $term");
  }

  InterpreterSymbol _addSymbol(String id, int srcRow) {
    var scope = _symbolTable[_symbolTable.length - 1];
    if (scope.containsKey(id)) {
      _error(srcRow, 'symbol "$id" already exists.');
    }
    var symbol = InterpreterSymbol();
    symbol.id = id;
    scope[id] = symbol;
    return symbol;
  }

  InterpreterSymbol? _getSymbol(String id) {
    //if (id.startsWith('@')) id = id.substring(1);
    var n = _symbolTable.length; // number of scopes
    for (var i = n - 1; i >= 0; i--) {
      var scope = _symbolTable[i];
      if (scope.containsKey(id)) return scope[id];
    }
    return null;
  }

  Term _processTerm(String src, List<String> keepVariables, int srcRow) {
    Term term = Term.createConstInt(0);
    try {
      term = _termParser.parse(src, splitIdentifiers: false);
    } catch (e) {
      _error(srcRow, 'error in term "$src":$e');
    }
    var variables = term.getVariableIDs();
    for (var id in variables) {
      if (keepVariables.contains(id)) continue;
      var symbol = _getSymbol(id);
      if (symbol == null) {
        _error(srcRow, 'error in term "$src": variable $id is unknown!');
      } else {
        if (symbol.isFunction) {
          term.substituteVariableByTerm(id, symbol.term.clone());
        } else {
          // replaces "term(X)" by the term of X,
          // replaces "X" w/o "term(..)" by the operand of X.
          term = term.substituteVariableByTermOrOperand(
              id, symbol.term.clone(), symbol.value.clone());
        }
      }
    }
    if (_verbose) {
      print('>> ${term.toString()}');
    }
    return term;
  }

  void _error(int srcRow, String message) {
    throw Exception('[Line $srcRow] $message\n');
  }
}

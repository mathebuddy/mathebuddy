/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../math-runtime/src/operand.dart';
import '../../math-runtime/src/term.dart';
import '../../math-runtime/src/parse.dart' as termParser;
import 'parser.dart';

class InterpreterSymbol {
  String id = '';
  Term term = Term.Const(Operand.createInt(0));
  Operand value = Operand.createInt(0);
}

class Interpreter {
  List<Map<String, InterpreterSymbol>> _symbolTable = [];
  termParser.Parser _termParser = new termParser.Parser();

  Interpreter() {
    // TODO: term parser splits variable names of length > 1
  }

  Map<String, InterpreterSymbol> runProgram(AST_Node program) {
    // init
    this._symbolTable = [];
    this._symbolTable.add({}); // open a new scope
    // run
    this._run(program);
    return this._symbolTable[0];
  }

  void _run(AST_Node node) {
    if (node is StatementList) {
      // ----- statement list -----
      var statementList = node;
      if (statementList.createScope)
        this._symbolTable.add({}); // open a new scope
      for (var i = 0; i < statementList.statements.length; i++) {
        var statement = statementList.statements[i];
        this._run(statement);
      }
      if (statementList.createScope)
        this._symbolTable.removeLast(); // close scope
    } else if (node is Assignment) {
      // ----- assignment -----
      var assignment = node;
      InterpreterSymbol? symbol = null;
      if (assignment.createSymbol) {
        symbol = this._addSymbol(assignment.lhs);
      } else {
        symbol = this._getSymbol(assignment.lhs);
      }
      if (symbol == null)
        this._error('symbol "${assignment.lhs}" is unknown.'); // TODO: location
      else {
        symbol.term = this._processTerm(assignment.rhs, assignment.vars);
        if (assignment.vars.length == 0) {
          var isOK = true;
          var k = 0;
          do {
            symbol.value = symbol.term.eval({}); // TODO: error handling
            isOK = true;
            for (var i = 0; i < assignment.independentTo.length; i++) {
              var indTo = assignment.independentTo[i];
              var s2 = this._getSymbol(indTo);
              if (Operand.compareEqual(symbol.value, s2?.value as Operand)) {
                isOK = false;
                break;
              }
            }
            k++;
            if (k >= 50)
              this._error(
                'failed to create different variable values for "${symbol.id}"',
              );
          } while (isOK == false);
          print(
            '>> assigned ' +
                symbol.id +
                ' := ' +
                symbol.value.toString() +
                ' (' +
                symbol.value.type.name +
                ')',
          );
        }
      }
    } else if (node is WhileLoop) {
      // ----- while loop -----
      var whileLoop = node;
      for (;;) {
        var condition = this._processTerm(
            whileLoop.condition, []).eval({}); // TODO: error handling
        if (condition.type != OperandType.BOOLEAN)
          this._error(
              'while loop expects a boolean condition'); // TODO: location
        if (condition.real == 0) break;
        this._run(whileLoop.statements as StatementList);
      }
    } else if (node is IfCond) {
      // ----- if condition -----
      var ifCond = node;
      var condition = this
          ._processTerm(ifCond.condition, []).eval({}); // TODO: error handling
      if (condition.type != OperandType.BOOLEAN)
        this._error('while loop expects a boolean condition'); // TODO: location
      if (condition.real != 0)
        this._run(ifCond.statementsTrue as StatementList);
      else if (ifCond.statementsFalse != null)
        this._run(ifCond.statementsFalse as StatementList);
    } else {
      throw new Exception('unimplemented');
    }
  }

  InterpreterSymbol _addSymbol(String id) {
    var scope = this._symbolTable[this._symbolTable.length - 1];
    if (scope.containsKey(id))
      this._error('symbol "${id}" already exists.'); // TODO: location
    var symbol = new InterpreterSymbol();
    symbol.id = id;
    scope[id] = symbol;
    return symbol;
  }

  InterpreterSymbol? _getSymbol(String id) {
    if (id.startsWith('@')) id = id.substring(1);
    var n = this._symbolTable.length; // number of scopes
    for (var i = n - 1; i >= 0; i--) {
      var scope = this._symbolTable[i];
      if (scope.containsKey(id)) return scope[id];
    }
    return null;
  }

  Term _processTerm(String src, List<String> keepVariables) {
    Term? term = null;
    try {
      term = this._termParser.parse(src);
    } catch (e) {
      this._error('error in term "${src}":' + e.toString()); // TODO: location
    }
    term = term as Term;
    var variables = term.getVariableIDs();
    for (var id in variables) {
      if (keepVariables.contains(id)) continue;
      var symbol = this._getSymbol(id);
      if (symbol == null) {
        this._error(
            'error in term "${src}": variable ${id} is unknown!'); // TODO: location
      } else {
        if (id.startsWith('@')) {
          term.substituteVariableByTerm(id, symbol.term.clone());
        } else {
          term.substituteVariableByOperand(id, symbol.value.clone());
        }
      }
    }
    print('>> ' + term.toString());
    return term;
  }

  void _error(String message) {
    throw new Exception(message); // TODO: location
  }
}

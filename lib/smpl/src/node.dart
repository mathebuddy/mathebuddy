/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../math-runtime/src/operand.dart';

import "help.dart";
import "interpreter.dart";

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
  String expectedType = ''; // used for test cases
  String expectedRhs = ''; // used for test cases
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
        'expected=[$expectedType,${expectedRhs.trim()}],'
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

class Figure extends AstNode {
  double minX = -5;
  double maxX = 5;
  double minY = -5;
  double maxY = 5;
  String xLabel = "x";
  String yLabel = "y";
  List<FigurePlot> plots = [];

  Figure(super.row);

  Set<String> getReferencesFunctionIDs() {
    Set<String> ids = {};
    for (var plot in plots) {
      if (plot.type == FigurePlotType.function) {
        ids.add(plot.functionId);
      }
    }
    return ids;
  }

  String generateSVG(Map<String, InterpreterSymbol> functionSymbols) {
    var width = maxX - minX;
    var height = maxY - minY;
    var code = '';
    for (var plot in plots) {
      switch (plot.type) {
        case FigurePlotType.circle:
          {
            var cx = plot.x.toStringAsFixed(3);
            var cy = plot.y.toStringAsFixed(3);
            var radius = plot.radius.toStringAsFixed(3);
            code += '  <circle cx="$cx" cy="$cy" r="$radius" fill="none" '
                'style="stroke: rgb(0,0,0); stroke-width: 0.05"/>\n';
            break;
          }
        case FigurePlotType.function:
          {
            var functionSymbol =
                functionSymbols[plot.functionId] as InterpreterSymbol;
            var numPoints = 50; // TODO: add to config file
            var h = width / numPoints.toDouble();
            var pointsCode = '';
            for (var x = minX; x <= maxY; x += h) {
              var y =
                  functionSymbol.term.eval({"x": Operand.createReal(x)}).real;
              if (y < minY * 2 || y > maxY * 2) continue;
              pointsCode += '${x.toStringAsFixed(3)} ${y.toStringAsFixed(3)} ';
            }
            code += '  <polyline points="$pointsCode" fill="none" '
                'style="stroke: rgb(0,0,0); stroke-width: 0.05"/>\n';
            break;
          }
      }
    }
    var svg = '<svg xmlns="http://www.w3.org/2000/svg"'
        ' width="$width" viewBox="$minX ${-minY - height} $width $height">\n'
        '  <g transform="scale(1,-1)">'
        '$code</g></svg>\n';
    //var base64 = base64Encode(utf8.encode(svg));
    //var encoded = 'data:image/svg+xml;base64,$base64';
    //return encoded;
    return svg;
  }

  @override
  String toString([int indent = 0]) {
    // TODO
    return ('${spaces(indent)}'
        'FIGURE:<data-not-yet-displayed-here>;\n');
  }
}

enum FigurePlotType {
  function,
  circle // TODO: rectangle, ...
}

class FigurePlot {
  FigurePlotType type;
  double x = 0.0; // relevant for type == circle
  double y = 0.0; // relevant for type == circle
  double radius = 0.0; // relevant for type == circle
  String functionId = ""; // relevant for type == function
  FigurePlot(this.type);
}

/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_compiler;

import 'package:slex/slex.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';

/// <GRAMMAR>
///   inlineMathCore =
///     { "term" "(" ID ")" | "term" "(" ID ")" | ID } .."$";
/// </GRAMMAR>
MbclLevelItem parseInlineMath(
    MbclLevel level, Lexer lexer, MbclLevelItem? exercise) {
  var lastTk = "";
  if (lexer.isTerminal('\$')) lexer.next();
  var inlineMath = MbclLevelItem(level, MbclLevelItemType.inlineMath, -1);
  while (lexer.isNotTerminal('\$') && lexer.isNotEnd()) {
    var tk = lexer.getToken().token;
    // ID | "opt" "(" ID ")" | "term" "(" ID ")";
    var showTerm = false;
    var showOptimizedTerm = false;
    var id = lexer.getToken().token;
    var isId = lexer.getToken().type == LexerTokenType.id;
    if (lexer.isTerminal("term")) {
      showTerm = true;
    } else if (lexer.isTerminal("opt")) {
      showOptimizedTerm = true;
    }
    lexer.next();
    if (showTerm || showOptimizedTerm) {
      if (lexer.isTerminal("(")) lexer.next();
      id = lexer.getToken().token;
      isId = lexer.getToken().type == LexerTokenType.id;
      lexer.next();
      if (lexer.isTerminal(")")) lexer.next();
    }
    // variable reference ?
    if (isId && exercise != null) {
      var data = exercise.exerciseData!;
      if (data.variables.contains(id)) {
        var type = MbclLevelItemType.variableReferenceOperand;
        if (showTerm || data.functionVariables.contains(id)) {
          type = MbclLevelItemType.variableReferenceTerm;
        }
        if (showOptimizedTerm) {
          type = MbclLevelItemType.variableReferenceOptimizedTerm;
        }
        var v = MbclLevelItem(level, type, -1);
        v.id = id;
        inlineMath.items.add(v);
        continue;
      }
    }
    // default (no variable reference)
    var text = MbclLevelItem(level, MbclLevelItemType.text, -1);
    if (lastTk == "\\") {
      text.text = tk;
    } else {
      text.text = " " + tk;
    }
    inlineMath.items.add(text);
    lastTk = tk;
  }
  if (lexer.isTerminal('\$')) lexer.next();
  return inlineMath;
}

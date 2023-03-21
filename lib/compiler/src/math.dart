/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import '../../mbcl/src/level_item.dart';

MbclLevelItem parseInlineMath(Lexer lexer, MbclLevelItem? exercise) {
  if (lexer.isTerminal('\$')) lexer.next();
  var inlineMath = MbclLevelItem(MbclLevelItemType.inlineMath);
  while (lexer.isNotTerminal('\$') && lexer.isNotEnd()) {
    var tk = lexer.getToken().token;
    var isId = lexer.getToken().type == LexerTokenType.id;
    lexer.next();
    if (isId &&
        exercise != null &&
        (exercise.exerciseData as MbclExerciseData).variables.contains(tk)) {
      var v = MbclLevelItem(MbclLevelItemType.variableReference);
      v.id = tk;
      inlineMath.items.add(v);
    } else {
      var text = MbclLevelItem(MbclLevelItemType.text);
      text.text = tk;
      inlineMath.items.add(text);
    }
  }
  if (lexer.isTerminal('\$')) lexer.next();
  return inlineMath;
}

/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_compiler;

import 'package:slex/slex.dart';

import '../../math-runtime/src/operand.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/level_item_input_field.dart';

import 'compiler.dart';
import 'exercise.dart';
import 'math.dart';
import 'input.dart';
import 'help.dart';

/// <GRAMMAR>
///   paragraph =
///       { part };
///   part =
///       itemize
///     | enumerate
///     | enumerateAlpha
///     | bold
///     | italic
///     | inlineMath
///     | inlineCode
///     | reference
///     | <PARSING_EXERCISE> inputElement
///     | <PARSING_EXERCISE> singleChoiceOption
///     | <PARSING_EXERCISE> multipleChoiceOption
///     | linefeed
///     | textProperty
///     | text;
///   itemize =
///         <COLUMN=1>  "-"      { part } "\n"
///       { <COLUMN=1> ("-"|" ") { part } "\n" };
///   enumerate =
///         <COLUMN=1>  "#."      { part } "\n"
///       { <COLUMN=1> ("#."|" ") { part } "\n" };
///   enumerateAlpha =
///         <COLUMN=1>  "-)"      { part } "\n"
///       { <COLUMN=1> ("-)"|" ") { part } "\n" };
///   bold =
///       "**" { part } "**";
///   italic =
///       "*" { part } "*";
///   inlineMath =
///       "$" inlineMathCore "$";
///   inlineCode =
///       "`" * "`";
///   reference =
///       "@" ID [ ":" ID ];
///   singleChoiceOption =
///       <COLUMN=1> "(" ( "x" | ":" ID | <EMPTY> ) ")" { part } "\n";
///   multipleChoiceOption =
///       <COLUMN=1> "[" ( "x" | ":" ID | <EMPTY> ) "]" { part } "\n";
///   lineFeed =
///       "\n";
///   textProperty =
///       <COLUMN!=1> "[" { part } "]" "@" ( "bold" | "italic" | "color" INT );
///   text =
///       *;
/// </GRAMMAR>
class Paragraph {
  MbclLevel level;
  Compiler compiler;

  Paragraph(this.level, this.compiler);

  List<MbclLevelItem> parse(String raw, int srcRowIdx, [MbclLevelItem? ex]) {
    // skip empty paragraphs
    if (raw.trim().isEmpty) {
      return [MbclLevelItem(level, MbclLevelItemType.paragraph, srcRowIdx)];
    }
    // create lexer
    var lexer = Lexer();
    lexer.enableEmitSingleQuotes(false);
    lexer.enableEmitBigint(false);
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.setTerminals(['**', '#.', '-)', '@@', '///']);
    lexer.configureSingleLineComments('/////');
    lexer.pushSource('', raw);
    List<MbclLevelItem> res = [];
    while (lexer.isNotEnd()) {
      var part = _parsePart(lexer, srcRowIdx, ex);
      switch (part.type) {
        case MbclLevelItemType.itemize:
        case MbclLevelItemType.enumerate:
        case MbclLevelItemType.enumerateAlpha:
        case MbclLevelItemType.singleChoice:
        case MbclLevelItemType.multipleChoice:
          res.add(part);
          break;
        case MbclLevelItemType.lineFeed:
          res.add(MbclLevelItem(level, MbclLevelItemType.paragraph, srcRowIdx));
          break;
        default:
          if (res.isNotEmpty && res.last.type == MbclLevelItemType.paragraph) {
            res.last.items.add(part);
          } else {
            var paragraph =
                MbclLevelItem(level, MbclLevelItemType.paragraph, srcRowIdx);
            res.add(paragraph);
            paragraph.items.add(part);
          }
      }
    }
    // remove unnecessary line feeds at end
    while (res.isNotEmpty &&
        res.last.type == MbclLevelItemType.paragraph &&
        res.last.items.isEmpty) {
      res.removeLast();
    }
    return res;
  }

  MbclLevelItem _parsePart(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    if (lexer.getToken().col == 1 &&
        (lexer.isTerminal('-') ||
            lexer.isTerminal('#.') ||
            lexer.isTerminal('-)'))) {
      // itemize or enumerate
      return _parseItemize(lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('**')) {
      // bold text
      return _parseBoldText(lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('*')) {
      // italic text
      return _parseItalicText(lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('\$')) {
      // inline math
      return parseInlineMath(level, lexer, exercise);
    } else if (lexer.isTerminal('`')) {
      // inline code
      return _parseInlineCode(lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('@')) {
      // reference
      return _parseReference(lexer, srcRowIdx);
    } else if (exercise != null && lexer.isTerminal('#')) {
      // input element(s)
      return parseInputElement(level, lexer, srcRowIdx, exercise);
    } else if (exercise != null &&
        lexer.getToken().col == 1 &&
        (lexer.isTerminal('[') || lexer.isTerminal('('))) {
      // single or multiple choice answer
      return _parseSingleOrMultipleChoice(compiler, lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('\n')) {
      // line feed
      var isNewParagraph = lexer.getToken().col == 1;
      lexer.next();
      if (isNewParagraph) {
        return MbclLevelItem(level, MbclLevelItemType.lineFeed, srcRowIdx);
      } else {
        return MbclLevelItem(level, MbclLevelItemType.text, srcRowIdx);
      }
    } else if (lexer.isTerminal('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return _parseTextProperty(lexer, srcRowIdx, exercise);
    } else if (lexer.isTerminal('///')) {
      lexer.next();
      return MbclLevelItem(
          level, MbclLevelItemType.languageSeparator, srcRowIdx);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      var text = MbclLevelItem(level, MbclLevelItemType.text, srcRowIdx);
      text.text = lexer.getToken().token;
      lexer.next();
      return text;
    }
  }

  MbclLevelItem _parseItemize(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    // '-' for itemize; '#.' for enumerate; '-)' for alpha enumerate
    var typeStr = lexer.getToken().token;
    MbclLevelItemType type = MbclLevelItemType.itemize;
    switch (typeStr) {
      case '-':
        type = MbclLevelItemType.itemize;
        break;
      case '#.':
        type = MbclLevelItemType.enumerate;
        break;
      case '-)':
        type = MbclLevelItemType.enumerateAlpha;
        break;
    }
    var itemize = MbclLevelItem(level, type, srcRowIdx);
    int rowIdx;
    while (lexer.getToken().col == 1 &&
        lexer.isTerminal(typeStr) &&
        lexer.isNotEnd()) {
      rowIdx = lexer.getToken().row;
      lexer.next();
      var span = MbclLevelItem(level, MbclLevelItemType.span, srcRowIdx);
      itemize.items.add(span);
      while (lexer.isNotNewline() && lexer.isNotEnd()) {
        span.items.add(_parsePart(lexer, srcRowIdx, exercise));
      }
      if (lexer.isNewline()) {
        lexer.newline();
      }
      // parse all consecutive lines, that belong to the item. These lines
      // are indicated by preceding spaces.
      while (lexer.getToken().col > 1 && lexer.isNotEnd()) {
        if (lexer.getToken().row - rowIdx > 1) {
          span.items.add(
              MbclLevelItem(level, MbclLevelItemType.text, srcRowIdx, '\n'));
        }
        rowIdx = lexer.getToken().row;
        while (lexer.isNotNewline() && lexer.isNotEnd()) {
          var p = _parsePart(lexer, srcRowIdx, exercise);
          span.items.add(p);
        }
        if (lexer.isNewline()) {
          lexer.newline();
        }
      }
    }
    // For rendering purposes, items should NOT start with inline math.
    // We add an invisible text item in these cases before the inline math item.
    for (var span in itemize.items) {
      if (span.items.isNotEmpty &&
          span.items[0].type == MbclLevelItemType.inlineMath) {
        var str = '';
        var text = MbclLevelItem(
            level, MbclLevelItemType.text, span.items[0].srcLine, str);
        span.items.insert(0, text);
      }
    }
    // return result
    return itemize;
  }

  MbclLevelItem _parseBoldText(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    var bold = MbclLevelItem(level, MbclLevelItemType.boldText, srcRowIdx);
    while (lexer.isNotTerminal('**') && lexer.isNotEnd()) {
      bold.items.add(_parsePart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('**')) lexer.next();
    return bold;
  }

  MbclLevelItem _parseItalicText(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    var italic = MbclLevelItem(level, MbclLevelItemType.italicText, srcRowIdx);
    while (lexer.isNotTerminal('*') && lexer.isNotEnd()) {
      italic.items.add(_parsePart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('*')) lexer.next();
    return italic;
  }

  MbclLevelItem _parseInlineCode(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    var inlineCode =
        MbclLevelItem(level, MbclLevelItemType.inlineCode, srcRowIdx);
    while (lexer.isNotTerminal('`') && lexer.isNotEnd()) {
      var token = lexer.getToken();
      inlineCode.text += token.token;
      lexer.next();
      var newCol = lexer.getToken().col;
      if (newCol > token.col + token.token.length) {
        var spaces = newCol - token.col - token.token.length;
        for (var i = 0; i < spaces; i++) {
          inlineCode.text += ' ';
        }
      }
    }
    if (lexer.isTerminal('`')) lexer.next();
    return inlineCode;
  }

  MbclLevelItem _parseReference(Lexer lexer, int srcRowIdx) {
    lexer.next(); // skip '@'
    var ref = MbclLevelItem(level, MbclLevelItemType.reference, srcRowIdx);
    var label = '';
    if (lexer.isIdentifier()) {
      label = lexer.getToken().token;
      lexer.next();
      if (lexer.isTerminal(":")) {
        label += lexer.getToken().token;
        lexer.next();
        if (lexer.isIdentifier()) {
          label += lexer.getToken().token;
          lexer.next();
        }
      }
    }
    ref.label = label;
    return ref;
  }

  MbclLevelItem _parseSingleOrMultipleChoice(
    Compiler compiler,
    Lexer lexer,
    int srcRowIdx,
    MbclLevelItem exercise,
  ) {
    var exerciseData = exercise.exerciseData!;
    var isMultipleChoice = lexer.isTerminal('[');
    lexer.next();
    var staticallyCorrect = false;
    var varId = '';
    if (lexer.isTerminal('x')) {
      lexer.next();
      staticallyCorrect = true;
    } else if (lexer.isTerminal(':')) {
      lexer.next();
      if (lexer.isIdentifier()) {
        varId = lexer.identifier();
        if (exerciseData.variables.contains(varId) == false) {
          exercise.error += ' Unknown variable "$varId".';
        }
      } else {
        exercise.error += ' Expected ID after ":".';
      }
    }
    MbclLevelItem root =
        MbclLevelItem(level, MbclLevelItemType.multipleChoice, srcRowIdx);
    if (varId.isEmpty) {
      varId = addStaticVariable(exerciseData, OperandType.boolean,
          staticallyCorrect ? 'true' : 'false');
    }
    if (isMultipleChoice) {
      if (lexer.isTerminal(']')) {
        lexer.next();
      } else {
        exercise.error += ' Expected "]".';
      }
      root.type = MbclLevelItemType.multipleChoice;
    } else {
      if (lexer.isTerminal(')')) {
        lexer.next();
      } else {
        exercise.error += ' Expected ")".';
      }
      root.type = MbclLevelItemType.singleChoice;
    }

    var inputField =
        MbclLevelItem(level, MbclLevelItemType.inputField, srcRowIdx);
    var inputFieldData = MbclInputFieldData();
    inputField.inputFieldData = inputFieldData;
    inputField.id = 'input${createUniqueId()}';
    inputFieldData.type = MbclInputFieldType.bool;
    inputFieldData.variableId = varId;
    root.items.add(inputField);
    exerciseData.inputFields.add(inputField);

    var span = MbclLevelItem(level, MbclLevelItemType.span, srcRowIdx);
    inputField.items.add(span);
    while (lexer.isNotNewline() && lexer.isNotEnd()) {
      span.items.add(_parsePart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('\n')) lexer.next();
    return root;
  }

  MbclLevelItem _parseTextProperty(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    List<MbclLevelItem> items = [];
    while (lexer.isNotTerminal(']') && lexer.isNotEnd()) {
      items.add(_parsePart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal(']')) {
      lexer.next();
    } else {
      return MbclLevelItem(
          level, MbclLevelItemType.error, srcRowIdx, ' Expected "]".');
    }
    if (lexer.isTerminal('@')) {
      lexer.next();
    } else {
      return MbclLevelItem(
          level, MbclLevelItemType.error, srcRowIdx, ' Expected "@".');
    }
    if (lexer.isIdentifier()) {
      var id = lexer.identifier();
      if (id == 'bold') {
        var bold = MbclLevelItem(level, MbclLevelItemType.boldText, srcRowIdx);
        bold.items = items;
        return bold;
      } else if (id == 'italic') {
        var italic =
            MbclLevelItem(level, MbclLevelItemType.italicText, srcRowIdx);
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        var color = MbclLevelItem(level, MbclLevelItemType.color, srcRowIdx);
        color.id = id.substring(5); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return MbclLevelItem(level, MbclLevelItemType.error, srcRowIdx,
            ' Unknown property $id.');
      }
    } else {
      return MbclLevelItem(level, MbclLevelItemType.error, srcRowIdx,
          ' Missing property name. ');
    }
  }
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import '../../math-runtime/src/operand.dart';

import '../../mbcl/src/level_item.dart';

import 'compiler.dart';
import 'exercise.dart';
import 'math.dart';

class Paragraph {
  Compiler compiler;

  Paragraph(this.compiler);

  /*G
     paragraph =
        { paragraphPart };
     paragraphPart =
      | "**" {paragraphPart} "**"
      | "*" {paragraphPart} "*"
      | "[" {paragraphPart} "]" "@" ID
      | "$" inlineMath "$"
      | "#" ID                                     (exercise only)
      | <START>"[" [ ("x"|":"ID) ] "]" {paragraphPart} "\n"  (exercise only)
      | <START>"(" [ ("x"|":"ID) ] ")" {paragraphPart} "\n"  (exercise only)
      | <START>"#" {paragraphPart} "\n"
      | <START>"-" {paragraphPart} "\n"
      | <START>"-)" {paragraphPart} "\n"
      | ID
      | DEL;
   */
  // TODO: RENAME METHOD!!
  List<MbclLevelItem> parseParagraph(String raw, int srcRowIdx,
      [MbclLevelItem? ex]) {
    // skip empty paragraphs
    if (raw.trim().isEmpty) {
      return [MbclLevelItem(MbclLevelItemType.paragraph, srcRowIdx)];
    }
    // create lexer
    var lexer = Lexer();
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.pushSource('', raw);
    lexer.setTerminals(['**', '#.', '-)', '@@']);
    List<MbclLevelItem> res = [];
    while (lexer.isNotEnd()) {
      var part = _parseParagraphPart(lexer, srcRowIdx, ex);
      switch (part.type) {
        case MbclLevelItemType.itemize:
        case MbclLevelItemType.enumerate:
        case MbclLevelItemType.enumerateAlpha:
        case MbclLevelItemType.singleChoice:
        case MbclLevelItemType.multipleChoice:
          res.add(part);
          break;
        case MbclLevelItemType.lineFeed:
          res.add(MbclLevelItem(MbclLevelItemType.paragraph, srcRowIdx));
          break;
        default:
          if (res.isNotEmpty && res.last.type == MbclLevelItemType.paragraph) {
            res.last.items.add(part);
          } else {
            var paragraph =
                MbclLevelItem(MbclLevelItemType.paragraph, srcRowIdx);
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

  MbclLevelItem _parseParagraphPart(
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
      return parseInlineMath(lexer, exercise);
    } else if (lexer.isTerminal('@')) {
      // reference
      return _parseReference(lexer, srcRowIdx);
    } else if (exercise != null && lexer.isTerminal('#')) {
      // input element(s)
      return _parseInputElements(lexer, srcRowIdx, exercise);
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
        return MbclLevelItem(MbclLevelItemType.lineFeed, srcRowIdx);
      } else {
        return MbclLevelItem(MbclLevelItemType.text, srcRowIdx);
      }
    } else if (lexer.isTerminal('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return _parseTextProperty(lexer, srcRowIdx, exercise);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      var text = MbclLevelItem(MbclLevelItemType.text, srcRowIdx);
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
    var itemize = MbclLevelItem(type, srcRowIdx);
    int rowIdx;
    while (lexer.getToken().col == 1 &&
        lexer.isTerminal(typeStr) &&
        lexer.isNotEnd()) {
      rowIdx = lexer.getToken().row;
      lexer.next();
      var span = MbclLevelItem(MbclLevelItemType.span, srcRowIdx);
      itemize.items.add(span);
      while (lexer.isNotNewline() && lexer.isNotEnd()) {
        span.items.add(_parseParagraphPart(lexer, srcRowIdx, exercise));
      }
      if (lexer.isNewline()) {
        lexer.newline();
      }
      // parse all consecutive lines, that belong to the item. These lines
      // are indicated by preceding spaces.
      while (lexer.getToken().col > 1 && lexer.isNotEnd()) {
        if (lexer.getToken().row - rowIdx > 1) {
          span.items
              .add(MbclLevelItem(MbclLevelItemType.text, srcRowIdx, '\n'));
        }
        rowIdx = lexer.getToken().row;
        while (lexer.isNotNewline() && lexer.isNotEnd()) {
          var p = _parseParagraphPart(lexer, srcRowIdx, exercise);
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
        var text =
            MbclLevelItem(MbclLevelItemType.text, span.items[0].srcLine, str);
        span.items.insert(0, text);
      }
    }
    // return result
    return itemize;
  }

  MbclLevelItem _parseBoldText(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    var bold = MbclLevelItem(MbclLevelItemType.boldText, srcRowIdx);
    while (lexer.isNotTerminal('**') && lexer.isNotEnd()) {
      bold.items.add(_parseParagraphPart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('**')) lexer.next();
    return bold;
  }

  MbclLevelItem _parseItalicText(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    lexer.next();
    var italic = MbclLevelItem(MbclLevelItemType.italicText, srcRowIdx);
    while (lexer.isNotTerminal('*') && lexer.isNotEnd()) {
      italic.items.add(_parseParagraphPart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('*')) lexer.next();
    return italic;
  }

  MbclLevelItem _parseReference(Lexer lexer, int srcRowIdx) {
    lexer.next(); // skip '@'
    var ref = MbclLevelItem(MbclLevelItemType.reference, srcRowIdx);
    var label = '';
    if (lexer.isIdentifier()) {
      label = lexer.getToken().token;
      lexer.next();
    }
    if (lexer.isTerminal(":")) {
      label += lexer.getToken().token;
      lexer.next();
    }
    if (lexer.isIdentifier()) {
      label += lexer.getToken().token;
      lexer.next();
    }
    ref.label = label;
    return ref;
  }

  MbclLevelItem _parseInputElements(
      Lexer lexer, int srcRowIdx, MbclLevelItem exercise) {
    lexer.next();
    var inputField = MbclLevelItem(MbclLevelItemType.inputField, srcRowIdx);
    var data = MbclInputFieldData();
    inputField.inputFieldData = data;
    inputField.id = 'input${compiler.createUniqueId()}';
    var exerciseData = exercise.exerciseData as MbclExerciseData;
    exerciseData.inputFields[inputField.id] = data;
    if (lexer.isIdentifier()) {
      data.variableId = lexer.identifier();
      if (exerciseData.variables.contains(data.variableId)) {
        var opType = OperandType.values
            .byName(exerciseData.smplOperandType[data.variableId] as String);
        //input.id = data.variableId;
        switch (opType) {
          case OperandType.int:
            data.type = MbclInputFieldType.int;
            break;
          case OperandType.rational:
            data.type = MbclInputFieldType.rational;
            break;
          case OperandType.real:
            data.type = MbclInputFieldType.real;
            break;
          case OperandType.complex:
            // TODO: keyboard with and without sqrt ??
            //if (xyz) {
            //  data.type = MbclInputFieldType.complexNormalXXX;
            //} else {
            data.type = MbclInputFieldType.complexNormal;
            //}
            break;
          case OperandType.matrix:
            data.type = MbclInputFieldType.matrix;
            break;
          case OperandType.set:
            // TODO: intSet, realSet, termSet, complexIntSet, ...
            data.type = MbclInputFieldType.complexIntSet;
            break;
          default:
            exercise.error += ' UNIMPLEMENTED input type ${opType.name}. ';
        }
      } else {
        exercise.error += ' There is no variable "${data.variableId}". ';
      }
    } else {
      exercise.error += ' No variable for input field given. ';
    }
    return inputField;
  }

  MbclLevelItem _parseSingleOrMultipleChoice(
    Compiler compiler,
    Lexer lexer,
    int srcRowIdx,
    MbclLevelItem exercise,
  ) {
    var exerciseData = exercise.exerciseData as MbclExerciseData;
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
        MbclLevelItem(MbclLevelItemType.multipleChoice, srcRowIdx);
    if (varId.isEmpty) {
      varId = addStaticBooleanVariable(exerciseData, staticallyCorrect);
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

    var inputField = MbclLevelItem(MbclLevelItemType.inputField, srcRowIdx);
    var inputFieldData = MbclInputFieldData();
    inputField.inputFieldData = inputFieldData;
    inputField.id = 'input${compiler.createUniqueId()}';
    inputFieldData.type = MbclInputFieldType.bool;
    inputFieldData.variableId = varId;
    root.items.add(inputField);
    exerciseData.inputFields[inputField.id] = inputFieldData;

    /*
    var option = MbclLevelItem(MbclLevelItemType.multipleChoiceOption);
    var data = MbclSingleOrMultipleChoiceOptionData();
    option.singleOrMultipleChoiceOptionData = data;
    if (root.type == MbclLevelItemType.singleChoice) {
      option.type = MbclLevelItemType.singleChoiceOption;
    }
    data.inputId = 'input${createUniqueId()}';
    data.variableId = varId;
    root.items.add(option);*/

    var span = MbclLevelItem(MbclLevelItemType.span, srcRowIdx);
    inputField.items.add(span);
    while (lexer.isNotNewline() && lexer.isNotEnd()) {
      span.items.add(_parseParagraphPart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal('\n')) lexer.next();
    return root;
  }

  MbclLevelItem _parseTextProperty(
      Lexer lexer, int srcRowIdx, MbclLevelItem? exercise) {
    // TODO: make sure, that errors are not too annoying...
    lexer.next();
    List<MbclLevelItem> items = [];
    while (lexer.isNotTerminal(']') && lexer.isNotEnd()) {
      items.add(_parseParagraphPart(lexer, srcRowIdx, exercise));
    }
    if (lexer.isTerminal(']')) {
      lexer.next();
    } else {
      return MbclLevelItem(
          MbclLevelItemType.error, srcRowIdx, ' Expected "]".');
    }
    if (lexer.isTerminal('@')) {
      lexer.next();
    } else {
      return MbclLevelItem(
          MbclLevelItemType.error, srcRowIdx, ' Expected "@".');
    }
    if (lexer.isIdentifier()) {
      var id = lexer.identifier();
      if (id == 'bold') {
        var bold = MbclLevelItem(MbclLevelItemType.boldText, srcRowIdx);
        bold.items = items;
        return bold;
      } else if (id == 'italic') {
        var italic = MbclLevelItem(MbclLevelItemType.italicText, srcRowIdx);
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        var color = MbclLevelItem(MbclLevelItemType.color, srcRowIdx);
        color.id = id.substring(5); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return MbclLevelItem(
            MbclLevelItemType.error, srcRowIdx, ' Unknown property $id.');
      }
    } else {
      return MbclLevelItem(
          MbclLevelItemType.error, srcRowIdx, ' Missing property name. ');
    }
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:path/path.dart' as Path;
import 'package:slex/slex.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/level_item_equation.dart';
import '../../mbcl/src/level_item_table.dart';
import '../../mbcl/src/level_item_exercise.dart';
import '../../mbcl/src/level_item_figure.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

import 'compiler.dart';
import 'exercise.dart';
import 'help.dart';
import 'math.dart';
import 'block.dart';
import 'paragraph.dart';
import 'level_item.dart';

/// <GRAMMAR input=pre_parsed_source>
///   level [defaultChild="STRUCTURED_PARAGRAPH"] =
///       "ROOT" INDENT
///         { levelItem }
///       DEDENT;
///   levelItem =
///       part
///     | exercise
///     | code
///     | exampleDefinition
///     | alignment
///     | equation
///     | table
///     | figure
///     | text
///     | structuredParagraph;
///   part =
///     "PART" INDENT
///       [ "ICON" "=" value; "\n" ]
///     DEDENT
///   exercise [defaultChild="PARAGRAPH"] =
///     "EXERCISE" [ title ] [ label ] INDENT
///       [ "REQUIREMENT" "=" label { "," label } "\n" ]
///       [ "ORDER" "=" ("static"|"shuffled") "\n" ]
///       [ "CHOICE_ALIGNMENT" "=" ("horizontal"|"vertical") "\n" ]
///       [ "DISABLE_RETRY" "=" ("true"|"false") "\n" ]
///       [ "TIME" "=" INT "\n" ]
///       [ "SCORES" "=" INT "\n" ]
///       [ "INSTANCES" "=" INT "\n" ]
///       { levelItem }
///     DEDENT;
///   code =
///     "CODE" IDENT
///       SMPL_CODE;
///     DEDENT;
///   exampleDefinition [defaultChild="PARAGRAPH"] =
///     exampleDefinitionKeyword [ title ] [ label ] INDENT
///       { levelItem }
///     DEDENT;
///   exampleDefinitionKeyword =
///       "AXIOM" | "CLAIM" | "CONJECTURE" | "COROLLARY"
///     | "DEFINITION" | "EXAMPLE" | "IDENTITY" | "LEMMA" | "PARADOX"
///     | "PROPOSITION" | "THEOREM" | "TODO".
///   alignment [defaultChild="PARAGRAPH"] =
///     alignmentKeyword INDENT
///       { levelItem }
///     DEDENT;
///   alignmentKeyword =
///     "CENTER" | "LEFT" | "RIGHT";
///   equation =
///     equationKeyword ["*"] [ label ] INDENT
///       *
///     DEDENT;
///   equationKeyword =
///       "ALIGNED-EQUATION"
///     | "LEFT-EQUATION"
///     | "EQUATION";
///   table =
///     "TABLE" [ title ] [ label ] IDENT
///       { table_row }
///     DEDENT;
///   table_row =
///     table_column { "&" table_column } "\n";
///   table_column =
///     paragraph;
///   figure [defaultChild="CAPTION"] =
///     "FIGURE" [ title ] [ label ] IDENT
///       [ "PATH" "=" value ] "\n"
///       [ "WIDTH" "=" INT ] "\n"
///       { code | caption }
///     DEDENT;
///   caption =
///     "CAPTION" INDENT
///       *
///     DEDENT;
///   text [defaultChild="TEXT"] =
///     "TEXT" INDENT
///       { levelItem };
///     DEDENT;
///   title =
///     { <!"@" && !"\n"> };
///   label =
///     "@" { <!"\n"> };
///   value =
///     { <!"\n"> };
///   structuredParagraph =
///     "STRUCTURED_PARAGRAPH" INDENT
///       { structuredParagraphPart };
///     DEDENT;
///   structuredParagraphPart =
///       levelTitle
///     | section
///     | subSection
///     | paragraph;
///   levelTitle =
///     * "\n" "####" * "\n";
///   section =
///     * "\n" "====" * "\n";
///   subSection =
///     * "\n" "----" * "\n";
/// </GRAMMAR>
void parseLevelBlock(Block block, Compiler compiler, MbclLevel level,
    MbclLevelItem? parent, int depth, MbclLevelItem? exercise) {
  // TODO: check compatibilty, e.g. TABLE may not contain a TABLE etc...

  switch (block.id) {
    case 'ROOT':
      {
        block.setChildrenDefaultType("STRUCTURED_PARAGRAPH");
        for (var child in block.children) {
          var pseudoParent = MbclLevelItem(level, MbclLevelItemType.error, -1);
          parseLevelBlock(
              child, compiler, level, pseudoParent, depth + 1, exercise);
          level.items.addAll(pseudoParent.items);
        }
        break;
      }

    case 'PART':
      {
        level.numParts++;
        var iconId = "";
        try {
          checkAttributes((block.attributes), ["ICON"]);
          if (block.attributes.containsKey("ICON")) {
            iconId = block.attributes["ICON"]!;
          }
        } catch (e) {
          var error =
              MbclLevelItem(level, MbclLevelItemType.error, block.srcLine);
          parent?.items.add(error);
          error.error += e.toString();
        }
        level.partIconIDs.add(iconId);
        var levelItem =
            MbclLevelItem(level, MbclLevelItemType.part, block.srcLine);
        parent?.items.add(levelItem);
        break;
      }

    case 'AXIOM':
    case 'CLAIM':
    case 'CONJECTURE':
    case 'COROLLARY':
    case 'DEFINITION':
    case 'EXAMPLE':
    case 'IDENTITY':
    case 'LEMMA':
    case 'PARADOX':
    case 'PROPOSITION':
    case 'THEOREM':
    case 'PROOF':
    case 'TODO':
      {
        block.setChildrenDefaultType("PARAGRAPH");
        var type = MbclLevelItemType.error;
        switch (block.id) {
          case 'EXAMPLE':
            type = MbclLevelItemType.example;
            break;
          case 'DEFINITION':
            type = MbclLevelItemType.defDefinition;
            break;
          case 'THEOREM':
            type = MbclLevelItemType.defTheorem;
            break;
          case 'LEMMA':
            type = MbclLevelItemType.defLemma;
            break;
          case 'COROLLARY':
            type = MbclLevelItemType.defCorollary;
            break;
          case 'PROPOSITION':
            type = MbclLevelItemType.defProposition;
            break;
          case 'CONJECTURE':
            type = MbclLevelItemType.defConjecture;
            break;
          case 'AXIOM':
            type = MbclLevelItemType.defAxiom;
            break;
          case 'CLAIM':
            type = MbclLevelItemType.defClaim;
            break;
          case 'IDENTITY':
            type = MbclLevelItemType.defIdentity;
            break;
          case 'PARADOX':
            type = MbclLevelItemType.defParadox;
            break;
          case 'PROOF':
            type = MbclLevelItemType.defProof;
            break;
          case 'TODO':
            type = MbclLevelItemType.todo;
            break;
        }
        var levelItem = MbclLevelItem(level, type, block.srcLine);
        parent?.items.add(levelItem);
        levelItem.title = block.title;
        levelItem.label = block.label;
        for (var child in block.children) {
          // TODO: add CHATKEYS to grammar + public-course examples
          if (child.id == 'CHATKEYS') {
            levelItem.chatKeys = child.children[0].data.trim();
            continue;
          }
          parseLevelBlock(
              child, compiler, level, levelItem, depth + 1, exercise);
        }
        //print(levelItem!.toJSON());
        break;
      }

    case "CENTER":
    case "LEFT":
    case "RIGHT":
      {
        block.setChildrenDefaultType("PARAGRAPH");
        var type = MbclLevelItemType.error;
        switch (block.id) {
          case "CENTER":
            type = MbclLevelItemType.alignCenter;
            break;
          case "LEFT":
            type = MbclLevelItemType.alignLeft;
            break;
          case "RIGHT":
            type = MbclLevelItemType.alignRight;
            break;
        }
        var align = MbclLevelItem(level, type, block.srcLine);
        parent?.items.add(align);
        for (var child in block.children) {
          parseLevelBlock(child, compiler, level, align, depth + 1, exercise);
        }
        //print(levelItem!.toJSON());
        break;
      }

    case "ALIGNED-EQUATION":
    case "ALIGNED-EQUATION*":
    case "LEFT-EQUATION":
    case "LEFT-EQUATION*":
    case "EQUATION":
    case "EQUATION*":
      {
        var equation =
            MbclLevelItem(level, MbclLevelItemType.equation, block.srcLine);
        parent?.items.add(equation);
        var data = MbclEquationData(equation);
        equation.equationData = data;
        if (block.children.length != 1 || block.children[0].id != "DEFAULT") {
          equation.type = MbclLevelItemType.error;
          equation.text = "Expected equation code. "
              "No other kinds of input is allowed here.";
          break;
        }
        var texCode = block.children[0].data;
        equation.title = block.title;
        equation.label = block.label;

        if (block.id.startsWith("LEFT-EQUATION")) {
          data.leftAligned = true;
        }

        if (block.id.endsWith("*")) {
          data.number = -1;
        } else {
          data.number = compiler.equationNumberCounter++;
        }

        List<String> nonEmptyLines = [];
        for (var line in texCode.split("\n")) {
          if (line.trim().isEmpty) continue;
          nonEmptyLines.add(line);
        }
        equation.text += nonEmptyLines.join('\n');
        if (block.id.startsWith("ALIGNED-EQUATION")) {
          equation.text = '\\begin{matrix}[ll]${equation.text}\\end{matrix}';
        }
        // compile math
        var lexer = Lexer();
        lexer.enableEmitSingleQuotes(false);
        lexer.enableEmitBigint(false);
        lexer.enableEmitBigint(false);
        lexer.pushSource('', equation.text);
        data.math = parseInlineMath(level, lexer, exercise);
        data.math!.type = MbclLevelItemType.displayMath;
        equation.text = "";
        //print(equation.toJSON());
        break;
      }

    case 'TABLE':
      {
        // TODO: attributes (align, ...)
        var table =
            MbclLevelItem(level, MbclLevelItemType.table, block.srcLine);
        parent?.items.add(table);
        table.title = block.title;
        table.label = block.label;
        var data = MbclTableData(table);
        table.tableData = data;
        if (block.children.length != 1 || block.children[0].id != "DEFAULT") {
          table.error += "Expected table description. "
              "No other kinds of input is allowed here.";
          break;
        }
        var src = block.children[0].data;
        // parse table cells
        int i = 0;
        int numColumns = -1;
        for (var line in src.split("\n")) {
          line = line.trim();
          if (line.isEmpty) continue;
          // TODO: "&" may also be used in math-mode!!
          var columnStrings = line.split('&');
          if (numColumns < 0) {
            numColumns = columnStrings.length;
          } else if (numColumns != columnStrings.length) {
            table.error += 'Number of table columns is chaotic!';
          }
          var row = MbclTableRow(table);
          if (i == 0) {
            data.head = row;
          } else {
            data.rows.add(row);
          }
          for (var columnString in columnStrings) {
            var p = Paragraph(level, compiler);
            var columnText = p.parse(columnString, block.srcLine, exercise);
            if (columnText.length != 1 ||
                columnText[0].type != MbclLevelItemType.paragraph) {
              table.error += 'Table cell is not pure text.';
              row.columns.add(
                  MbclLevelItem(level, MbclLevelItemType.text, -1, 'error'));
            } else {
              row.columns.add(columnText[0]);
            }
          }
          i++;
        }
        //print(levelItem!.toJSON());
        break;
      }

    case 'FIGURE':
      {
        block.setChildrenDefaultType("CAPTION");
        var figure =
            MbclLevelItem(level, MbclLevelItemType.figure, block.srcLine);
        parent?.items.add(figure);
        var data = MbclFigureData(figure);
        figure.figureData = data;
        try {
          checkAttributes(block.attributes, ["PATH", "WIDTH"]);
          data.widthPercentage =
              getAttributeInt(block.attributes, "WIDTH", 100);
          if (data.widthPercentage < 5 || data.widthPercentage > 100) {
            figure.error +=
                "Figure width percentage must be in range [5,100]; ";
          }
          if (block.attributes.containsKey("PATH")) {
            data.filePath = block.attributes["PATH"]!;
            //var path = "${compiler.baseDirectory}"
            //    "${compiler.chapter.fileId}/${data.filePath}";
            //path = path.replaceAll("//", "/");
            var path = Path.join(
                compiler.baseDirectory, compiler.chapter.fileId, data.filePath);
            data.data = compiler.loadFile(path);
            if (data.data.isEmpty) {
              figure.error += 'Could not load image file from path "$path". ';
            }
            break;
          }
        } catch (e) {
          figure.error += e.toString();
        }
        for (var child in block.children) {
          if (child.id == "CAPTION") {
            var p = Paragraph(level, compiler);
            data.caption = p.parse(child.data, block.srcLine, exercise);
          } else if (child.id == "CODE") {
            if (child.children.length != 1 ||
                child.children[0].id != "DEFAULT") {
              figure.error += "Expected code.";
              break;
            }
            data.code = child.children[0].data;
            try {
              var parser = smpl_parser.Parser();
              parser.parse(data.code);
              var ic = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
              var interpreter = smpl_interpreter.Interpreter();
              var symbols = interpreter.runProgram(ic);
              if (symbols.containsKey('__figure') == false) {
                figure.error += 'Code does generate a figure.';
              } else {
                var figureSymbol =
                    symbols['__figure'] as smpl_interpreter.InterpreterSymbol;
                data.data = figureSymbol.value.text;
              }
            } catch (e) {
              figure.error += e.toString();
            }
          }
          // TODO: error if unknown
        }
        //print(figure.toJSON());
        break;
      }

    case 'EXERCISE':
      {
        // TODO: must guarantee that no two exercises labels are same in entire course!!
        block.setChildrenDefaultType("PARAGRAPH");
        var exercise =
            MbclLevelItem(level, MbclLevelItemType.exercise, block.srcLine);
        parent?.items.add(exercise);
        exercise.title = block.title;
        exercise.label = block.label;
        var data = MbclExerciseData(exercise);
        exercise.exerciseData = data;
        if (exercise.label.isEmpty) {
          exercise.label = 'ex${createUniqueId().toString()}';
        }
        try {
          checkAttributes(block.attributes, [
            "REQUIREMENT",
            "ORDER",
            "CHOICE_ALIGNMENT",
            "DISABLE_RETRY",
            "TIME",
            "SCORE",
            "INSTANCES"
          ]);
          data.disableRetry =
              getAttributeBool(block.attributes, "DISABLE_RETRY", false);
          data.time = getAttributeInt(block.attributes, "TIME", -1);
          data.score = getAttributeInt(block.attributes, "SCORE", 1);
          data.staticOrder = getAttributeString(block.attributes, "ORDER",
                  ["static", "shuffled"], "shuffled") ==
              "static";
          data.alignChoicesHorizontally = getAttributeString(block.attributes,
                  "CHOICE_ALIGNMENT", ["horizontal", "vertical"], "vertical") ==
              "horizontal";
          data.numInstances = getAttributeInt(block.attributes, "INSTANCES", 5);
        } catch (e) {
          exercise.error += e.toString();
        }
        if (block.attributes.containsKey("REQUIREMENT")) {
          var labels = block.attributes["REQUIREMENT"]!.split(",");
          for (var label in labels) {
            var referencedExercise = level.getExerciseByLabel(label);
            if (referencedExercise == null) {
              exercise.error +=
                  'Exercise referenced by "$label" does not exist. ';
            } else {
              data.requiredExercises.add(referencedExercise);
            }
          }
        }

        for (var child in block.children) {
          parseLevelBlock(
              child, compiler, level, exercise, depth + 1, exercise);
        }

        break;
      }

    case 'CODE':
      {
        if (exercise != null && block.children.isNotEmpty) {
          if (block.children.length != 1 || block.children[0].id != "DEFAULT") {
            exercise.error += "Expected code.";
            break;
          }
          exercise.exerciseData!.code = block.children[0].data;
          processExerciseCode(exercise);
        }
        break;
      }

    case 'TEXT':
      {
        block.setChildrenDefaultType("PARAGRAPH");
        for (var child in block.children) {
          parseLevelBlock(child, compiler, level, parent, depth + 1, exercise);
        }
        break;
      }

    case 'STRUCTURED_PARAGRAPH':
      {
        // also contains sections, subsections, page breaks, ...
        var lines = block.data.split("\n");
        var paragraphSrc = "";
        var paragraphLine = 0;
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i];
          var line2 = i + 1 < lines.length ? lines[i + 1] : "";
          if (line2.startsWith('####') ||
              line2.startsWith('====') ||
              line2.startsWith('----')) {
            // --- level title | section | subsection---
            if (paragraphSrc.trim().isNotEmpty) {
              var p = Paragraph(level, compiler);
              var levelItems = p.parse(paragraphSrc, paragraphLine, exercise);
              parent?.items.addAll(levelItems);
              paragraphSrc = '';
            }
            var tokens = line.split('@');
            var name = tokens[0].trim();
            var label = "";
            if (tokens.length > 1) {
              label = tokens[1].trim();
            }
            switch (line2[0]) {
              case '#':
                {
                  level.title = name;
                  level.label = label;
                  level.isEvent = name.toLowerCase() == 'event';
                  break;
                }
              case '=':
                {
                  var sec = MbclLevelItem(
                      level, MbclLevelItemType.section, block.srcLine + i);
                  parent?.items.add(sec);
                  sec.text = name;
                  sec.label = label;
                  break;
                }
              case '-':
                {
                  var subSec = MbclLevelItem(
                      level, MbclLevelItemType.subSection, block.srcLine + i);
                  parent?.items.add(subSec);
                  subSec.text = name;
                  subSec.label = label;
                  break;
                }
            }
            i++; // move forward
          } else {
            if (paragraphSrc.isEmpty) {
              paragraphLine = block.srcLine + i;
            }
            paragraphSrc += '$line\n';
          }
        }
        if (paragraphSrc.trim().isNotEmpty) {
          var p = Paragraph(level, compiler);
          var levelItems = p.parse(paragraphSrc, paragraphLine, exercise);
          parent?.items.addAll(levelItems);
          paragraphSrc = '';
        }
        break;
      }

    case 'PARAGRAPH':
      {
        var p = Paragraph(level, compiler);
        var levelItems = p.parse(block.data, block.srcLine, exercise);
        parent?.items.addAll(levelItems);
        break;
      }

    default:
      {
        var error =
            MbclLevelItem(level, MbclLevelItemType.error, block.srcLine);
        parent?.items.add(error);
        error.error += 'unknown keyword "${block.id}"';
      }
  }
}

void postProcessLevel(MbclLevel level) {
  for (var i = 0; i < level.items.length; i++) {
    var item = level.items[i];
    postProcessLevelItem(item);
  }
  removeEmptyParagraphs(level.items);
}

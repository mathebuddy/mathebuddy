/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// TODO: rename file

import 'package:slex/slex.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';

import '../../smpl/src/parser.dart' as smpl_parser;
import '../../smpl/src/node.dart' as smpl_node;
import '../../smpl/src/interpreter.dart' as smpl_interpreter;

import '../../math-runtime/src/operand.dart' as math_operand;

import 'compiler.dart';
import 'math.dart';
import 'paragraph_NEW.dart';

class Block_NEW {
  String id = "";
  String title = "";
  int indent = 0;
  String label = "";
  Map<String, String> attributes = {};
  String data = "";
  List<Block_NEW> children = [];
  int srcLine = -1;

  //MbclLevelItem? levelItem;

  Block_NEW(this.id, this.indent, this.srcLine);

  void _setChildrenDefaultType(String type) {
    for (var child in children) {
      if (child.id == "DEFAULT") {
        child.id = type;
      }
    }
  }

  void parse(Compiler compiler, MbclLevel level, MbclLevelItem? parent,
      int depth, MbclLevelItem? exercise) {
    // TODO: check compatibilty, e.g. TABLE may not contain a TABLE etc...

    switch (id) {
      case 'ROOT':
        {
          _setChildrenDefaultType("STRUCTURED_PARAGRAPH");
          for (var child in children) {
            var pseudoParent = MbclLevelItem(MbclLevelItemType.error, -1);
            child.parse(compiler, level, pseudoParent, depth + 1, exercise);
            level.items.addAll(pseudoParent.items);
          }
          break;
        }

      case 'PART':
        {
          level.numParts++;
          var iconId = "";
          for (var key in attributes.keys) {
            var value = attributes[key]!;
            switch (key) {
              case "ICON":
                {
                  iconId = value.trim();
                  break;
                }
              default:
                var error = MbclLevelItem(MbclLevelItemType.error, srcLine);
                parent?.items.add(error);
                error.error += 'unknown attribute "$key"';
                break;
            }
          }
          level.partIconIDs.add(iconId);
          var levelItem = MbclLevelItem(MbclLevelItemType.part, srcLine);
          parent?.items.add(levelItem);
          break;
        }

      case 'EXAMPLE':
      case 'DEFINITION':
      case 'THEOREM':
      case 'LEMMA':
      case 'COROLLARY':
      case 'PROPOSITION':
      case 'CONJECTURE':
      case 'AXIOM':
      case 'CLAIM':
      case 'IDENTITY':
      case 'PARADOX':
      case 'TODO':
        {
          _setChildrenDefaultType("PARAGRAPH");
          var type = MbclLevelItemType.error;
          switch (id) {
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
            case 'TODO':
              type = MbclLevelItemType.todo;
              break;
          }
          var levelItem = MbclLevelItem(type, srcLine);
          parent?.items.add(levelItem);
          levelItem.title = title;
          levelItem.label = label;
          for (var child in children) {
            child.parse(compiler, level, levelItem, depth + 1, exercise);
          }
          //print(levelItem!.toJSON());
          break;
        }

      case "LEFT":
      case "RIGHT":
      case "CENTER":
        {
          _setChildrenDefaultType("PARAGRAPH");
          var type = MbclLevelItemType.error;
          switch (id) {
            case "LEFT":
              type = MbclLevelItemType.alignLeft;
              break;
            case "RIGHT":
              type = MbclLevelItemType.alignRight;
              break;
            case "CENTER":
              type = MbclLevelItemType.alignCenter;
              break;
          }
          var align = MbclLevelItem(type, srcLine);
          parent?.items.add(align);
          for (var child in children) {
            child.parse(compiler, level, align, depth + 1, exercise);
          }
          //print(levelItem!.toJSON());
          break;
        }

      case "EQUATION":
      case "EQUATION*":
      case "ALIGNED-EQUATION":
      case "ALIGNED-EQUATION*":
        {
          var equation = MbclLevelItem(MbclLevelItemType.equation, srcLine);
          parent?.items.add(equation);
          if (children.length != 1 || children[0].id != "DEFAULT") {
            equation.error += "Expected equation code. "
                "No other kinds of input is allowed here.";
            break;
          }
          var texCode = children[0].data;
          equation.title = title;
          equation.label = label;
          var data = MbclEquationData();
          equation.equationData = data;

          if (id.endsWith("*")) {
            data.number = -1;
          } else {
            data.number = 888; // TODO}
          }

          List<String> nonEmptyLines = [];
          for (var line in texCode.split("\n")) {
            if (line.trim().isEmpty) continue;
            nonEmptyLines.add(line);
          }
          equation.text += nonEmptyLines.join('\n');
          if (id.startsWith("ALIGNED-EQUATION")) {
            equation.text = '\\begin{matrix}[ll]${equation.text}\\end{matrix}';
          }
          // compile math
          var lexer = Lexer();
          lexer.pushSource('', equation.text);
          data.math = parseInlineMath(lexer, exercise);
          data.math!.type = MbclLevelItemType.displayMath;
          equation.text = "";
          //print(equation.toJSON());
          break;
        }

      case 'TABLE':
        {
          // TODO: attributes (align, ...)
          var table = MbclLevelItem(MbclLevelItemType.table, srcLine);
          parent?.items.add(table);
          table.title = title;
          table.label = label;
          var data = MbclTableData();
          table.tableData = data;
          if (children.length != 1 || children[0].id != "DEFAULT") {
            table.error += "Expected table description. "
                "No other kinds of input is allowed here.";
            break;
          }
          var src = children[0].data;
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
            var row = MbclTableRow();
            if (i == 0) {
              data.head = row;
            } else {
              data.rows.add(row);
            }
            for (var columnString in columnStrings) {
              var p = Paragraph(compiler);
              var columnText =
                  p.parseParagraph(columnString, srcLine, exercise);
              if (columnText.length != 1 ||
                  columnText[0].type != MbclLevelItemType.paragraph) {
                table.error += 'Table cell is not pure text.';
                row.columns
                    .add(MbclLevelItem(MbclLevelItemType.text, -1, 'error'));
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
          _setChildrenDefaultType("CAPTION");
          var figure = MbclLevelItem(MbclLevelItemType.figure, srcLine);
          parent?.items.add(figure);
          var data = MbclFigureData();
          figure.figureData = data;
          for (var key in attributes.keys) {
            var value = attributes[key]!;
            switch (key) {
              case "PATH":
                data.filePath = compiler.baseDirectory + value.trim();
                data.data = compiler.loadFile(data.filePath);
                if (data.data.isEmpty) {
                  figure.error +=
                      'Could not load image file from path "${data.filePath}".';
                }
                break;
              case "WIDTH":
                data.options.add(MbclFigureOption.width75); // TODO!!
                break;
              default:
                figure.error += 'Unknown attribute "$key".';
                break;
            }
          }
          for (var child in children) {
            if (child.id == "CAPTION") {
              var p = Paragraph(compiler);
              data.caption = p.parseParagraph(child.data, srcLine, exercise);
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
          _setChildrenDefaultType("PARAGRAPH");
          var exercise = MbclLevelItem(MbclLevelItemType.exercise, srcLine);
          parent?.items.add(exercise);
          exercise.title = title;
          exercise.label = label;
          var data = MbclExerciseData(exercise);
          exercise.exerciseData = data;
          if (exercise.label.isEmpty) {
            exercise.label = 'ex${compiler.createUniqueId().toString()}';
          }
          for (var child in children) {
            child.parse(compiler, level, exercise, depth + 1, exercise);
          }
          for (var key in attributes.keys) {
            var value = attributes[key]!;
            switch (key) {
              case "ORDER":
                {
                  if (value == 'static') {
                    data.staticOrder = true;
                  } else {
                    exercise.error +=
                        'Attribute value "$value" is not allowed for key "$key".';
                  }
                  break;
                }
              case "CHOICE_ALIGNMENT":
                if (value == 'horizontal') {
                  data.horizontalSingleMultipleChoiceAlignment = true;
                } else {
                  exercise.error +=
                      'Attribute value "$value" is not allowed for key "$key".';
                }
                break;
              default:
                exercise.error += 'Unknown attribute "$key".';
                break;
            }
          }
          //print(exercise.toJSON());
          break;
        }

      case 'CODE':
        {
          if (exercise != null && children.isNotEmpty) {
            if (children.length != 1 || children[0].id != "DEFAULT") {
              exercise.error += "Expected code.";
              break;
            }
            exercise.exerciseData!.code = children[0].data;
            processExerciseCode(exercise);
          }
          break;
        }

      case 'TEXT':
        {
          _setChildrenDefaultType("PARAGRAPH");
          for (var child in children) {
            child.parse(compiler, level, parent, depth + 1, exercise);
          }
          break;
        }

      case 'STRUCTURED_PARAGRAPH':
        {
          // also contains sections, subsections, page breaks, ...
          var lines = data.split("\n");
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
                var p = Paragraph(compiler);
                var levelItems =
                    p.parseParagraph(paragraphSrc, paragraphLine, exercise);
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
                    break;
                  }
                case '=':
                  {
                    var sec =
                        MbclLevelItem(MbclLevelItemType.section, srcLine + i);
                    parent?.items.add(sec);
                    sec.text = name;
                    sec.label = label;
                    break;
                  }
                case '-':
                  {
                    var subSec = MbclLevelItem(
                        MbclLevelItemType.subSection, srcLine + i);
                    parent?.items.add(subSec);
                    subSec.text = name;
                    subSec.label = label;
                    break;
                  }
              }
              i++; // move forward
            } else {
              if (paragraphSrc.isEmpty) {
                paragraphLine = srcLine + i;
              }
              paragraphSrc += '$line\n';
            }
          }
          if (paragraphSrc.trim().isNotEmpty) {
            var p = Paragraph(compiler);
            var levelItems =
                p.parseParagraph(paragraphSrc, paragraphLine, exercise);
            parent?.items.addAll(levelItems);
            paragraphSrc = '';
          }
          break;
        }

      case 'PARAGRAPH':
        {
          var p = Paragraph(compiler);
          var levelItems = p.parseParagraph(data, srcLine, exercise);
          parent?.items.addAll(levelItems);
          break;
        }

      case 'NEWPAGE':
        {
          var newPage = MbclLevelItem(MbclLevelItemType.newPage, srcLine);
          parent?.items.add(newPage);
          break;
        }

      default:
        {
          var error = MbclLevelItem(MbclLevelItemType.error, srcLine);
          parent?.items.add(error);
          error.error += 'unknown keyword "$id"';
        }
    }
  }

  void postProcess() {
    // combine consecutive DEFAULT blocks
    for (int i = 0; i < children.length; i++) {
      if (children[i].id == "DEFAULT") {
        for (int k = i + 1; k < children.length; k++) {
          if (children[k].id == "DEFAULT") {
            children[i].data += children[k].data;
            children.removeAt(k);
            k--;
          } else {
            break;
          }
        }
      }
    }
    for (var child in children) {
      child.postProcess();
    }
    // reduce indentation (if applicable)
    if (data.isNotEmpty) {
      // (a) for all nonempty lines: get minimum of preceding spaces
      var lines = data.split("\n");
      var minSpaces = 10000;
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        var spaces = 0;
        for (var k = 0; k < line.length; k++) {
          if (line[k] == ' ') {
            spaces++;
          } else {
            break;
          }
        }
        if (spaces < minSpaces) {
          minSpaces = spaces;
        }
      }
      // (b) for all nonempty lines: remove spaces
      for (int i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.trim().isEmpty) continue;
        lines[i] = line.substring(minSpaces);
      }
      data = lines.join("\n");
    }
  }

  void processExerciseCode(MbclLevelItem exercise) {
    const numberOfInstances = 5; // TODO!! must be configurable
    var data = exercise.exerciseData!;
    for (var i = 0; i < numberOfInstances; i++) {
      // TODO: repeat if same instance is already drawn
      // TODO: must check for endless loops, e.g. happens if search space is restricted!
      try {
        var parser = smpl_parser.Parser();
        parser.parse(data.code);
        var ic = parser.getAbstractSyntaxTree() as smpl_node.AstNode;
        var interpreter = smpl_interpreter.Interpreter();
        var symbols = interpreter.runProgram(ic);
        if (i == 0) {
          // add variables names
          for (var symId in symbols.keys) {
            var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
            data.variables.add(symId);
          }
        }
        // set types
        for (var symId in symbols.keys) {
          var sym = symbols[symId] as smpl_interpreter.InterpreterSymbol;
          if (i == 0) {
            // first instance: just set type
            data.smplOperandType[symId] = sym.value.type.name;
          } else {
            var currentType = math_operand.OperandType.values
                .byName(data.smplOperandType[symId]!);
            var type = sym.value.type;
            // further instances: check if type is "more mighty" than the
            // type currently set
            if (currentType != type &&
                math_operand.getOperandTypeMightiness(type) >
                    math_operand.getOperandTypeMightiness(currentType)) {
              data.smplOperandType[symId] = type.name;
            }
          }
        }
        // fill instances
        Map<String, String> instance = {};
        for (var v in data.variables) {
          var sym = symbols[v] as smpl_interpreter.InterpreterSymbol;
          // pure math
          instance[v] = sym.value.toString();
          instance['@$v'] = sym.term.toString();
          instance['@@$v'] = sym.term.clone().optimize().toString();
          // TeX
          instance['$v.tex'] = sym.value.toTeXString();
          instance['@$v.tex'] = sym.term.toTeXString();
          instance['@@$v.tex'] = sym.term.clone().optimize().toTeXString();
        }
        data.instances.add(instance);
      } catch (e) {
        exercise.error += 'SMPL-Error: $e\n';
        break;
      }
    }
  }

  @override
  String toString() {
    var s = '';
    s += '${_indent(indent)}--------\n';
    s += '${_indent(indent)}ID="$id"\n';
    s += '${_indent(indent)}SRC_LINE="$srcLine"\n';
    s += '${_indent(indent)}TITLE="$title"\n';
    s += '${_indent(indent)}LABEL="$label"\n';
    s += '${_indent(indent)}ATTRIBUTES=[';
    for (var key in attributes.keys) {
      var value = attributes[key];
      s += '$key=$value';
      s += ',';
    }
    s += ']\n';
    var d = data.replaceAll("\n", "\\n").replaceAll("\t", "\\t");
    s += '${_indent(indent)}DATA="$d"\n';
    if (children.isNotEmpty) {
      s += '${_indent(indent)}CHILDREN:\n';
    }
    for (var child in children) {
      s += child.toString();
    }
    return s;
  }

  String _indent(int n) {
    var s = '';
    for (int i = 0; i < n * 4; i++) {
      s += ' ';
    }
    return s;
  }
}

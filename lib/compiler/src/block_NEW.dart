// TODO: rename file, add meta data to file header, ...

import 'package:slex/slex.dart';

import '../../mbcl/src/level.dart';
import '../../mbcl/src/level_item.dart';
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

  MbclLevelItem? levelItem;

  Block_NEW(this.id, this.indent, this.srcLine);

  void _error(String message) {
    // TODO: include file path!
    throw Exception('ERROR:$srcLine: $message');
  }

  void _setChildrenDefaultType(String type) {
    for (var child in children) {
      if (child.id == "DEFAULT") {
        child.id = type;
      }
    }
  }

  void parse(
      Compiler compiler, MbclLevel level, MbclLevelItem? parent, int depth) {
    // TODO: check compatibilty, e.g. TABLE may not contain a TABLE etc...

    switch (id) {
      case 'ROOT':
        {
          _setChildrenDefaultType("STRUCTURED_PARAGRAPH");
          for (var child in children) {
            child.parse(compiler, level, null, depth + 1);
          }
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
          }
          levelItem = MbclLevelItem(type, srcLine);
          levelItem!.title = title;
          levelItem!.label = label;
          for (var child in children) {
            child.parse(compiler, level, levelItem, depth + 1);
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
          levelItem = MbclLevelItem(type, srcLine);
          for (var child in children) {
            child.parse(compiler, level, levelItem, depth + 1);
          }
          //print(levelItem!.toJSON());
          break;
        }

      case "EQUATION":
      case "EQUATION*":
      case "ALIGNED-EQUATION":
      case "ALIGNED-EQUATION*":
        {
          if (children.length != 1 || children[0].id != "DEFAULT") {
            _error("Expected equation code. "
                "No other kinds of input is allowed here.");
          }
          levelItem = MbclLevelItem(MbclLevelItemType.equation, srcLine);
          var texCode = children[0].data;
          levelItem!.title = title;
          levelItem!.label = label;
          var data = MbclEquationData();
          levelItem!.equationData = data;

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
          levelItem!.text += nonEmptyLines.join('\n');
          if (id == "ALIGNED-EQUATION") {
            levelItem!.text =
                '\\begin{matrix}[ll]${levelItem!.text}\\end{matrix}';
          }
          // compile math
          var lexer = Lexer();
          lexer.pushSource('', levelItem!.text);
          data.math = parseInlineMath(lexer, null); // TODO: exercise
          data.math!.type = MbclLevelItemType.displayMath;
          levelItem!.text = "";
          //print(levelItem!.toJSON());
          break;
        }

      case 'TABLE':
        {
          // TODO: arguments (align, ...)
          if (children.length != 1 || children[0].id != "DEFAULT") {
            _error("Expected table description. "
                "No other kinds of input is allowed here.");
          }
          levelItem = MbclLevelItem(MbclLevelItemType.table, srcLine);
          var data = MbclTableData();
          levelItem!.tableData = data;
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
              levelItem!.error += 'Number of table columns is chaotic!';
            }
            var row = MbclTableRow();
            if (i == 0) {
              data.head = row;
            } else {
              data.rows.add(row);
            }
            for (var columnString in columnStrings) {
              var p = Paragraph(compiler);
              var columnText = p.parseParagraph(columnString, srcLine, null);
              if (columnText.length != 1 ||
                  columnText[0].type != MbclLevelItemType.paragraph) {
                levelItem!.error += 'Table cell is not pure text.';
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

      case 'EXERCISE':
        {
          // TODO: must guarantee that no two exercises labels are same in entire course!!
          _setChildrenDefaultType("PARAGRAPH");
          var exercise = MbclLevelItem(MbclLevelItemType.table, srcLine);
          levelItem = exercise;
          exercise.title = title;
          exercise.label = label;
          var data = MbclExerciseData(exercise);
          exercise.exerciseData = data;
          if (exercise.label.isEmpty) {
            exercise.label = 'ex${compiler.createUniqueId().toString()}';
          }

          print(exercise.toJSON());
          break;
        }

      case 'STRUCTURED_PARAGRAPH':
        {
          // also contains sections, subsections, page breaks, ...
          // TODO
          var bp = 1337;
          break;
        }

      case 'PARAGRAPH':
        {
          var p = Paragraph(compiler);
          var levelItems = p.parseParagraph(data, srcLine, null);
          parent?.items.addAll(levelItems);
          break;
        }

      case 'NEWPAGE':
        {
          // TODO
          break;
        }

      default:
        {
          _error('unknown keyword "$id"');
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

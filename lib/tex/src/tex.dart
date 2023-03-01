/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:math';

import '../../../ext/multila-lexer/src/lex.dart' as multilaLexer;

import 'font.dart';
import 'node.dart';

class TeX {
  multilaLexer.Lexer _lexer = new multilaLexer.Lexer();
  Set<String> _usedLetters = {};

  String _lastParsed = '';
  String _error = '';

  String get lastParsed {
    return _lastParsed;
  }

  String get error {
    return _error;
  }

  String tex2svg(String src, [paintBox = false]) {
    _usedLetters = {};
    _lexer = new multilaLexer.Lexer();
    _lexer.enableUnderscoreInID(false);
    _lexer.pushSource('', src);
    /*while (_lexer.isEND() == false) {
      var tk = _lexer.getToken();
      print(tk.token);
      _lexer.next();
    }*/
    try {
      var list = _parseTexList(false);
      _lastParsed = list.toString();
      print(_lastParsed); // TODO: remove this

      var cmds = '';

      _layout(list, 0, 0);
      cmds += _generate(list, 4);

      int BELOW_HEIGHT = 250; // TODO
      int minX = 0;
      int minY = -list.height;
      int width = list.width;
      int height = list.height + BELOW_HEIGHT;
      var defs = '';
      for (var id in _usedLetters) {
        var d = fontDB[id];
        defs += '    <path id="${id}" d="${d}"></path>\n';
      }

      String boundingBoxes = '';
      if (paintBox) {
        boundingBoxes =
            '    <rect x="0" y="${-BELOW_HEIGHT}" width="${width}" height="${height}" fill="none" stroke="rgb(200,200,200)" stroke-width="30"></rect>\n' +
                '    <rect x="0" y="0" width="${width}" height="${height - BELOW_HEIGHT}" fill="none" stroke="rgb(200,200,200)" stroke-width="10"></rect>\n';
      }

      cmds =
          '  <g stroke="currentColor" fill="currentColor" stroke-width="0" transform="scale(1,-1)">\n${boundingBoxes}${cmds}  </g>';
      var svg =
          '<svg style="" xmlns="http://www.w3.org/2000/svg" role="img" focusable="false" viewBox="${minX} ${minY} ${width} ${height}" xmlns:xlink="http://www.w3.org/1999/xlink">\n  <defs>\n${defs}  </defs>\n${cmds}\n</svg>\n';
      return svg;
    } catch (e) {
      _error = e.toString();
      return "";
    }
  }

  String _indent(String text, int numSpaces) {
    var lines = text.split("\n");
    var s = '';
    for (var line in lines) {
      for (var i = 0; i < numSpaces; i++) {
        s += ' ';
      }
      s += line + '\n';
    }
    return s;
  }

  String _generate(TeXNode node, indent) {
    if (node.isList) {
      var svg = _indent('<g transform="scale(${node.scaling})">', indent);
      for (var i = 0; i < node.items.length; i++) {
        var item = node.items[i];
        svg += _generate(item, indent + 2);
      }
      svg += _indent('</g>', indent);
      return svg;
    } else {
      var x = node.x;
      var y = node.y;
      var scaling = node.scaling;
      var svg = _indent(
          '<g transform="translate(${x},${y}) scale(${scaling})">', indent);
      svg += _indent('<use xlink:href="#${node.svgPathId}"></use>', indent + 2);
      if (node.sub != null) {
        var sub = node.sub as TeXNode;
        svg += _generate(sub, indent + 2);
      }
      if (node.sup != null) {
        var sup = node.sup as TeXNode;
        svg += _generate(sup, indent + 2);
      }
      svg += _indent('</g>', indent);
      return svg;
    }
  }

  void _layout(TeXNode node, int baseX, int baseY, [scaling = 1.0]) {
    if (node.isList) {
      int x = baseX;
      int y = baseY;
      node.x = x;
      node.y = y;
      node.scaling = scaling;
      for (var i = 0; i < node.items.length; i++) {
        var item = node.items[i];
        _layout(item, x, y, scaling);
        x += item.width;
        node.height = max<int>(node.height, item.height);
      }
      node.width = x - baseX;
    } else {
      int x = baseX;
      int y = baseY;
      var ch = node.tk;
      node.x = x;
      node.y = y;
      int code = 0;
      if (_isNum(ch)) {
        node.svgPathId = _createSvgPathId("MJX-1-TEX-N-", ch.codeUnitAt(0));
        x += 500;
        node.height = 750;
      } else if (_isUpperCaseAlpha(ch)) {
        node.svgPathId = _createSvgPathId(
            "MJX-1-TEX-I-", (0x1D434 + ch.codeUnitAt(0) - "A".codeUnitAt(0)));
        x += 800;
        node.height = 750;
      } else if (_isLowerCaseAlpha(ch)) {
        node.svgPathId = _createSvgPathId(
            "MJX-1-TEX-I-", (0x1D44E + ch.codeUnitAt(0) - "a".codeUnitAt(0)));
        x += 500;
        node.height = 750;
      } else if ("+-*/=()[],".contains(ch)) {
        node.svgPathId = _createSvgPathId("MJX-1-TEX-N-", ch.codeUnitAt(0));
        switch (ch) {
          case ",":
            node.x += 150;
            x += 600;
            break;
          case "+":
            node.x += 200;
            x += 1200;
            break;
          case "=":
            node.x += 200;
            x += 1200;
            break;
          case "(":
          case ")":
            x += 400;
            break;
          default:
            x += 1200;
            break;
        }
        node.height = 750;
      } else if ((code = _getGreekCode(ch)) != 0) {
        node.svgPathId = _createSvgPathId("MJX-1-TEX-I-", code);
        x += 650;
        node.height = 750;
      } else {
        throw new Exception("unimplemented token '" + ch + "'");
      }
      if (node.sub != null) {
        var sub = node.sub as TeXNode;
        _layout(sub, 875, -250, 0.7071);
        x += (sub.width * 0.7071).round();
        // TODO: 0.7071 may be "recursive"
        // TODO: sign of 600????
        //node.height =
        //    max<int>(node.height, (600 + sub.height * 0.7071).round());
      }
      if (node.sup != null) {
        var sup = node.sup as TeXNode;
        _layout(sup, 750, 600, 0.7071);
        x += (sup.width * 0.7071).round();
        // TODO: 0.7071 may be "recursive"
        node.height =
            max<int>(node.height, (600 + sup.height * 0.7071).round());
      }
      node.width = x - baseX;
    }
  }

  String _createSvgPathId(String prefix, int num) {
    var id = prefix + num.toRadixString(16).toUpperCase();
    _usedLetters.add(id);
    return id;
  }

  bool _isNum(String ch) {
    return ch.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isUpperCaseAlpha(String ch) {
    return ch.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'Z'.codeUnitAt(0);
  }

  bool _isLowerCaseAlpha(String ch) {
    return ch.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'z'.codeUnitAt(0);
  }

  int _getGreekCode(String ch) {
    if (ch.startsWith("\\") == false) return 0;
    switch (ch) {
      // TODO!!
      case "\\alpha":
        return 0x1D6FC;
      case "\\beta":
        return 0x1D6FD;
      case "\\gamma":
        return 0x1D6FE;
      default:
        return 0;
    }
  }

  //G texList = { texNode };
  TeXNode _parseTexList(bool parseBraces) {
    if (parseBraces) {
      if (_lexer.isTER('{')) {
        _lexer.next();
      } else {
        throw new Exception('ERROR: expected {');
      }
    }
    var list = new TeXNode(true, []);
    while (_lexer.isNotTER('}')) {
      list.items.add(_parseTexNode());
    }
    if (parseBraces) {
      if (_lexer.isTER('}')) {
        _lexer.next();
      } else {
        throw new Exception('ERROR: expected }');
      }
    }
    return list;
  }

  //G texNode = "\" ID { "{" texList "}" } | ID | INT | ...;
  TeXNode _parseTexNode() {
    if (_lexer.isTER('{')) {
      return _parseTexList(true);
    } else {
      var node = new TeXNode(false, []);
      if (_lexer.isTER('\\')) {
        node.tk += '\\';
        _lexer.next();
      }
      node.tk += _lexer.getToken().token;
      if (node.tk.startsWith("\\") == false && node.tk.length != 1) {
        throw Exception("unimplemented!");
      }
      _lexer.next();
      while (this._lexer.isTER('^') || this._lexer.isTER('_')) {
        var del = this._lexer.getToken().token;
        this._lexer.next();
        if (del == '^' && node.sup != null) {
          throw new Exception('ERROR: use { } when chaining ^');
        } else if (del == '_' && node.sub != null) {
          throw new Exception('ERROR: use { } when chaining _');
        }
        if (del == '_') {
          node.sub = this._lexer.isTER('{')
              ? this._parseTexList(true)
              : new TeXNode(true, [this._parseTexNode()]);
        }
        if (del == '^') {
          node.sup = this._lexer.isTER('{')
              ? this._parseTexList(true)
              : new TeXNode(true, [this._parseTexNode()]);
        }
      }
      return node;
    }
  }
}

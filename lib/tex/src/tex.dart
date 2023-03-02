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
import 'tables.dart';

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
      var root = _parseTexList(false);
      _lastParsed = root.toString();
      print(_lastParsed); // TODO: remove this

      var cmds = '';

      _layout(root, 0, 0);
      cmds += _generate(root, 4);

      int BELOW_HEIGHT = 250; // TODO
      int minX = 0;
      int minY = -root.height;
      int width = root.width;
      int height = root.height + BELOW_HEIGHT;
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
      var tk = node.tk;
      node.x = x;
      node.y = y;
      int code = 0;
      if (_isNum(tk)) {
        node.svgPathId = _createSvgPathId("MJX-1-TEX-N-", tk.codeUnitAt(0));
        x += 500;
        node.height = 750;
      } else if (_isUpperCaseAlpha(tk)) {
        node.svgPathId = _createSvgPathId(
            "MJX-1-TEX-I-", (0x1D434 + tk.codeUnitAt(0) - "A".codeUnitAt(0)));
        x += 800;
        node.height = 750;
      } else if (_isLowerCaseAlpha(tk)) {
        node.svgPathId = _createSvgPathId(
            "MJX-1-TEX-I-", (0x1D44E + tk.codeUnitAt(0) - "a".codeUnitAt(0)));
        x += 500;
        node.height = 750;
      } else if ("+-*/=()[],-<>:;|!".contains(tk)) {
        // TODO: add these to tables.dart
        node.svgPathId = _createSvgPathId("MJX-1-TEX-N-", tk.codeUnitAt(0));
        switch (tk) {
          case ",":
            node.x += 150;
            x += 600;
            break;
          case "+":
            node.x += 200;
            x += 1200;
            break;
          case "-":
            x += 600;
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
      } else if ((code = _getGreekCode(tk)) != 0) {
        node.svgPathId = _createSvgPathId("MJX-1-TEX-I-", code);
        x += 650;
        node.height = 750;
      } else if (table.containsKey(tk)) {
        var entry = table[tk] as Map<Object, Object>;
        node.svgPathId = _createSvgPathId(entry["code"] as String, -1);
        x += entry["w"] as int;
        if (entry.containsKey("d")) {
          node.x += entry["d"] as int;
        }
      } else if (tk == "\\mathbb") {
        // TODO: flatter-function that replaces lists with one node by that node
        var bp = 1337;
      } else {
        throw new Exception("unimplemented token '" + tk + "'");
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
    var id = prefix;
    if (num >= 0) id += num.toRadixString(16).toUpperCase();
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
      case "\\alpha":
        return 0x1D6FC;
      case "\\beta":
        return 0x1D6FD;
      case "\\gamma":
        return 0x1D6FE;
      case "\\delta":
        return 0x1D6FF;
      case "\\Delta":
        return 0x394;
      case "\\epsilon":
        return 0x1D700;
      case "\\varepsilon":
        return 0; // TODO
      case "\\zeta":
        return 0x1D701;
      case "\\eta":
        return 0x1D702;
      case "\\theta":
        return 0x1D703;
      case "\\vartheta":
        return 0; // TODO
      case "\\Theta":
        return 0x398;
      case "\\iota":
        return 0x1D704;
      case "\\kappa":
        return 0x1D705;
      case "\\lambda":
        return 0x1D706;
      case "\\Lambda":
        return 0; // TODO
      case "\\mu":
        return 0x1D707;
      case "\\nu":
        return 0x1D708;
      case "\\xi":
        return 0x1D709;
      case "\\Xi":
        return 0; // TODO
      case "\\pi":
        return 0x1D70B;
      case "\\Pi":
        return 0; // TODO
      case "\\rho":
        return 0x1D70C;
      case "\\varrho":
        return 0; // TODO
      case "\\varsigma":
        return 0x1D70D;
      case "\\sigma":
        return 0x1D70E;
      case "\\Sigma":
        return 0; // TODO
      case "\\tau":
        return 0x1D70F;
      case "\\upsilon":
        return 0x1D710;
      case "\\Upsilon":
        return 0; // TODO
      case "\\phi":
        return 0x1D711;
      case "\\varphi":
        return 0; // TODO
      case "\\Phi":
        return 0; // TODO
      case "\\chi":
        return 0x1D712;
      case "\\psi":
        return 0x1D713;
      case "\\Psi":
        return 0; // TODO
      case "\\omega":
        return 0x1D714;
      case "\\Omega":
        return 0; // TODO
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
    // post-process: populate node.args
    for (var i = 0; i < list.items.length; i++) {
      if (list.items[i].isList == false &&
          numArgs.containsKey(list.items[i].tk)) {
        var item = list.items[i];
        var n = numArgs[item.tk] as int;
        for (var j = 0; j < n; j++) {
          if (i + 1 >= list.items.length) {
            throw new Exception('ERROR: ' +
                item.tk +
                ' excepts ' +
                n.toString() +
                ' arguments!');
          }
          var item2 = list.items.removeAt(i + 1);
          item.args.add(item2);
        }
        i += n - 1;
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

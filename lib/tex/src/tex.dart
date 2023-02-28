/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../../ext/multila-lexer/src/lex.dart';

import 'font.dart';

class TexNode {
  bool isList;
  List<TexNode> items = [];
  String tk = '';
  TexNode? sub = null;
  TexNode? sup = null;

  int width = 0;

  TexNode(this.isList);

  @override
  String toString() {
    if (isList) {
      var s = '{';
      for (var i = 0; i < items.length; i++) {
        if (i > 0) s += ' ';
        var item = items[i];
        s += item.toString();
      }
      s += '}';
      return s;
    } else {
      var s = tk;
      if (this.sub != null) {
        s += '_' + this.sub.toString();
      }
      if (this.sup != null) {
        s += '^' + this.sup.toString();
      }
      return s;
    }
  }
}

class Tex {
  Lexer _lexer = new Lexer();
  Set<String> _usedLetters = {};

  String tex2svg(String src) {
    _usedLetters = {};
    _lexer = new Lexer();
    _lexer.enableUnderscoreInID(false);
    _lexer.pushSource('', src);
    /*while (_lexer.isEND() == false) {
      var tk = _lexer.getToken();
      print(tk.token);
      _lexer.next();
    }*/
    var list = _parseTexList(false);
    print(list.toString());

    var cmds = _generate(list, 0, 0);

    int minX = 0;
    int minY = -500;
    int width = list.width;
    int height = 1000;
    var defs = '';
    for (var id in _usedLetters) {
      var d = fontDB[id];
      defs += '    <path id="${id}" d="${d}"></path>\n';
    }
    cmds =
        '  <g stroke="currentColor" fill="currentColor" stroke-width="0" transform="scale(1,-1)">\n${cmds}</g>';
    var svg =
        '<svg style="vertical-align: -0.025ex;" xmlns="http://www.w3.org/2000/svg" width="1.294ex" height="1.025ex" role="img" focusable="false" viewBox="${minX} ${minY} ${width} ${height}" xmlns:xlink="http://www.w3.org/1999/xlink">\n  <defs>\n${defs}  </defs>\n${cmds}\n</svg>\n';
    return svg;
  }

  String _generate(TexNode node, int baseX, int baseY, [scale = 1.0]) {
    // TODO: only generate positions + xlink!
    // TODO: generate svg in subsequent step
    if (node.isList) {
      var svg = '';
      int x = baseX;
      int y = baseY;
      for (var i = 0; i < node.items.length; i++) {
        var item = node.items[i];
        svg += _generate(item, x, y);
        x += item.width;
      }
      node.width = x - baseX;
      return svg;
    } else {
      var svg = '';
      int x = baseX;
      int y = baseY;
      svg += '    <g transform="translate(${x},${y}) scale(${scale})">\n';
      var ch = node.tk[0];
      if (_isNum(ch)) {
        svg += _put("MJX-1-TEX-N-", ch.codeUnitAt(0));
        x += 500;
      } else if (_isLowerCaseAlpha(ch)) {
        svg += _put(
            "MJX-1-TEX-I-", (0x1D44E + ch.codeUnitAt(0) - "a".codeUnitAt(0)));
        x += 500;
      } else if (ch == '+') {
        svg += _put("MJX-1-TEX-N-", ch.codeUnitAt(0));
        x += 1000;
      }
      if (node.sup != null) {
        svg += _generate(node.sup as TexNode, 300, 300, 0.7071);
      }
      svg += '    </g>\n';
      node.width = x - baseX;
      return svg;
    }
  }

  String _put(String prefix, int num) {
    var id = prefix + num.toRadixString(16).toUpperCase();
    _usedLetters.add(id);
    return '      <use xlink:href="#${id}"></use>\n';
  }

  bool _isNum(String ch) {
    return ch.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isLowerCaseAlpha(String ch) {
    return ch.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'z'.codeUnitAt(0);
  }

  //G texList = { texNode };
  TexNode _parseTexList(bool parseBraces) {
    if (parseBraces) {
      if (_lexer.isTER('{')) {
        _lexer.next();
      } else {
        throw new Exception('ERROR: expected {');
      }
    }
    var list = new TexNode(true);
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
  TexNode _parseTexNode() {
    if (_lexer.isTER('{')) {
      return _parseTexList(true);
    } else {
      var node = new TexNode(false);
      if (_lexer.isTER('\\')) {
        node.tk += '\\';
        _lexer.next();
      }
      node.tk += _lexer.getToken().token;
      if (node.tk.startsWith("/") == false && node.tk.length != 1) {
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
              : this._parseTexNode();
        }
        if (del == '^') {
          node.sup = this._lexer.isTER('{')
              ? this._parseTexList(true)
              : this._parseTexNode();
        }
      }
      return node;
    }
  }
}

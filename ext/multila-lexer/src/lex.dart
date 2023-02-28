/*
  MULTILA Compiler and Computer Architecture Infrastructure
  Copyright (c) 2022 by Andreas Schwenk, contact@multila.org
  Licensed by GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
*/

import 'lang.dart';
import 'state.dart';
import 'token.dart';

class LexerFile {
  LexerState? stateBackup = null;
  LexerToken? tokenBackup = null;
  String id = '';
  String sourceCode = '';
}

class LexerBackup {
  LexerState state;
  LexerToken token;

  LexerBackup(this.state, this.token);
}

class Lexer {
  Set<String> _terminals = {};

  List<LexerFile> _fileStack = [];
  LexerToken _token = new LexerToken();
  LexerToken? _lastToken = null;
  LexerState _state = new LexerState();

  String _singleLineCommentStart = '//';
  String _multiLineCommentStart = '/*';
  String _multilineCommentEnd = '*/';
  bool _emitNewline = false;
  bool _emitHex = true;
  bool _emitInt = true;
  bool _emitReal = true;
  bool _emitBigint = true;
  bool _emitSingleQuotes = true;
  bool _emitDoubleQuotes = true;
  bool _emitIndentation = false;
  String _lexerFilePositionPrefix = '!>';
  bool _allowBackslashLineBreaks = false;

  bool _allowUmlautInID = false;
  bool _allowHyphenInID = false;
  bool _allowUnderscoreInID = true;

  List<LexerToken> _putTrailingSemicolon = [];
  List<String> _multicharDelimiters = [];

  void configureSingleLineComments([pattern = '//']) {
    this._singleLineCommentStart = pattern;
  }

  void configureMultiLineComments([startPattern = '/*', endPattern = '*/']) {
    this._multiLineCommentStart = startPattern;
    this._multilineCommentEnd = endPattern;
  }

  void configureLexerFilePositionPrefix([pattern = '!>']) {
    this._lexerFilePositionPrefix = pattern;
  }

  enableEmitNewlines(bool value) {
    this._emitNewline = value;
  }

  enableEmitHex(bool value) {
    this._emitHex = value;
  }

  enableEmitInt(bool value) {
    this._emitInt = value;
  }

  enableEmitReal(bool value) {
    this._emitReal = value;
  }

  enableEmitBigint(bool value) {
    this._emitBigint = value;
  }

  enableEmitSingleQuotes(bool value) {
    this._emitSingleQuotes = value;
  }

  enableEmitDoubleQuotes(bool value) {
    this._emitDoubleQuotes = value;
  }

  enableEmitIndentation(bool value) {
    this._emitIndentation = value;
  }

  enableBackslashLineBreaks(bool value) {
    this._allowBackslashLineBreaks = value;
  }

  enableUmlautInID(bool value) {
    this._allowUmlautInID = value;
  }

  enableHyphenInID(bool value) {
    this._allowHyphenInID = value;
  }

  enableUnderscoreInID(bool value) {
    this._allowUnderscoreInID = value;
  }

  bool isEND() {
    return this._token.type == LexerTokenType.END;
  }

  bool isNotEND() {
    return this._token.type != LexerTokenType.END;
  }

  END() {
    if (this._token.type == LexerTokenType.END) {
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' END',
      );
  }

  bool isID() {
    return this._token.type == LexerTokenType.ID;
  }

  String ID() {
    var res = '';
    if (this._token.type == LexerTokenType.ID) {
      res = this._token.token;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' ID',
      );
    return res;
  }

  /**
   * lower case
   * @returns
   */
  bool isLID() {
    return (this._token.type == LexerTokenType.ID &&
        this._token.token == this._token.token.toLowerCase());
  }

  /**
   * lower case
   * @returns
   */
  String LID() {
    var res = '';
    if (this._token.type == LexerTokenType.ID &&
        this._token.token == this._token.token.toLowerCase()) {
      res = this._token.token;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' LowerCaseID',
      );
    return res;
  }

  /**
   * upper case
   * @returns
   */
  bool isUID() {
    return (this._token.type == LexerTokenType.ID &&
        this._token.token == this._token.token.toUpperCase());
  }

  /**
   * upper case
   * @returns
   */
  String UID() {
    var res = '';
    if (this._token.type == LexerTokenType.ID &&
        this._token.token == this._token.token.toUpperCase()) {
      res = this._token.token;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' UpperCaseID',
      );
    return res;
  }

  bool isINT() {
    return this._token.type == LexerTokenType.INT;
  }

  int INT() {
    int res = 0;
    if (this._token.type == LexerTokenType.INT) {
      res = this._token.value as int;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' INT',
      );
    return res;
  }

  bool isBIGINT() {
    return this._token.type == LexerTokenType.BIGINT;
  }

  BigInt BIGINT() {
    var res = BigInt.from(0);
    if (this._token.type == LexerTokenType.BIGINT) {
      res = this._token.valueBigint;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' BIGINT',
      );
    return res;
  }

  bool isREAL() {
    return this._token.type == LexerTokenType.REAL;
  }

  num REAL() {
    num res = 0.0;
    if (this._token.type == LexerTokenType.REAL) {
      res = this._token.value;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' REAL',
      );
    return res;
  }

  bool isHEX() {
    return this._token.type == LexerTokenType.HEX;
  }

  String HEX() {
    var res = '';
    if (this._token.type == LexerTokenType.HEX) {
      res = this._token.token;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' HEX',
      );
    return res;
  }

  bool isSTR() {
    return this._token.type == LexerTokenType.STR;
  }

  String STR() {
    var res = '';
    if (this._token.type == LexerTokenType.STR) {
      res = this._token.token;
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' STR',
      );
    return res;
  }

  bool isTER(String t) {
    return ((this._token.type == LexerTokenType.DEL &&
            this._token.token == t) ||
        (this._token.type == LexerTokenType.ID && this._token.token == t));
  }

  bool isNotTER(String t) {
    return this.isTER(t) == false && this._token.type != LexerTokenType.END;
  }

  TER(String t) {
    if ((this._token.type == LexerTokenType.DEL && this._token.token == t) ||
        (this._token.type == LexerTokenType.ID && this._token.token == t)) {
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' "' + t + '"',
      );
  }

  // end of statement
  bool isEOS() {
    // TODO: ';' OR newline
    // TODO: configure ';'
    return this._token.token == ';';
  }

  // end of statement
  EOS() {
    // TODO: ';' OR newline
    if (this._token.token == ';')
      this.next();
    else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' ";"',
      );
  }

  bool isINDENT() {
    return this._token.type == LexerTokenType.DEL && this._token.token == '\t+';
  }

  bool isNotINDENT() {
    return !(this._token.type == LexerTokenType.DEL &&
        this._token.token == '\t+');
  }

  INDENT() {
    if (this._token.type == LexerTokenType.DEL && this._token.token == '\t+') {
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' INDENT',
      );
  }

  bool isOUTDENT() {
    return this._token.type == LexerTokenType.DEL && this._token.token == '\t-';
  }

  bool isNotOUTDENT() {
    if (this._token.type == LexerTokenType.END)
      return false; // TODO: must do this for ALL "not" methods
    return !(this._token.type == LexerTokenType.DEL &&
        this._token.token == '\t-');
  }

  OUTDENT() {
    if (this._token.type == LexerTokenType.DEL && this._token.token == '\t-') {
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' OUTDENT',
      );
  }

  bool isNEWLINE() {
    return (this.isOUTDENT() ||
        (this._token.type == LexerTokenType.DEL && this._token.token == '\n'));
  }

  bool isNotNEWLINE() {
    return (!this.isOUTDENT() &&
        !(this._token.type == LexerTokenType.DEL && this._token.token == '\n'));
  }

  NEWLINE() {
    if (this.isOUTDENT()) return;
    if (this._token.type == LexerTokenType.DEL && this._token.token == '\n') {
      this.next();
    } else
      throw new Exception(
        this._err_pos() + getStr(LanguageText.EXPECTED) + ' NEWLINE',
      );
  }

  error(String s, [LexerToken? tk = null]) {
    throw new Exception(this._err_pos(tk) + s);
  }

  errorExpected(List<String> terminals) {
    var s = getStr(LanguageText.EXPECTED_ONE_OF) + ' ';
    for (var i = 0; i < terminals.length; i++) {
      if (i > 0) s += ', ';
      s += terminals[i];
    }
    s += '.';
    this.error(s);
  }

  errorConditionNotBool() {
    this.error(getStr(LanguageText.CONDITION_NOT_BOOLEAN));
  }

  errorUnknownSymbol(String symId) {
    this.error(getStr(LanguageText.UNKNOWN_SYMBOL) + ' ' + symId);
  }

  errorNotAFunction() {
    this.error(getStr(LanguageText.SYMBOL_IS_NOT_A_FUNCTION));
  }

  errorTypesInBinaryOperation(String op, String t1, String t2) {
    this.error(
      getStr(LanguageText.BIN_OP_INCOMPATIBLE_TYPES)
          .replaceAll('\$OP', op)
          .replaceAll('\$T1', t1)
          .replaceAll('\$T2', t2),
    );
  }

  String _err_pos([LexerToken? tk = null]) {
    if (tk == null) tk = this._token as LexerToken;
    return tk.fileID + ':' + tk.row.toString() + ':' + tk.col.toString() + ': ';
  }

  addPutTrailingSemicolon(LexerTokenType type, [terminal = '']) {
    var tk = new LexerToken();
    tk.type = type;
    tk.token = terminal;
    this._putTrailingSemicolon.add(tk);
  }

  /**
   * Sets a set of terminals consisting of identifiers and delimiters.
   * @param terminals
   */
  setTerminals(List<String> terminals) {
    this._terminals.clear();
    this._multicharDelimiters = [];
    for (var ter in terminals) {
      if (ter.length == 0) continue;
      if ((ter.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
              ter.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
          (ter.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
              ter.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
          ter[0] == '_')
        this._terminals.add(ter);
      else
        this._multicharDelimiters.add(ter);
    }
    // must sort delimiters by descending length (e.g. "==" must NOT be tokenized to "=", "=")
    this._multicharDelimiters.sort((a, b) => b.length - a.length);
  }

  List<String> getTerminals() {
    return this._terminals.toList();
  }

  List<String> getMulticharDelimiters() {
    return this._multicharDelimiters;
  }

  LexerToken getToken() {
    return this._token;
  }

  next() {
    this._lastToken = this._token;
    var src = this._fileStack.last.sourceCode;
    var file_id = this._fileStack.last.id;
    var s = this._state;
    if (s.stack.length > 0) {
      this._token = s.stack[0];
      s.stack.removeAt(0); // remove first element
      return;
    }
    this._token = new LexerToken();
    this._token.fileID = file_id;
    // white spaces and comments
    s.indent = -1; // indents are disallowed, until a newline-character is read
    var outputLinefeed = false; // token == "\n"?
    for (;;) {
      // newline
      if (s.i < s.n && src[s.i] == '\n') {
        s.indent = 0;
        outputLinefeed = this._nextTokenLinefeed(s);
      }
      // space
      else if (s.i < s.n && src[s.i] == ' ') {
        s.i++;
        s.col++;
        if (s.indent >= 0) s.indent++;
      }
      // tab
      else if (s.i < s.n && src[s.i] == '\t') {
        s.i++;
        s.col += 4;
        if (s.indent >= 0) s.indent += 4;
      }
      // backslash line break -> consume all following whitespace
      else if (this._allowBackslashLineBreaks &&
          s.i < s.n &&
          src[s.i] == '\\') {
        s.i++;
        while (s.i < s.n) {
          if (src[s.i] == ' ')
            s.col++;
          else if (src[s.i] == '\t')
            s.col += 4;
          else if (src[s.i] == '\n') {
            s.row++;
            s.col = 1;
          } else
            break;
          s.i++;
        }
      }
      // single line comment (slc)
      else if (this._singleLineCommentStart.length > 0 &&
          this._isNext(this._singleLineCommentStart)) {
        if (this._emitIndentation && s.indent >= 0) break;
        var n = this._singleLineCommentStart.length;
        s.i += n;
        s.col += n;
        while (s.i < s.n && src[s.i] != '\n') {
          s.i++;
          s.col++;
        }
        if (s.i < s.n && src[s.i] == '\n') {
          //if (this.nextTokenLinefeed(s)) return;
          outputLinefeed = this._nextTokenLinefeed(s);
        }
        s.indent = 0;
      }
      // multi line comment (mlc)
      else if (this._multiLineCommentStart.length > 0 &&
          this._isNext(this._multiLineCommentStart)) {
        if (this._emitIndentation && s.indent >= 0) break;
        var n = this._multiLineCommentStart.length;
        s.i += n;
        s.col += n;
        while (s.i < s.n && !this._isNext(this._multilineCommentEnd)) {
          if (src[s.i] == '\n') {
            // TODO: this.nextTokenLinefeed(s)!!
            s.row++;
            s.col = 1;
            s.indent = 0;
          } else
            s.col++;
          s.i++;
        }
        n = this._multilineCommentEnd.length;
        s.i += n;
        s.col += n;
      }
      // FILEPOS = PREFIX ":" STR ":" INT ":" "INT";
      else if (this._lexerFilePositionPrefix.length > 0 &&
          src.substring(s.i).startsWith(this._lexerFilePositionPrefix)) {
        s.i += this._lexerFilePositionPrefix.length;
        // path
        var path = '';
        while (s.i < s.n && src[s.i] != ':') {
          path += src[s.i];
          s.i++;
        }
        s.i++;
        this._fileStack.last.id = path;
        this._token.fileID = path;
        // row
        var rowStr = '';
        while (s.i < s.n && src[s.i] != ':') {
          rowStr += src[s.i];
          s.i++;
        }
        s.i++;
        this._token.row = int.parse(rowStr);
        // column
        var colStr = '';
        while (s.i < s.n && src[s.i] != ':') {
          colStr += src[s.i];
          s.i++;
        }
        s.i++;
        this._token.col = int.parse(colStr);
      } else
        break;
    }
    // indentation
    if (this._emitIndentation && s.indent >= 0) {
      var diff = s.indent - s.lastIndent;
      s.lastIndent = s.indent;
      if (diff != 0) {
        if (diff % 4 == 0) {
          var is_plus = diff > 0;
          var n = (diff.abs() / 4).floor();
          for (var k = 0; k < n; k++) {
            this._token = new LexerToken();
            this._token.fileID = file_id;
            this._token.row = s.row;
            if (is_plus)
              this._token.col = s.col - diff + 4 * k;
            else
              this._token.col = s.col;
            this._token.type = LexerTokenType.DEL;
            this._token.token = is_plus ? '\t+' : '\t-';
            s.stack.add(this._token);
          }
          this._token = s.stack[0];
          s.stack.removeAt(0); // remove first
          return;
        } else {
          this._token.row = s.row;
          this._token.col = s.col - diff;
          this._token.type = LexerTokenType.TER;
          this._token.token = '\terr';
          return;
        }
      }
    }
    // in case that this._parseNewLineEnabled == true, we must stop here
    // if "\n" was actually read
    if (outputLinefeed) return;
    // backup current state
    var s_bak = s.copy();
    this._token.row = s.row;
    this._token.col = s.col;
    s.indent = 0;
    // end?
    if (s.i >= s.n) {
      this._token.token = '\$end';
      this._token.type = LexerTokenType.END;
      return;
    }
    // ID = ( "A".."Z" | "a".."z" | underscore&&"_" | hyphen&&"-" | umlaut&&("ä".."ß") )
    //   { "A".."Z" | "a".."z" | "0".."9" | underscore&&"_" | hyphen&&"-" | umlaut&&("ä".."ß") };
    this._token.type = LexerTokenType.ID;
    this._token.token = '';
    if (s.i < s.n &&
        ((src.codeUnitAt(s.i) >= 'A'.codeUnitAt(0) &&
                src.codeUnitAt(s.i) <= 'Z'.codeUnitAt(0)) ||
            (src.codeUnitAt(s.i) >= 'a'.codeUnitAt(0) &&
                src.codeUnitAt(s.i) <= 'z'.codeUnitAt(0)) ||
            (this._allowUnderscoreInID && src[s.i] == '_') ||
            (this._allowHyphenInID && src[s.i] == '-') ||
            (this._allowUmlautInID && 'ÄÖÜäöüß'.contains(src[s.i])))) {
      this._token.token += src[s.i];
      s.i++;
      s.col++;
      while (s.i < s.n &&
          ((src.codeUnitAt(s.i) >= 'A'.codeUnitAt(0) &&
                  src.codeUnitAt(s.i) <= 'Z'.codeUnitAt(0)) ||
              (src.codeUnitAt(s.i) >= 'a'.codeUnitAt(0) &&
                  src.codeUnitAt(s.i) <= 'z'.codeUnitAt(0)) ||
              (src.codeUnitAt(s.i) >= '0'.codeUnitAt(0) &&
                  src.codeUnitAt(s.i) <= '9'.codeUnitAt(0)) ||
              (this._allowUnderscoreInID && src[s.i] == '_') ||
              (this._allowHyphenInID && src[s.i] == '-') ||
              (this._allowUmlautInID && 'ÄÖÜäöüß'.contains(src[s.i])))) {
        this._token.token += src[s.i];
        s.i++;
        s.col++;
      }
    }
    if (this._token.token.length > 0) {
      if (this._terminals.contains(this._token.token))
        this._token.type = LexerTokenType.TER;
      this._state = s;
      return;
    }
    // STR = '"' { any except '"' and '\n' } '"'
    s = s_bak.copy();
    if (this._emitDoubleQuotes) {
      this._token.type = LexerTokenType.STR;
      if (s.i < s.n && src[s.i] == '"') {
        this._token.token = '';
        s.i++;
        s.col++;
        while (s.i < s.n && src[s.i] != '"' && src[s.i] != '\n') {
          this._token.token += src[s.i];
          s.i++;
          s.col++;
        }
        if (s.i < s.n && src[s.i] == '"') {
          s.i++;
          s.col++;
          this._state = s;
          return;
        }
      }
    }
    // STR = '\'' { any except '\'' and '\n' } '\''
    s = s_bak.copy();
    if (this._emitSingleQuotes) {
      this._token.type = LexerTokenType.STR;
      if (s.i < s.n && src[s.i] == "'") {
        this._token.token = '';
        s.i++;
        s.col++;
        while (s.i < s.n && src[s.i] != "'" && src[s.i] != '\n') {
          this._token.token += src[s.i];
          s.i++;
          s.col++;
        }
        if (s.i < s.n && src[s.i] == "'") {
          s.i++;
          s.col++;
          this._state = s;
          return;
        }
      }
    }
    // HEX = "0" "x" { "0".."9" | "A".."F" | "a".."f" }+;
    s = s_bak.copy();
    if (this._emitHex) {
      this._token.type = LexerTokenType.HEX;
      this._token.token = '';
      if (s.i < s.n && src[s.i] == '0') {
        s.i++;
        s.col++;
        if (s.i < s.n && src[s.i] == 'x') {
          s.i++;
          s.col++;
          var k = 0;
          while (s.i < s.n &&
              ((src.codeUnitAt(s.i) >= '0'.codeUnitAt(0) &&
                      src.codeUnitAt(s.i) <= '9'.codeUnitAt(0)) ||
                  (src.codeUnitAt(s.i) >= 'A'.codeUnitAt(0) &&
                      src.codeUnitAt(s.i) <= 'F'.codeUnitAt(0)) ||
                  (src.codeUnitAt(s.i) >= 'a'.codeUnitAt(0) &&
                      src.codeUnitAt(s.i) <= 'f'.codeUnitAt(0)))) {
            this._token.token += src[s.i];
            s.i++;
            s.col++;
            k++;
          }
          if (k > 0) {
            this._token.value = int.parse(this._token.token, radix: 16);
            this._token.token = '0x' + this._token.token;
            this._token.valueBigint = BigInt.parse(this._token.token);
            this._state = s;
            return;
          }
        }
      }
    }
    // INT|BIGINT|REAL = "0" | "1".."9" { "0".."9" } [ "." { "0".."9" } ];
    s = s_bak.copy();
    if (this._emitInt) {
      this._token.type = LexerTokenType.INT;
      this._token.token = '';
      if (s.i < s.n && src[s.i] == '0') {
        this._token.token = '0';
        s.i++;
        s.col++;
      } else if (s.i < s.n &&
          src.codeUnitAt(s.i) >= '1'.codeUnitAt(0) &&
          src.codeUnitAt(s.i) <= '9'.codeUnitAt(0)) {
        this._token.token = src[s.i];
        s.i++;
        s.col++;
        while (s.i < s.n &&
            src.codeUnitAt(s.i) >= '0'.codeUnitAt(0) &&
            src.codeUnitAt(s.i) <= '9'.codeUnitAt(0)) {
          this._token.token += src[s.i];
          s.i++;
          s.col++;
        }
      }
      if (this._token.token.length > 0 &&
          this._emitBigint &&
          s.i < s.n &&
          src[s.i] == 'n') {
        s.i++;
        s.col++;
        this._token.type = LexerTokenType.BIGINT;
      } else if (this._token.token.length > 0 &&
          this._emitReal &&
          s.i < s.n &&
          src[s.i] == '.') {
        this._token.type = LexerTokenType.REAL;
        this._token.token += '.';
        s.i++;
        s.col++;
        while (s.i < s.n &&
            src.codeUnitAt(s.i) >= '0'.codeUnitAt(0) &&
            src.codeUnitAt(s.i) <= '9'.codeUnitAt(0)) {
          this._token.token += src[s.i];
          s.i++;
          s.col++;
        }
      }
      if (this._token.token.length > 0) {
        if (this._token.type == LexerTokenType.INT)
          this._token.value = int.parse(this._token.token);
        else if (this._token.type == LexerTokenType.BIGINT)
          this._token.valueBigint = BigInt.parse(this._token.token);
        else
          this._token.value = num.parse(this._token.token);
        this._state = s;
        return;
      }
    }
    // DEL = /* element of this._multichar_delimiters */;
    this._token.type = LexerTokenType.DEL;
    this._token.token = '';
    for (var k = 0; k < this._multicharDelimiters.length; k++) {
      var d = this._multicharDelimiters[k];
      var match = true;
      s = s_bak.copy();
      for (var l = 0; l < d.length; l++) {
        var ch = d[l];
        if (s.i < s.n && src[s.i] == ch) {
          s.i++;
          s.col++;
        } else {
          match = false;
          break;
        }
      }
      if (match) {
        this._state = s;
        this._token.token = d;
        return;
      }
    }
    // unexpected
    s = s_bak.copy();
    this._token.type = LexerTokenType.DEL;
    this._token.token = '';
    if (s.i < s.n) {
      this._token.token = src[s.i];
      s.i++;
      s.col++;
      this._state = s;
    }
  }

  bool _nextTokenLinefeed(LexerState s) {
    var insertedSemicolon = false;
    if (this._emitNewline) {
      this._token.row = s.row;
      this._token.col = s.col;
      this._token.token = '\n';
      this._token.type = LexerTokenType.DEL;
    } else if (this._putTrailingSemicolon.length > 0) {
      var match = false;
      for (var i = 0; i < this._putTrailingSemicolon.length; i++) {
        var pts = this._putTrailingSemicolon[i];
        if (pts.type == this._lastToken?.type) {
          if (pts.type == LexerTokenType.DEL)
            match = pts.token == this._lastToken?.token;
          else
            match = true;
          if (match) break;
        }
      }
      if (match) {
        insertedSemicolon = true;
        this._token.row = s.row;
        this._token.col = s.col;
        this._token.token = ';';
        this._token.type = LexerTokenType.DEL;
      }
    }
    s.row++;
    s.col = 1;
    s.indent = 0;
    s.i++;
    return this._emitNewline || insertedSemicolon;
  }

  bool _isNext(String str) {
    var src = this._fileStack.last.sourceCode;
    var s = this._state;
    var n = str.length;
    if (s.i + n >= s.n) return false;
    for (var k = 0; k < n; k++) {
      var ch = str[k];
      if (src[s.i + k] != ch) return false;
    }
    return true;
  }

  pushSource(String id, String src, [int initialRowIdx = 1]) {
    if (this._fileStack.length > 0) {
      this._fileStack.last.stateBackup = this._state.copy();
      this._fileStack.last.tokenBackup = this._token.copy();
    }
    var f = new LexerFile();
    f.id = id;
    f.sourceCode = src;
    this._fileStack.add(f);
    this._state = new LexerState();
    this._state.row = initialRowIdx;
    this._state.n = src.length;
    this.next();
  }

  popSource() {
    this._fileStack.removeLast();
    if (this._fileStack.length > 0) {
      this._state = this._fileStack.last.stateBackup as LexerState;
      this._token = this._fileStack.last.tokenBackup as LexerToken;
    }
  }

  LexerBackup backupState() {
    return new LexerBackup(this._state.copy(), this._token.copy());
  }

  void replayState(LexerBackup backup) {
    this._state = backup.state;
    this._token = backup.token;
  }
}

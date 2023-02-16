/*
PROJECT

    MULTILA Compiler and Computer Architecture Infrastructure
    Copyright (c) 2022 by Andreas Schwenk, contact@multila.org
    Licensed by GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

*/

import 'token.dart';

class LexerState {
  int i = 0; // current character index
  int n = -1; // number of characters
  int row = 1;
  int col = 1;
  int indent = 0;
  int lastIndent = 0;
  List<LexerToken> stack =
      []; // tokens that must be put in subsequent next()-calls

  LexerState copy() {
    var bak = new LexerState();
    bak.i = this.i;
    bak.n = this.n;
    bak.row = this.row;
    bak.col = this.col;
    bak.indent = this.indent;
    bak.lastIndent = this.lastIndent;
    for (var i = 0; i < this.stack.length; i++)
      bak.stack.add(this.stack[i].copy());
    return bak;
  }
}

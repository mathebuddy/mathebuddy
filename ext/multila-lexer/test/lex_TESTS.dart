/*
PROJECT

    MULTILA Compiler and Computer Architecture Infrastructure
    Copyright (c) 2022 by Andreas Schwenk, contact@multila.org
    Licensed by GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

*/

import '../src/lex.dart';
import '../src/token.dart';

// TODO: tests for addPutTrailingSemicolon

List<LexerToken> result = [];

void run_internal(Lexer lexer, String id, String src) {
  lexer.pushSource(id, src);
  for (;;) {
    var tk = lexer.getToken();
    result.add(tk);
    //var tkStr = JSON.stringify(tk);
    //console.log(tkStr);
    //console.log(tk);
    if (tk.token == 'import') {
      var myImport = 'a = 3\nb = 4\n';
      run_internal(lexer, 'myImport.txt', myImport);
      lexer.popSource();
    }
    if (tk.type == LexerTokenType.END) break;
    lexer.next();
  }
}

LexerToken createToken(Map<String, dynamic> map) {
  var tk = new LexerToken();
  tk.token = map['token'];
  tk.type = LexerTokenType.values.byName(map['type']);
  tk.value = map['value'];
  if (map.containsKey('valueBigint')) {
    tk.valueBigint = map['valueBigint'];
  }
  tk.fileID = map['fileID'];
  tk.row = map['row'];
  tk.col = map['col'];
  return tk;
}

void run() {
  var lexer = new Lexer();
  lexer.enableEmitNewlines(true);
  lexer.enableEmitIndentation(true);
  lexer.configureSingleLineComments('#');
  lexer.configureMultiLineComments('/*', '*/');
  lexer.enableBackslashLineBreaks(false);

  lexer.setTerminals(['def', 'return', 'import', ':=']);

  var prog = '''def add 123(x, y):
    return z  # comment test
    w = 20
        x = 2.456
                blub /* a multiline
                        comment */
    import
    y = "myString"
    z := bla
    w = 0x2Fa4
sub:
    reg@x reg@y reg@z
    -> [x := y - z]
    -> 2/8, x/8, y/8, z/8;
''';

  run_internal(lexer, 'prog0.txt', prog);

  var xxx = {
    "token": 'def',
    "type": 'TER',
    "value": 0,
    "valueBigint": 0,
    "fileID": 'prog0.txt',
    "row": 1,
    "col": 1,
  };

  var expected = [
    createToken({
      "token": 'def',
      "type": 'TER',
      "value": 0,
      "valueBigint": BigInt.from(0),
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 1,
    }),
    createToken({
      "token": 'add',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 5,
    }),
    createToken({
      "token": '123',
      "type": 'INT',
      "value": 123,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 9,
    }),
    createToken({
      "token": '(',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 12,
    }),
    createToken({
      "token": 'x',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 13,
    }),
    createToken({
      "token": ',',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 14,
    }),
    createToken({
      "token": 'y',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 16,
    }),
    createToken({
      "token": ')',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 17,
    }),
    createToken({
      "token": ':',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 18,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 1,
      "col": 19,
    }),*/
    createToken({
      "token": '\t+',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 2,
      "col": 1,
    }),
    createToken({
      "token": 'return',
      "type": 'TER',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 2,
      "col": 5,
    }),
    createToken({
      "token": 'z',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 2,
      "col": 12,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 2,
      "col": 29,
    }),
    createToken({
      "token": 'w',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 3,
      "col": 5,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 3,
      "col": 7,
    }),
    createToken({
      "token": '20',
      "type": 'INT',
      "value": 20,
      "fileID": 'prog0.txt',
      "row": 3,
      "col": 9,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 3,
      "col": 11,
    }),*/
    createToken({
      "token": '\t+',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 4,
      "col": 5,
    }),
    createToken({
      "token": 'x',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 4,
      "col": 9,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 4,
      "col": 11,
    }),
    createToken({
      "token": '2.456',
      "type": 'REAL',
      "value": 2.456,
      "fileID": 'prog0.txt',
      "row": 4,
      "col": 13,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 4,
      "col": 18,
    }),*/
    createToken({
      "token": '\t+',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 5,
      "col": 9,
    }),
    createToken({
      "token": '\t+',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 5,
      "col": 13,
    }),
    createToken({
      "token": 'blub',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 5,
      "col": 17,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 6,
      "col": 35,
    }),*/
    createToken({
      "token": '\t-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 7,
      "col": 5,
    }),
    createToken({
      "token": '\t-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 7,
      "col": 5,
    }),
    createToken({
      "token": '\t-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 7,
      "col": 5,
    }),
    createToken({
      "token": 'import',
      "type": 'TER',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 7,
      "col": 5,
    }),
    createToken({
      "token": 'a',
      "type": 'ID',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 1,
      "col": 1,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 1,
      "col": 3,
    }),
    createToken({
      "token": '3',
      "type": 'INT',
      "value": 3,
      "fileID": 'myImport.txt',
      "row": 1,
      "col": 5,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 1,
      "col": 6,
    }),
    createToken({
      "token": 'b',
      "type": 'ID',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 2,
      "col": 1,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 2,
      "col": 3,
    }),
    createToken({
      "token": '4',
      "type": 'INT',
      "value": 4,
      "fileID": 'myImport.txt',
      "row": 2,
      "col": 5,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 2,
      "col": 6,
    }),
    createToken({
      "token": '\$end',
      "type": 'END',
      "value": 0,
      "fileID": 'myImport.txt',
      "row": 3,
      "col": 1,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 7,
      "col": 11,
    }),
    createToken({
      "token": 'y',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 8,
      "col": 5,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 8,
      "col": 7,
    }),
    createToken({
      "token": 'myString',
      "type": 'STR',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 8,
      "col": 9,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 8,
      "col": 19,
    }),
    createToken({
      "token": 'z',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 9,
      "col": 5,
    }),
    createToken({
      "token": ':=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 9,
      "col": 7,
    }),
    createToken({
      "token": 'bla',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 9,
      "col": 10,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 9,
      "col": 13,
    }),
    createToken({
      "token": 'w',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 10,
      "col": 5,
    }),
    createToken({
      "token": '=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 10,
      "col": 7,
    }),
    createToken({
      "token": '0x2Fa4',
      "type": 'HEX',
      "value": 12196,
      "valueBigint": BigInt.from(12196),
      "fileID": 'prog0.txt',
      "row": 10,
      "col": 9,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 10,
      "col": 15,
    }),*/
    createToken({
      "token": '\t-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 11,
      "col": 1,
    }),
    createToken({
      "token": 'sub',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 11,
      "col": 1,
    }),
    createToken({
      "token": ':',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 11,
      "col": 4,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 11,
      "col": 5,
    }),*/
    createToken({
      "token": '\t+',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 1,
    }),
    createToken({
      "token": 'reg',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 5,
    }),
    createToken({
      "token": '@',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 8,
    }),
    createToken({
      "token": 'x',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 9,
    }),
    createToken({
      "token": 'reg',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 11,
    }),
    createToken({
      "token": '@',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 14,
    }),
    createToken({
      "token": 'y',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 15,
    }),
    createToken({
      "token": 'reg',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 17,
    }),
    createToken({
      "token": '@',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 20,
    }),
    createToken({
      "token": 'z',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 21,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 12,
      "col": 22,
    }),
    createToken({
      "token": '-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 5,
    }),
    createToken({
      "token": '>',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 6,
    }),
    createToken({
      "token": '[',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 8,
    }),
    createToken({
      "token": 'x',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 9,
    }),
    createToken({
      "token": ':=',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 11,
    }),
    createToken({
      "token": 'y',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 14,
    }),
    createToken({
      "token": '-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 16,
    }),
    createToken({
      "token": 'z',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 18,
    }),
    createToken({
      "token": ']',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 19,
    }),
    createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 13,
      "col": 20,
    }),
    createToken({
      "token": '-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 5,
    }),
    createToken({
      "token": '>',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 6,
    }),
    createToken({
      "token": '2',
      "type": 'INT',
      "value": 2,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 8,
    }),
    createToken({
      "token": '/',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 9,
    }),
    createToken({
      "token": '8',
      "type": 'INT',
      "value": 8,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 10,
    }),
    createToken({
      "token": ',',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 11,
    }),
    createToken({
      "token": 'x',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 13,
    }),
    createToken({
      "token": '/',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 14,
    }),
    createToken({
      "token": '8',
      "type": 'INT',
      "value": 8,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 15,
    }),
    createToken({
      "token": ',',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 16,
    }),
    createToken({
      "token": 'y',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 18,
    }),
    createToken({
      "token": '/',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 19,
    }),
    createToken({
      "token": '8',
      "type": 'INT',
      "value": 8,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 20,
    }),
    createToken({
      "token": ',',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 21,
    }),
    createToken({
      "token": 'z',
      "type": 'ID',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 23,
    }),
    createToken({
      "token": '/',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 24,
    }),
    createToken({
      "token": '8',
      "type": 'INT',
      "value": 8,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 25,
    }),
    createToken({
      "token": ';',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 26,
    }),
    /*createToken({
      "token": '\n',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 14,
      "col": 27,
    }),*/
    createToken({
      "token": '\t-',
      "type": 'DEL',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 15,
      "col": 1,
    }),
    createToken({
      "token": '\$end',
      "type": 'END',
      "value": 0,
      "fileID": 'prog0.txt',
      "row": 15,
      "col": 1,
    }),
  ];

  assert(result.length == expected.length);
  for (var i = 0; i < result.length; i++) {
    var ok = result[i].compare(expected[i]);
    if (!ok) {
      print('=== UNEQUAL ===');
      var r = result[i];
      var e = expected[i];
      print(r);
      print(e);
    }
    assert(ok);
  }
  print("tests succeeded!");
}

void main() {
  run();
}

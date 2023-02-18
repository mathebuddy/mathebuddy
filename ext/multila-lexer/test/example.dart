// import multila-lexer
import '../src/lex.dart';

void parse(String src) {
  // create a new lexer instance
  var lexer = new Lexer();

  // configuration
  lexer.configureSingleLineComments('#');

  // must add operators with two or more chars
  lexer.setTerminals([':=']);

  // source code to be parsed
  lexer.pushSource('mySource', src);
  parseProgram(lexer);
}

//G program = { assignment };
void parseProgram(Lexer lexer) {
  while (lexer.isNotEND()) {
    parseAssignment(lexer);
  }
}

//G assignment = ID ":=" add ";";
void parseAssignment(Lexer lexer) {
  var id = lexer.ID();
  print(id);
  lexer.TER(':=');
  parseAdd(lexer);
  lexer.TER(';');
  print('assign');
}

//G add = mul { "+" mul };
void parseAdd(Lexer lexer) {
  parseMul(lexer);
  while (lexer.isTER('+')) {
    lexer.next();
    parseMul(lexer);
    print('add');
  }
}

//G mul = unary { "*" unary };
void parseMul(Lexer lexer) {
  parseUnary(lexer);
  while (lexer.isTER('*')) {
    lexer.next();
    parseUnary(lexer);
    print('mul');
  }
}

//G unary = ID | INT | "(" add ")";
void parseUnary(Lexer lexer) {
  if (lexer.isID()) {
    var id = lexer.ID();
    print(id);
  } else if (lexer.isINT()) {
    var value = lexer.INT();
    print(value);
  } else if (lexer.isTER('(')) {
    lexer.next();
    parseAdd(lexer);
    lexer.TER(')');
  } else {
    lexer.error('expected ID or INT');
  }
}

void main() {
  var src = '''# comment
x := 3 * (4+5);''';
  parse(src);
  print("..ready");
}

// the output is:
// x 3 4 5 add mul assign

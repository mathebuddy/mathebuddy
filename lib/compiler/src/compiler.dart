/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../../ext/multila-lexer/src/lex.dart';
import '../../../ext/multila-lexer/src/token.dart';
import 'block.dart';
import 'data/dataChapter.dart';
import 'data/dataCourse.dart';
import 'data/dataExercise.dart';
import 'data/dataLevel.dart';
import 'data/dataSection.dart';
import 'data/dataText.dart';
import 'data/dataUnit.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbl.html

class Compiler {
  _loadFile: (String path) => String = null;

  MBL_Course _course = null;
  MBL_Chapter _chapter = null;
  MBL_Unit _unit = null;
  MBL_Level _level = null;

  List<String> _srcLines = [];
  int _i = -1; // current line index (starting from 0)
  String _line = ''; // current line
  String _line2 = ''; // next line
  String _paragraph = '';

  int _uniqueIdCounter = 0;

  int createUniqueId() {
    return this._uniqueIdCounter++;
  }

  MBL_Course getCourse() {
    return this._course;
  }

  void compile(String path, loadFile: (path: string) => string) {
    // store load function
    this._loadFile = loadFile;
    // compile
    if (path.endsWith('course.mbl')) {
      // processing complete course
      this._compileCourse(path);
    } else if (path.endsWith('index.mbl')) {
      // processing only a course chapter
      this._course = new MBL_Course();
      this._course.debug = MBL_Course_Debug.Chapter;
      this._compileChapter(path);
    } else {
      // processing only a course level
      this._course = new MBL_Course();
      this._course.debug = MBL_Course_Debug.Level;
      this._chapter = new MBL_Chapter();
      this._course.chapters.push(this._chapter);
      this.compileLevel(path);
    }
    // post processing
    this._course.postProcess();
  }

  //G course = courseTitle courseAuthor courseChapters;
  //G courseTitle = "TITLE" { ID } "\n";
  //G courseAuthor = "AUTHOR" { ID } "\n";
  //G courseChapters = "CHAPTERS" "\n" { courseChapter };
  //G courseChapter = "(" INT "," INT ")" ID { "!" ID } "\n";
  void compileCourse(String path) {
    // create a new course
    this._course = new MBL_Course();
    // get course description file source
    var src = this.loadFile(path);
    if (src.length == 0) {
      this._error(
        'course description file ' + path + ' does not exist or is empty',
      );
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';
    var rowIdx = 0;
    for (var line of lines) {
      rowIdx++;
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state == 'global') {
        if (line.startsWith('TITLE'))
          this._course.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this._course.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('CHAPTERS')) state = 'chapter';
        else this._error('unexpected line ' + line);
      } else if (state == 'chapter') {
        var lexer = new Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.TER('(');
        var posX = lexer.INT();
        lexer.TER(',');
        var posY = lexer.INT();
        lexer.TER(')');
        var directoryName = lexer.ID();
        var requirements: string[] = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.push(lexer.ID());
        }
        lexer.END();
        // compile chapter
        var dirname = path.match(/.*\//);
        var chapterPath = dirname + directoryName + '/index.mbl';
        this.compileChapter(chapterPath);
        // set chapter meta data
        this._chapter.file_id = directoryName;
        this._chapter.pos_x = posX;
        this._chapter.pos_y = posY;
        this._chapter.requires_tmp.push(...requirements);
      }
    }
    // build dependency graph
    for (var chapter of this._course.chapters) {
      for (var r of chapter.requires_tmp) {
        var requiredChapter = this._course.getChapterByFileID(r);
        if (requiredChapter == null) this._error('unknown chapter ' + r);
        else chapter.requires.push(requiredChapter);
      }
    }
  }

  //G chapter = chapterTitle chapterAuthor { chapterUnit };
  //G chapterTitle = "TITLE" { ID } "\n";
  //G chapterAuthor = "AUTHOR" { ID } "\n";
  //G chapterUnit = "UNIT" { ID } "\n" { chapterLevel };
  //G chapterLevel = "(" INT "," INT ")" ID { "!" ID } "\n";
  void compileChapter(String path) {
    // create a new chapter
    this._chapter = new MBL_Chapter();
    this._course.chapters.add(this._chapter);
    // get chapter index file source
    var src = this.loadFile(path);
    if (src.length == 0) {
      this._error('chapter index file ' + path + ' does not exist or is empty');
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';
    var rowIdx = 0;
    for (var line of lines) {
      rowIdx++;
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state == 'global' || line.startsWith('UNIT')) {
        if (line.startsWith('TITLE'))
          this._chapter.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this._chapter.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('UNIT')) {
          // TODO: handle units!!
          var unitTitle = line.substring('UNIT'.length).trim();
          state = 'unit';
          this._unit = new MBL_Unit();
          this._unit.title = unitTitle;
          this._chapter.units.push(this._unit);
        } else this._error('unexpected line ' + line);
      } else if (state == 'unit') {
        var lexer = new Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.TER('(');
        var posX = lexer.INT();
        lexer.TER(',');
        var posY = lexer.INT();
        lexer.TER(')');
        var fileName = lexer.ID();
        var requirements: string[] = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.push(lexer.ID());
        }
        lexer.END();
        // compile level
        var dirname = path.match(/.*\//);
        var levelPath = dirname + fileName + '.mbl';
        this.compileLevel(levelPath);
        this._unit.levels.push(this._level);
        // set chapter meta data
        this._level.file_id = fileName;
        this._level.pos_x = posX;
        this._level.pos_y = posY;
        this._level.requires_tmp.push(...requirements);
      }
    }
    // build dependency graph
    for (var level of this._chapter.levels) {
      for (var r of level.requires_tmp) {
        var requiredLevel = this._chapter.getLevelByFileID(r);
        if (requiredLevel == null) this._error('unknown level ' + r);
        else level.requires.push(requiredLevel);
      }
    }
  }

  //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };
  void compileLevel(String path) {
    // create a new level
    this._level = new MBL_Level();
    this._chapter.levels.add(this._level);
    // get level source
    var src = this.loadFile(path);
    if (src.length == 0)
      this._error('level file ' + path + ' does not exist or is empty');
    // set source, split it into lines, trim these lines and
    // filter out comments of each line
    this._srcLines = src.split('\n');
    for (var k = 0; k < this._srcLines.length; k++) {
      var line = this._srcLines[k].trim();
      var tokens = line.split('%');
      this._srcLines[k] = tokens[0];
    }
    // init lexer
    this._i = -1;
    this._next();
    // parse
    while (this._line != '§END') {
      if (this._line2.startsWith('#####')) {
        this._pushParagraph();
        this._parseLevelTitle();
      } else if (this._line2.startsWith('==')) {
        this._pushParagraph();
        this._level.items.add(this._parseSectionTitle());
      } else if (this._line2.startsWith('-----')) {
        this._pushParagraph();
        this._level.items.add(this._parseSubSectionTitle());
      } else if (this._line == '---') {
        this._pushParagraph();
        this._level.items.add(this._parseBlock(false));
      } else {
        this._paragraph += this._line + '\n';
        this._next();
      }
    }
    this._pushParagraph();
  }

  void _pushParagraph() {
    if (this._paragraph.trim().length > 0) {
      this._level.items.add(this.parseParagraph(this._paragraph));
      this._paragraph = '';
    }
  }

  void _next() {
    this._i++;
    if (this._i < this._srcLines.length) {
      this._line = this._srcLines[this._i];
    } else this._line = '§END';
    if (this._i + 1 < this._srcLines.length) {
      this._line2 = this._srcLines[this._i + 1];
    } else this._line2 = '§END';
  }

  //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;
  void _parseLevelTitle() {
    var tokens = this._line.split('@');
    this._level.title = tokens[0].trim();
    if (tokens.length > 1) {
      this._level.label = tokens[1].trim();
    }
    this._next(); // skip document title
    this._next(); // skip '#####..'
  }

  //G sectionTitle = { CHAR } "@" { ID } NEWLINE "==.." { "#" } NEWLINE;
  MBL_Section _parseSectionTitle() {
    var section = new MBL_Section(MBL_SectionType.Section);
    var tokens = this._line.split('@');
    section.text = tokens[0].trim();
    if (tokens.length > 1) {
      section.label = tokens[1].trim();
    }
    this._next(); // skip section title
    this._next(); // skip '==..'
    return section;
  }

  //G subSectionTitle = { CHAR } "@" { ID } NEWLINE "-----.." { "#" } NEWLINE;
  MBL_Section _parseSubSectionTitle() {
    var subSection = new MBL_Section(MBL_SectionType.SubSection);
    var tokens = this._line.split('@');
    subSection.text = tokens[0].trim();
    if (tokens.length > 1) {
      subSection.label = tokens[1].trim();
    }
    this._next(); // skip subSection title
    this._next(); // skip '-----..'
    return subSection;
  }

  //G block = "---" NEWLINE { "@" ID NEWLINE | LINE } "---" NEWLINE;
  // TODO: grammar for subblocks
  MBL_LevelItem _parseBlock(bool parseSubBlock) {
    var block = new Block(this);
    block.srcLine = this._i;
    if (!parseSubBlock) this._next(); // skip "---"
    var tokens = this._line.split(' ');
    for (var k = 0; k < tokens.length; k++) {
      if (k == 0) block.type = tokens[k];
      else if (tokens[k].startsWith('@')) block.label = tokens[k];
      else block.title += tokens[k] + ' ';
    }
    block.title = block.title.trim();
    this._next();
    BlockPart part = new BlockPart();
    part.name = 'global';
    block.parts.push(part);
    while (this._line != '---' && this._line != '§END') {
      if (this._line.startsWith('@')) {
        part = new BlockPart();
        block.parts.push(part);
        part.name = this._line.substring(1).trim();
        this._next();
      } else if (
        this._line.length >= 3 &&
        this._line.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        this._line.codeUnitAt(0) <= 'Z'.codeUnitAt(0) &&
        this._line.substring(0, 3) == this._line.toUpperCase().substring(0, 3)
      ) {
        if (parseSubBlock) break;
        else block.parts.push(this._parseBlock(true));
      } else {
        part.lines.add(this._line);
        this._next();
      }
    }
    if (!parseSubBlock) {
      if (this._line == '---') this._next();
      else
        this._error(
          'block started in line ' + block.srcLine.toString() + ' must end with ---',
        );
    }
    return block.process();
  }

  /*G
     paragraph =
        { paragraphPart };
     paragraphPart =
      | "**" {paragraphPart} "**"
      | "*" {paragraphPart} "*"
      | "[" {paragraphPart} "]" "@" ID
      | "$" inlineMath "$"
      | "#" ID                                     (exercise only)
      | <START>"[" [ ("x"|":"ID) ] "]" {paragraphPart} "\n"  (exercise only)
      | <START>"(" [ ("x"|":"ID) ] ")" {paragraphPart} "\n"  (exercise only)
      | <START>"#" {paragraphPart} "\n"
      | <START>"-" {paragraphPart} "\n"
      | <START>"-)" {paragraphPart} "\n"
      | ID
      | DEL;
   */
  MBL_Text parseParagraph(String raw, [MBL_Exercise? ex = null]) {
    // skip empty paragraphs
    if (raw.trim().length == 0)
      //return new ParagraphItem(ParagraphItemType.Text);
      return new MBL_Text_Text(); // TODO: OK??
    // create lexer
    var lexer = new Lexer();
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.pushSource('', raw);
    lexer.setTerminals(['**', '#.', '-)']);
    var paragraph = new MBL_Text_Paragraph();
    while (lexer.isNotEND())
      paragraph.items.add(this.parseParagraph_part(lexer, ex));
    return paragraph;
  }

  MBL_Text _parseParagraph_part(Lexer lexer, MBL_Exercise exercise) {
    if (
      lexer.getToken().col == 1 &&
      (lexer.isTER('-') || lexer.isTER('#.') || lexer.isTER('-)'))
    ) {
      // itemize or enumerate
      return this.parseItemize(lexer, exercise);
    } else if (lexer.isTER('**')) {
      // bold text
      return this.parseBoldText(lexer, exercise);
    } else if (lexer.isTER('*')) {
      // italic text
      return this.parseItalicText(lexer, exercise);
    } else if (lexer.isTER('$')) {
      // inline math
      return this.parseInlineMath(lexer, exercise);
    } else if (lexer.isTER('@')) {
      // reference
      return this.parseReference(lexer);
    } else if (exercise != null && lexer.isTER('#')) {
      // input element(s)
      return this.parseInputElements(lexer, exercise);
    } else if (
      exercise != null &&
      lexer.getToken().col == 1 &&
      (lexer.isTER('[') || lexer.isTER('('))
    ) {
      // single or multiple choice answer
      return this.parseSingleOrMultipleChoice(lexer, exercise);
    } else if (lexer.isTER('\n')) {
      // line feed
      var isNewParagraph = lexer.getToken().col == 1;
      lexer.next();
      if (isNewParagraph) return new MBL_Text_Linefeed();
      else return new MBL_Text_Text();
    } else if (lexer.isTER('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return this.parseTextProperty(lexer, exercise);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      var text = new MBL_Text_Text();
      text.value = lexer.getToken().token;
      lexer.next();
      return text;
    }
    throw new Error('this should never happen!');
  }

  MBL_Text _parseItemize(Lexer lexer, MBL_Exercise exercise) {
    // '-' for itemize; '#.' for enumerate; '-)' for alpha enumerate
    var typeStr = lexer.getToken().token;
    MBL_Text_Itemize_Type type;
    switch (typeStr) {
      case '-':
        type = MBL_Text_Itemize_Type.Itemize;
        break;
      case '#.':
        type = MBL_Text_Itemize_Type.Enumerate;
        break;
      case '-)':
        type = MBL_Text_Itemize_Type.EnumerateAlpha;
        break;
    }
    var itemize = new MBL_Text_Itemize(type);
    while (lexer.getToken().col == 1 && lexer.isTER(typeStr)) {
      lexer.next();
      var span = new MBL_Text_Span();
      itemize.items.add(span);
      while (lexer.isNotNEWLINE() && lexer.isNotEND())
        span.items.add(this._parseParagraph_part(lexer, exercise));
      if (lexer.isNEWLINE()) lexer.NEWLINE();
    }
    return itemize;
  }

  MBL_Text _parseBoldText(Lexer lexer, MBL_Exercise exercise) {
    lexer.next();
    var bold = new MBL_Text_Bold();
    while (lexer.isNotTER('**') && lexer.isNotEND())
      bold.items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER('**')) lexer.next();
    return bold;
  }

  MBL_Text _parseItalicText(Lexer lexer, MBL_Exercise exercise) {
    lexer.next();
    var italic = new MBL_Text_Italic();
    while (lexer.isNotTER('*') && lexer.isNotEND())
      italic.items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER('*')) lexer.next();
    return italic;
  }

  MBL_Text _parseInlineMath(Lexer lexer, MBL_Exercise exercise) {
    lexer.next();
    var inlineMath = new MBL_Text_InlineMath();
    while (lexer.isNotTER('\$') && lexer.isNotEND()) {
      var tk = lexer.getToken().token;
      var isId = lexer.getToken().type == LexerTokenType.ID;
      lexer.next();
      if (isId && exercise != null && tk in exercise.variables) {
        var v = new MBL_Exercise_Text_Variable();
        v.variableId = tk;
        inlineMath.items.add(v);
      } else {
        var text = new MBL_Text_Text();
        text.value = tk;
        inlineMath.items.add(text);
      }
    }
    if (lexer.isTER('\$')) lexer.next();
    return inlineMath;
  }

  MBL_Text _parseReference(Lexer lexer) {
    lexer.next();
    var ref = new MBL_Text_Reference();
    if (lexer.isID()) {
      ref.label = lexer.getToken().token;
      lexer.next();
    }
    return ref;
  }

  MBL_Text _parseInputElements(Lexer lexer, MBL_Exercise exercise) {
    lexer.next();
    var id = '';
    var input = new MBL_Exercise_Text_Input();
    input.input_id = 'input' + this.createUniqueId().toString();
    if (lexer.isID()) {
      id = lexer.ID();
      if (id in exercise.variables) {
        var v = exercise.variables[id];
        input.variable = id;
        switch (v.type) {
          case MBL_Exercise_VariableType.Int:
            input.input_type = MBL_Exercise_Text_Input_Type.Int;
            break;
          case MBL_Exercise_VariableType.IntSet:
            input.input_type = MBL_Exercise_Text_Input_Type.IntSet;
            break;
          case MBL_Exercise_VariableType.Real:
            input.input_type = MBL_Exercise_Text_Input_Type.Real;
            break;
          case MBL_Exercise_VariableType.Complex:
            input.input_type = MBL_Exercise_Text_Input_Type.ComplexNormal;
            break;
          case MBL_Exercise_VariableType.ComplexSet:
            input.input_type = MBL_Exercise_Text_Input_Type.ComplexSet;
            break;
          case MBL_Exercise_VariableType.Matrix:
            input.input_type = MBL_Exercise_Text_Input_Type.Matrix;
            break;
          default:
            exercise.error += 'UNIMPLEMENTED input type ' + v.type.name + '. ';
        }
      } else {
        exercise.error = 'there is no variable "' + id + '". ';
      }
    } else {
      exercise.error = 'no variable for input field given. ';
    }
    return input;
  }

  MBL_Text _parseSingleOrMultipleChoice(
    Lexer lexer,
    MBL_Exercise exercise,
  ) {
    var isMultipleChoice = lexer.isTER('[');
    lexer.next();
    var staticallyCorrect = false;
    var varId = '';
    if (lexer.isTER('x')) {
      lexer.next();
      staticallyCorrect = true;
    } else if (lexer.isTER(':')) {
      lexer.next();
      if (lexer.isID) {
        varId = lexer.ID();
        if (varId in exercise.variables == false)
          exercise.error = 'unknown variable ' + varId;
      } else {
        exercise.error = 'expected ID after :';
      }
    }
    var element:
      | MBL_Exercise_Text_Multiple_Choice
      | MBL_Exercise_Text_Single_Choice = null;
    if (varId.length == 0)
      varId = exercise.addStaticBooleanVariable(staticallyCorrect);
    if (isMultipleChoice) {
      if (lexer.isTER(']')) lexer.next();
      else exercise.error = 'expected ]';
      element = new MBL_Exercise_Text_Multiple_Choice();
    } else {
      if (lexer.isTER(')')) lexer.next();
      else exercise.error = 'expected )';
      element = new MBL_Exercise_Text_Multiple_Choice();
    }
    var option = new MBL_Exercise_Text_Single_or_Multi_Choice_Option();
    option.input_id = 'input' + this.createUniqueId();
    option.variable = varId;
    element.items.push(option);
    var span = new MBL_Text_Span();
    option.text = span;
    while (lexer.isNotNEWLINE() && lexer.isNotEND())
      span.items.push(this.parseParagraph_part(lexer, exercise));
    if (lexer.isTER('\n')) lexer.next();
    return element;
  }

  MBL_Text _parseTextProperty(Lexer lexer, MBL_Exercise exercise) {
    // TODO: make sure, that errors are not too annoying...
    lexer.next();
    List<MBL_Text> items = [];
    while (lexer.isNotTER(']') && lexer.isNotEND())
      items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER(']')) lexer.next();
    else return new MBL_Text_Error('expected ]');
    if (lexer.isTER('@')) lexer.next();
    else return new MBL_Text_Error('expected @');
    if (lexer.isID()) {
      var id = lexer.ID();
      if (id == 'bold') {
        var bold = new MBL_Text_Bold();
        bold.items = items;
        return bold;
      } else if (id == 'italic') {
        var italic = new MBL_Text_Italic();
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        var color = new MBL_Text_Color();
        color.key = parseInt(id.substring(5)); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return new MBL_Text_Error('unknown property ' + id);
      }
    } else return new MBL_Text_Error('missing property name');
  }

  void _error(String message) {
    // TODO: include file path!
    throw new Exception('ERROR:' + (this._i + 1).toString() + ': ' + message);
  }
}

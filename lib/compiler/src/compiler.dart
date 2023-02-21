/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../../ext/multila-lexer/src/lex.dart';
import '../../../ext/multila-lexer/src/token.dart';

import '../../mbcl/src/course.dart';
import '../../mbcl/src/level_item.dart';

import 'block.dart';
import 'chapter.dart';
import 'course.dart';
import 'help.dart';
import 'level.dart';
import 'level_item.dart';
import 'unit.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbl.html

class Compiler {
  Function(String) _loadFile;

  MBCL_Course? _course = null;
  MBCL_Chapter? _chapter = null;
  MBCL_Unit? _unit = null;
  MBCL_Level? _level = null;

  List<String> _srcLines = [];
  int _i = -1; // current line index (starting from 0)
  String _line = ''; // current line
  String _line2 = ''; // next line
  String _paragraph = '';

  int _uniqueIdCounter = 0;

  Compiler(this._loadFile);

  MBCL_Course? getCourse() {
    return this._course;
  }

  //void compile(String path, loadFile: (path: string) => string) {
  void compile(String path) {
    // compile
    if (path.endsWith('course.mbl')) {
      // processing complete course
      this.compileCourse(path);
    } else if (path.endsWith('index.mbl')) {
      // processing only a course chapter
      this._course = new MBCL_Course();
      this._course?.debug = MBCL_Course_Debug.Chapter;
      this.compileChapter(path);
    } else {
      // processing only a course level
      this._course = new MBCL_Course();
      this._course?.debug = MBCL_Course_Debug.Level;
      this._chapter = new MBCL_Chapter();
      this._course?.chapters.add(this._chapter as MBCL_Chapter);
      this.compileLevel(path);
    }
    // post processing
    this._course?.postProcess();
  }

  //G course = courseTitle courseAuthor courseChapters;
  //G courseTitle = "TITLE" { ID } "\n";
  //G courseAuthor = "AUTHOR" { ID } "\n";
  //G courseChapters = "CHAPTERS" "\n" { courseChapter };
  //G courseChapter = "(" INT "," INT ")" ID { "!" ID } "\n";
  void compileCourse(String path) {
    // create a new course
    this._course = new MBCL_Course();
    // get course description file source
    var src = this._loadFile(path);
    if (src.length == 0) {
      this._error(
        'course description file ' + path + ' does not exist or is empty',
      );
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';

    for (var rowIdx = 0; rowIdx < lines.length; rowIdx++) {
      var line = lines[rowIdx];
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state == 'global') {
        if (line.startsWith('TITLE'))
          this._course?.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this._course?.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('CHAPTERS'))
          state = 'chapter';
        else
          this._error('unexpected line ' + line);
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
        List<String> requirements = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.add(lexer.ID());
        }
        lexer.END();
        // compile chapter
        var dirname = extractDirname(path);
        var chapterPath = dirname + directoryName + '/index.mbl';
        this.compileChapter(chapterPath);
        // set chapter meta data
        this._chapter?.file_id = directoryName;
        this._chapter?.pos_x = posX;
        this._chapter?.pos_y = posY;
        this._chapter?.requires_tmp.addAll(requirements);
      }
    }
    // build dependency graph
    for (var i = 0; i < (this._course as MBCL_Course).chapters.length; i++) {
      var chapter = this._course?.chapters[i] as MBCL_Chapter;
      for (var j = 0; j < chapter.requires_tmp.length; j++) {
        var r = chapter.requires_tmp[j];
        var requiredChapter = this._course?.getChapterByFileID(r);
        if (requiredChapter == null)
          this._error('unknown chapter ' + r);
        else
          chapter.requires.add(requiredChapter);
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
    this._chapter = new MBCL_Chapter();
    this._course?.chapters.add(this._chapter as MBCL_Chapter);
    // get chapter index file source
    var src = this._loadFile(path);
    if (src.length == 0) {
      this._error('chapter index file ' + path + ' does not exist or is empty');
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';
    for (var rowIdx = 0; rowIdx < lines.length; rowIdx++) {
      var line = lines[rowIdx];
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state == 'global' || line.startsWith('UNIT')) {
        if (line.startsWith('TITLE'))
          this._chapter?.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this._chapter?.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('UNIT')) {
          // TODO: handle units!!
          var unitTitle = line.substring('UNIT'.length).trim();
          state = 'unit';
          this._unit = new MBCL_Unit();
          this._unit?.title = unitTitle;
          this._chapter?.units.add(this._unit as MBCL_Unit);
        } else
          this._error('unexpected line ' + line);
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
        List<String> requirements = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.add(lexer.ID());
        }
        lexer.END();
        // compile level
        var dirname = extractDirname(path);
        var levelPath = dirname + fileName + '.mbl';
        this.compileLevel(levelPath);
        this._unit?.levels.add(this._level as MBCL_Level);
        // set chapter meta data
        this._level?.file_id = fileName;
        this._level?.pos_x = posX;
        this._level?.pos_y = posY;
        this._level?.requires_tmp.addAll(requirements);
      }
    }
    // build dependency graph
    for (var i = 0; i < (this._chapter as MBCL_Chapter).levels.length; i++) {
      var level = this._chapter?.levels[i] as MBCL_Level;
      for (var j = 0; j < level.requires_tmp.length; j++) {
        var r = level.requires_tmp[j];
        var requiredLevel = this._chapter?.getLevelByFileID(r);
        if (requiredLevel == null)
          this._error('unknown level ' + r);
        else
          level.requires.add(requiredLevel);
      }
    }
  }

  //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };
  void compileLevel(String path) {
    // create a new level
    this._level = new MBCL_Level();
    this._chapter?.levels.add(this._level as MBCL_Level);
    // get level source
    var src = this._loadFile(path);
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
        this._level?.items.add(this._parseSectionTitle());
      } else if (this._line2.startsWith('-----')) {
        this._pushParagraph();
        this._level?.items.add(this._parseSubSectionTitle());
      } else if (this._line == '---') {
        this._pushParagraph();
        var block = this._parseBlock(false);
        this._level?.items.add(block.levelItem);
      } else {
        this._paragraph += this._line + '\n';
        this._next();
      }
    }
    this._pushParagraph();
  }

  int _createUniqueId() {
    return this._uniqueIdCounter++;
  }

  void _pushParagraph() {
    if (this._paragraph.trim().length > 0) {
      this._level?.items.add(this.parseParagraph(this._paragraph));
      this._paragraph = '';
    }
  }

  void _next() {
    this._i++;
    if (this._i < this._srcLines.length) {
      this._line = this._srcLines[this._i];
    } else
      this._line = '§END';
    if (this._i + 1 < this._srcLines.length) {
      this._line2 = this._srcLines[this._i + 1];
    } else
      this._line2 = '§END';
  }

  //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;
  void _parseLevelTitle() {
    var tokens = this._line.split('@');
    this._level?.title = tokens[0].trim();
    if (tokens.length > 1) {
      this._level?.label = tokens[1].trim();
    }
    this._next(); // skip document title
    this._next(); // skip '#####..'
  }

  //G sectionTitle = { CHAR } "@" { ID } NEWLINE "==.." { "#" } NEWLINE;
  MBCL_LevelItem _parseSectionTitle() {
    var section = new MBCL_LevelItem(MBCL_LevelItemType.Section);
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
  MBCL_LevelItem _parseSubSectionTitle() {
    var subSection = new MBCL_LevelItem(MBCL_LevelItemType.SubSection);
    var tokens = this._line.split('@');
    subSection.text = tokens[0].trim();
    if (tokens.length > 1) {
      subSection.label = tokens[1].trim();
    }
    this._next(); // skip subSection title
    this._next(); // skip '-----..'
    return subSection;
  }

  //G block = "---" NEWLINE { "@" ID NEWLINE | LINE | subBlock } "---" NEWLINE;
  //G subBlock = UPPERCASE_LINE NEWLINE { "@" ID NEWLINE | LINE | subBlock };
  Block _parseBlock(bool parseSubBlock) {
    var block = new Block(this);
    block.srcLine = this._i;
    if (!parseSubBlock) this._next(); // skip "---"
    var tokens = this._line.split(' ');
    for (var k = 0; k < tokens.length; k++) {
      if (k == 0)
        block.type = tokens[k];
      else if (tokens[k].startsWith('@'))
        block.label = tokens[k];
      else
        block.title += tokens[k] + ' ';
    }
    block.title = block.title.trim();
    this._next();
    BlockPart part = new BlockPart();
    part.name = 'global';
    block.parts.add(part);
    while (this._line != '---' && this._line != '§END') {
      if (this._line.startsWith('@')) {
        part = new BlockPart();
        block.parts.add(part);
        part.name = this._line.substring(1).trim();
        this._next();
      } else if (this._line.length >= 3 &&
          this._line.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          this._line.codeUnitAt(0) <= 'Z'.codeUnitAt(0) &&
          this._line.substring(0, 3) ==
              this._line.toUpperCase().substring(0, 3)) {
        if (parseSubBlock)
          break;
        else
          block.subBlocks.add(this._parseBlock(true));
      } else {
        part.lines.add(this._line);
        this._next();
      }
    }
    if (!parseSubBlock) {
      if (this._line == '---')
        this._next();
      else
        this._error(
          'block started in line ' +
              block.srcLine.toString() +
              ' must end with ---',
        );
    }
    block.process();
    return block;
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
  MBCL_LevelItem parseParagraph(String raw, [MBCL_LevelItem? ex = null]) {
    // skip empty paragraphs
    if (raw.trim().length == 0)
      return new MBCL_LevelItem(MBCL_LevelItemType.Text);
    // create lexer
    var lexer = new Lexer();
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.pushSource('', raw);
    lexer.setTerminals(['**', '#.', '-)']);
    var paragraph = new MBCL_LevelItem(MBCL_LevelItemType.Paragraph);
    while (lexer.isNotEND())
      paragraph.items.add(this._parseParagraph_part(lexer, ex));
    return paragraph;
  }

  MBCL_LevelItem _parseParagraph_part(Lexer lexer, MBCL_LevelItem? exercise) {
    if (lexer.getToken().col == 1 &&
        (lexer.isTER('-') || lexer.isTER('#.') || lexer.isTER('-)'))) {
      // itemize or enumerate
      return this._parseItemize(lexer, exercise);
    } else if (lexer.isTER('**')) {
      // bold text
      return this._parseBoldText(lexer, exercise);
    } else if (lexer.isTER('*')) {
      // italic text
      return this._parseItalicText(lexer, exercise);
    } else if (lexer.isTER('\$')) {
      // inline math
      return this._parseInlineMath(lexer, exercise);
    } else if (lexer.isTER('@')) {
      // reference
      return this._parseReference(lexer);
    } else if (exercise != null && lexer.isTER('#')) {
      // input element(s)
      return this._parseInputElements(lexer, exercise);
    } else if (exercise != null &&
        lexer.getToken().col == 1 &&
        (lexer.isTER('[') || lexer.isTER('('))) {
      // single or multiple choice answer
      return this._parseSingleOrMultipleChoice(lexer, exercise);
    } else if (lexer.isTER('\n')) {
      // line feed
      var isNewParagraph = lexer.getToken().col == 1;
      lexer.next();
      if (isNewParagraph)
        return new MBCL_LevelItem(MBCL_LevelItemType.LineFeed);
      else
        return new MBCL_LevelItem(MBCL_LevelItemType.Text);
    } else if (lexer.isTER('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return this._parseTextProperty(lexer, exercise);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      var text = new MBCL_LevelItem(MBCL_LevelItemType.Text);
      text.text = lexer.getToken().token;
      lexer.next();
      return text;
    }
  }

  MBCL_LevelItem _parseItemize(Lexer lexer, MBCL_LevelItem? exercise) {
    // '-' for itemize; '#.' for enumerate; '-)' for alpha enumerate
    var typeStr = lexer.getToken().token;
    MBCL_LevelItemType type = MBCL_LevelItemType.Itemize;
    switch (typeStr) {
      case '-':
        type = MBCL_LevelItemType.Itemize;
        break;
      case '#.':
        type = MBCL_LevelItemType.Enumerate;
        break;
      case '-)':
        type = MBCL_LevelItemType.EnumerateAlpha;
        break;
    }
    var itemize = new MBCL_LevelItem(type);
    while (lexer.getToken().col == 1 && lexer.isTER(typeStr)) {
      lexer.next();
      var span = new MBCL_LevelItem(MBCL_LevelItemType.Span);
      itemize.items.add(span);
      while (lexer.isNotNEWLINE() && lexer.isNotEND())
        span.items.add(this._parseParagraph_part(lexer, exercise));
      if (lexer.isNEWLINE()) lexer.NEWLINE();
    }
    return itemize;
  }

  MBCL_LevelItem _parseBoldText(Lexer lexer, MBCL_LevelItem? exercise) {
    lexer.next();
    var bold = new MBCL_LevelItem(MBCL_LevelItemType.BoldText);
    while (lexer.isNotTER('**') && lexer.isNotEND())
      bold.items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER('**')) lexer.next();
    return bold;
  }

  MBCL_LevelItem _parseItalicText(Lexer lexer, MBCL_LevelItem? exercise) {
    lexer.next();
    var italic = new MBCL_LevelItem(MBCL_LevelItemType.ItalicText);
    while (lexer.isNotTER('*') && lexer.isNotEND())
      italic.items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER('*')) lexer.next();
    return italic;
  }

  MBCL_LevelItem _parseInlineMath(Lexer lexer, MBCL_LevelItem? exercise) {
    lexer.next();
    var inlineMath = new MBCL_LevelItem(MBCL_LevelItemType.InlineMath);
    while (lexer.isNotTER('\$') && lexer.isNotEND()) {
      var tk = lexer.getToken().token;
      var isId = lexer.getToken().type == LexerTokenType.ID;
      lexer.next();
      // TODO: reactivate the following!
      /*if (isId && exercise != null && exercise.variables.containsKey(tk)) {
        var v = new MBCL_Exercise_Text_Variable();
        v.variableId = tk;
        inlineMath.items.add(v);
      } else*/
      {
        var text = new MBCL_LevelItem(MBCL_LevelItemType.Text);
        text.text = tk;
        inlineMath.items.add(text);
      }
    }
    if (lexer.isTER('\$')) lexer.next();
    return inlineMath;
  }

  MBCL_LevelItem _parseReference(Lexer lexer) {
    lexer.next();
    var ref = new MBCL_LevelItem(MBCL_LevelItemType.Reference);
    if (lexer.isID()) {
      ref.label = lexer.getToken().token;
      lexer.next();
    }
    return ref;
  }

  MBCL_LevelItem _parseInputElements(Lexer lexer, MBCL_LevelItem exercise) {
    lexer.next();
    var id = '';
    var input = new MBCL_LevelItem(MBCL_LevelItemType.ExerciseInputField);
    input.id = 'input' + this._createUniqueId().toString();
    var exerciseData = exercise.exerciseData as MBCL_ExerciseData;
    if (lexer.isID()) {
      id = lexer.ID();
      if (exerciseData.variables.containsKey(id)) {
        var v = exerciseData.variables[id] as MBCL_Exercise_VariableType;
        input.id = id;
        switch (v) {
          case MBCL_Exercise_VariableType.Int:
            input.id = MBCL_Exercise_Text_Input_Type.Int.name;
            break;
          case MBCL_Exercise_VariableType.IntSet:
            input.id = MBCL_Exercise_Text_Input_Type.IntSet.name;
            break;
          case MBCL_Exercise_VariableType.Real:
            input.id = MBCL_Exercise_Text_Input_Type.Real.name;
            break;
          case MBCL_Exercise_VariableType.Complex:
            input.id = MBCL_Exercise_Text_Input_Type.ComplexNormal.name;
            break;
          case MBCL_Exercise_VariableType.ComplexSet:
            input.id = MBCL_Exercise_Text_Input_Type.ComplexSet.name;
            break;
          case MBCL_Exercise_VariableType.Matrix:
            input.id = MBCL_Exercise_Text_Input_Type.Matrix.name;
            break;
          default:
            exercise.error += 'UNIMPLEMENTED input type ' + v.name + '. ';
        }
      } else {
        exercise.error = 'there is no variable "' + id + '". ';
      }
    } else {
      exercise.error = 'no variable for input field given. ';
    }
    return input;
  }

  MBCL_LevelItem _parseSingleOrMultipleChoice(
    Lexer lexer,
    MBCL_LevelItem exercise,
  ) {
    return MBCL_LevelItem(MBCL_LevelItemType.Error, 'MC/SC is unimplemented!');
  }
  // TODO: reactivate the following method
  /*MBCL_LevelItem _parseSingleOrMultipleChoice(
    Lexer lexer,
    MBCL_LevelItem exercise,
  ) {
    var exerciseData = exercise.exerciseData as MBCL_ExerciseData;
    var isMultipleChoice = lexer.isTER('[');
    lexer.next();
    var staticallyCorrect = false;
    var varId = '';
    if (lexer.isTER('x')) {
      lexer.next();
      staticallyCorrect = true;
    } else if (lexer.isTER(':')) {
      lexer.next();
      if (lexer.isID()) {
        varId = lexer.ID();
        if (exerciseData.variables.containsKey(varId) == false)
          exercise.error = 'unknown variable ' + varId;
      } else {
        exercise.error = 'expected ID after :';
      }
    }
    MBCL_Exercise_Text_SingleOrMultiple_Choice? element = null;
    if (varId.length == 0)
      varId = exercise.addStaticBooleanVariable(staticallyCorrect);
    if (isMultipleChoice) {
      if (lexer.isTER(']'))
        lexer.next();
      else
        exercise.error = 'expected ]';
      element = new MBCL_Exercise_Text_Multiple_Choice();
    } else {
      if (lexer.isTER(')'))
        lexer.next();
      else
        exercise.error = 'expected )';
      element = new MBCL_Exercise_Text_Single_Choice();
    }
    var option = new MBCL_Exercise_Text_Single_or_Multi_Choice_Option();
    option.input_id = 'input' + this._createUniqueId().toString();
    option.variable = varId;
    element.items.add(option);
    var span = new MBCL_LevelItem(MBCL_LevelItemType.Span);
    option.text = span;
    while (lexer.isNotNEWLINE() && lexer.isNotEND())
      span.items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER('\n')) lexer.next();
    return element;
  }*/

  MBCL_LevelItem _parseTextProperty(Lexer lexer, MBCL_LevelItem? exercise) {
    // TODO: make sure, that errors are not too annoying...
    lexer.next();
    List<MBCL_LevelItem> items = [];
    while (lexer.isNotTER(']') && lexer.isNotEND())
      items.add(this._parseParagraph_part(lexer, exercise));
    if (lexer.isTER(']'))
      lexer.next();
    else
      return new MBCL_LevelItem(MBCL_LevelItemType.Error, 'expected ]');
    if (lexer.isTER('@'))
      lexer.next();
    else
      return new MBCL_LevelItem(MBCL_LevelItemType.Error, 'expected @');
    if (lexer.isID()) {
      var id = lexer.ID();
      if (id == 'bold') {
        var bold = new MBCL_LevelItem(MBCL_LevelItemType.BoldText);
        bold.items = items;
        return bold;
      } else if (id == 'italic') {
        var italic = new MBCL_LevelItem(MBCL_LevelItemType.ItalicText);
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        var color = new MBCL_LevelItem(MBCL_LevelItemType.Color);
        color.id = id.substring(5); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return new MBCL_LevelItem(
            MBCL_LevelItemType.Error, 'unknown property ' + id);
      }
    } else
      return new MBCL_LevelItem(
          MBCL_LevelItemType.Error, 'missing property name');
  }

  void _error(String message) {
    // TODO: include file path!
    throw new Exception('ERROR:' + (this._i + 1).toString() + ': ' + message);
  }
}

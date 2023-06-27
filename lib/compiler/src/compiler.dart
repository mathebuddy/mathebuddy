/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import '../../math-runtime/src/operand.dart';

import '../../mbcl/src/chapter.dart';
import '../../mbcl/src/course.dart';
import '../../mbcl/src/level_item.dart';
import '../../mbcl/src/level.dart';
import '../../mbcl/src/unit.dart';

import 'block_NEW.dart';
import 'course.dart';
import 'exercise.dart';
import 'help.dart';
import 'math.dart';
import 'references.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbl.html

class Compiler {
  //final Function(String) loadFile;
  final String Function(String) loadFile;
  String baseDirectory = '';

  int equationNumber = 1;

  MbclCourse? _course;
  MbclChapter? _chapter;
  MbclUnit? _unit;
  MbclLevel? _level;

  List<String> _srcLines = [];
  int _i = -1; // current line index (starting from 0)
  String _line = ''; // current line
  String _line2 = ''; // next line
  String _paragraph = '';

  int _uniqueIdCounter = 0;

  Compiler(this.loadFile);

  MbclCourse? getCourse() {
    return _course;
  }

  //void compile(String path, loadFile: (path: string) => string) {
  void compile(String path) {
    print("COMPILING FROM PATH '$path'");
    // extract base directory from path
    baseDirectory = extractDirname(path);
    // compile
    if (path.endsWith('course.mbl')) {
      // processing complete course
      compileCourse(path);
    } else if (path.endsWith('index.mbl')) {
      // processing only a course chapter
      _course = MbclCourse();
      _course?.debug = MbclCourseDebug.chapter;
      compileChapter(path);
    } else {
      // processing only a course level
      _course = MbclCourse();
      _course?.debug = MbclCourseDebug.level;
      _chapter = MbclChapter();
      _course?.chapters.add(_chapter as MbclChapter);
      compileLevel_NEW(path); // compileLevel(path);
    }
    // post processing
    postProcessCourse(_course as MbclCourse);
    // solve references
    ReferenceSolver rs = ReferenceSolver(_course as MbclCourse);
    rs.run();
  }

  //G course = courseTitle courseAuthor courseChapters;
  //G courseTitle = "TITLE" { ID } "\n";
  //G courseAuthor = "AUTHOR" { ID } "\n";
  //G courseChapters = "CHAPTERS" "\n" { courseChapter };
  //G courseChapter = "(" INT "," INT ")" ID { "!" ID } "\n";
  void compileCourse(String path) {
    // create a new course
    _course = MbclCourse();
    // get course description file source
    var src = loadFile(path);
    if (src.isEmpty) {
      _error(
        'Course description file "$path" does not exist or is empty.',
      );
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';

    for (var rowIdx = 0; rowIdx < lines.length; rowIdx++) {
      var line = lines[rowIdx];
      line = line.split('%')[0];
      if (line.trim().isEmpty) continue;
      if (state == 'global') {
        if (line.startsWith('TITLE')) {
          _course?.title = line.substring('TITLE'.length).trim();
        } else if (line.startsWith('AUTHOR')) {
          _course?.author = line.substring('AUTHOR'.length).trim();
        } else if (line.startsWith('CHAPTERS')) {
          state = 'chapter';
        } else {
          _error('Unexpected line "$line".');
        }
      } else if (state == 'chapter') {
        var lexer = Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.terminal('(');
        var posX = lexer.integer();
        lexer.terminal(',');
        var posY = lexer.integer();
        lexer.terminal(')');
        var directoryName = lexer.identifier();
        List<String> requirements = [];
        while (lexer.isTerminal('!')) {
          lexer.next();
          requirements.add(lexer.identifier());
        }
        lexer.end();
        // compile chapter
        var dirname = extractDirname(path);
        var chapterPath = '$dirname$directoryName/index.mbl';
        compileChapter(chapterPath);
        // set chapter meta data
        _chapter?.fileId = directoryName;
        _chapter?.posX = posX;
        _chapter?.posY = posY;
        _chapter?.requiresTmp.addAll(requirements);
      }
    }
    // build dependency graph
    for (var i = 0; i < (_course as MbclCourse).chapters.length; i++) {
      var chapter = _course?.chapters[i] as MbclChapter;
      for (var j = 0; j < chapter.requiresTmp.length; j++) {
        var r = chapter.requiresTmp[j];
        var requiredChapter = _course?.getChapterByFileID(r);
        if (requiredChapter == null) {
          _error('Unknown chapter "$r".');
        } else {
          chapter.requires.add(requiredChapter);
        }
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
    _chapter = MbclChapter();
    _course?.chapters.add(_chapter as MbclChapter);
    // get chapter index file source
    var src = loadFile(path);
    if (src.isEmpty) {
      _error('Chapter index file "$path" does not exist or is empty.');
      return;
    }
    // parse
    var lines = src.split('\n');
    var state = 'global';
    for (var rowIdx = 0; rowIdx < lines.length; rowIdx++) {
      var line = lines[rowIdx];
      line = line.split('%')[0];
      if (line.trim().isEmpty) continue;
      if (state == 'global' || line.startsWith('UNIT')) {
        if (line.startsWith('TITLE')) {
          _chapter?.title = line.substring('TITLE'.length).trim();
        } else if (line.startsWith('AUTHOR')) {
          _chapter?.author = line.substring('AUTHOR'.length).trim();
        } else if (line.startsWith('UNIT')) {
          // TODO: handle units!!
          var unitTitle = line.substring('UNIT'.length).trim();
          state = 'unit';
          _unit = MbclUnit();
          _unit?.title = unitTitle;
          _chapter?.units.add(_unit as MbclUnit);
        } else {
          _error('Unexpected line "$line".');
        }
      } else if (state == 'unit') {
        var lexer = Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.terminal('(');
        var posX = lexer.integer();
        lexer.terminal(',');
        var posY = lexer.integer();
        lexer.terminal(')');
        var fileName = lexer.identifier();
        List<String> requirements = [];
        while (lexer.isTerminal('!')) {
          lexer.next();
          requirements.add(lexer.identifier());
        }
        var iconData = '';
        if (lexer.isTerminal("ICON")) {
          lexer.next();
          var path = baseDirectory;
          while (lexer.getToken().type != LexerTokenType.end) {
            path += lexer.getToken().token.trim();
            lexer.next();
          }
          iconData = loadFile(path);
        }
        lexer.end();
        // compile level
        var dirname = extractDirname(path);
        var levelPath = '$dirname$fileName.mbl';
        compileLevel_NEW(levelPath); // compileLevel(levelPath);
        _unit?.levels.add(_level as MbclLevel);
        // set chapter meta data
        _level?.fileId = fileName;
        _level?.posX = posX;
        _level?.posY = posY;
        _level?.requiresTmp.addAll(requirements);
        _level?.iconData = iconData;
      }
    }
    // build dependency graph
    for (var i = 0; i < (_chapter as MbclChapter).levels.length; i++) {
      var level = _chapter?.levels[i] as MbclLevel;
      for (var j = 0; j < level.requiresTmp.length; j++) {
        var r = level.requiresTmp[j];
        var requiredLevel = _chapter?.getLevelByFileID(r);
        if (requiredLevel == null) {
          _error('Unknown dependency-level "$r".');
        } else {
          level.requires.add(requiredLevel);
        }
      }
    }
  }

  //G level = TODO
  void compileLevel_NEW(String path) {
    equationNumber = 1;
    // create a new level
    _level = MbclLevel();
    _chapter?.levels.add(_level as MbclLevel);
    // get level source
    var src = loadFile(path);
    if (src.isEmpty) {
      _error('Level file $path does not exist or is empty.');
    }
    // set source, split it into lines, trim these lines and
    // filter out comments of each line
    _srcLines = src.split('\n');
    for (var k = 0; k < _srcLines.length; k++) {
      var line = _srcLines[k];
      var tokens = line.split('%');
      _srcLines[k] = tokens[0];
    }
    // init lexer
    _i = -1;
    _next();

    //  TODO: move (most) the following code to file block_NEW.dart

    // parse
    var depthList = List<Block_NEW?>.filled(0, null,
        growable: true); // TODO: write comment!!
    var rootBlock = Block_NEW("ROOT", 0, -1);
    depthList.length = 1;
    depthList[0] = rootBlock;
    var currentBlock = rootBlock;

    while (_line != '§END') {
      var trimmed = _line.trim();
      /*if (trimmed.isEmpty) {
        _next();
        continue;
      }*/
      var spaces = 0;
      for (var k = 0; k < _line.length; k++) {
        if (_line[k] == ' ') {
          spaces++;
        } else if (_line[k] == '\t') {
          spaces += 4;
        } else {
          break;
        }
      }
      int indentation = spaces ~/ 4;
      indentation += 1; // add one for root element

      var keyword = "";
      // A keyword is fully uppercase; also "_", "-" and "*" are allowed
      // characters.
      // If "=" is followed (directly or after some spaces), we are actually
      // parsing an attribute and NOT a keyword.
      for (int i = 0; i < trimmed.length; i++) {
        var ch = trimmed[i];
        var isValid = ch.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                ch.codeUnitAt(0) <= 'Z'.codeUnitAt(0) ||
            (i > 0 && ch == '_') ||
            (i > 0 && ch == '-') ||
            (i > 0 && ch == '*');
        if (isValid) {
          keyword += ch;
        } else {
          for (int j = i; j < trimmed.length; j++) {
            if (ch == " " || ch == "\t") continue;
            if (ch == "=") {
              // attribute!
              keyword = "";
            }
          }
          // require at least length 3
          if (keyword.length < 3) {
            keyword = "";
          }
          break;
        }
      }

      if (keyword.isNotEmpty) {
        if ((spaces % 4) != 0) {
          _error('bad spacing before "$keyword".');
        }
        var srcLine = _i + 1;
        currentBlock = Block_NEW(keyword, indentation, srcLine);
        depthList.length = indentation + 1;
        var parent = depthList[indentation - 1];
        if (parent == null) {
          _error('bad indentation before "$keyword".');
        } else {
          parent.children.add(currentBlock);
        }
        depthList[indentation] = currentBlock;
        // parse TITLE [ "@" ID ]
        var tokens = trimmed.substring(keyword.length).split("@");
        if (tokens.isNotEmpty) {
          currentBlock.title = tokens[0].trim();
          if (tokens.length >= 2) {
            currentBlock.label = tokens[1].trim();
            if (currentBlock.label.contains(' ')) {
              _error('bad label (must be one word)');
            }
          }
        }
      } else {
        // not a keyword
        if (trimmed.isNotEmpty && indentation <= currentBlock.indent) {
          currentBlock = depthList[indentation - 1]!;
        }
        var line = _line.replaceAll('\t', '    ');
        var isAttribute = false;

        if (line.contains("=")) {
          isAttribute = true;
          var l = Lexer();
          l.pushSource("", line);
          try {
            var key = l.uppercaseIdentifier();
            var value = "";
            l.terminal("=");
            while (l.isNotEnd()) {
              value += l.getToken().token;
              l.next();
            }
            l.end();
            // parsing of attribute succeeded
            currentBlock.attributes[key] = value;
          } catch (e) {
            isAttribute = false;
          }
          if (isAttribute && currentBlock.children.isNotEmpty) {
            _error('Attributes must be first. '
                'Hint: Move line ${_i + 1} to line ${currentBlock.srcLine + 1}');
          }
        }
        if (isAttribute == false) {
          var b = Block_NEW("DEFAULT", indentation, _i + 1);
          b.data = '$line\n';
          currentBlock.children.add(b);
        }
      }
      _next();
    }
    rootBlock.postProcess();
    //print(rootBlock);
    rootBlock.parse(this, _level!, null, 0, null);
  }

  // //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };
  // void compileLevel(String path) {
  //   equationNumber = 1;
  //   // create a new level
  //   _level = MbclLevel();
  //   _chapter?.levels.add(_level as MbclLevel);
  //   // get level source
  //   var src = loadFile(path);
  //   if (src.isEmpty) {
  //     _error('Level file $path does not exist or is empty.');
  //   }
  //   // set source, split it into lines, trim these lines and
  //   // filter out comments of each line
  //   _srcLines = src.split('\n');
  //   for (var k = 0; k < _srcLines.length; k++) {
  //     var line = _srcLines[
  //         k]; // .trim(); TODO: OK to entirely remove trimming?? NOT allowed for itemize
  //     var tokens = line.split('%');
  //     _srcLines[k] = tokens[0];
  //   }
  //   // init lexer
  //   _i = -1;
  //   _next();
  //   // parse
  //   while (_line != '§END') {
  //     if (_line2.startsWith('#####')) {
  //       _pushParagraph();
  //       _parseLevelTitle();
  //     } else if (_line2.startsWith('==')) {
  //       _pushParagraph();
  //       _level?.items.add(_parseSectionTitle());
  //     } else if (_line2.startsWith('-----')) {
  //       _pushParagraph();
  //       _level?.items.add(_parseSubSectionTitle());
  //     } else if (_line.startsWith('---')) {
  //       _pushParagraph();
  //       var block = _parseBlock(false, _i);
  //       _level?.items.addAll(block.levelItems);
  //     } else {
  //       _paragraph += '$_line\n';
  //       _next();
  //     }
  //   }
  //   _pushParagraph();
  // }

  int createUniqueId() {
    return _uniqueIdCounter++;
  }

  void _pushParagraph() {
    if (_paragraph.trim().isNotEmpty) {
      _level?.items.addAll(parseParagraph(_paragraph));
      _paragraph = '';
    }
  }

  void _next() {
    _i++;
    if (_i < _srcLines.length) {
      _line = _srcLines[_i];
    } else {
      _line = '§END';
    }
    if (_i + 1 < _srcLines.length) {
      _line2 = _srcLines[_i + 1];
    } else {
      _line2 = '§END';
    }
  }

  // //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;
  // void _parseLevelTitle() {
  //   var tokens = _line.split('@');
  //   _level?.title = tokens[0].trim();
  //   if (tokens.length > 1) {
  //     _level?.label = tokens[1].trim();
  //   }
  //   _next(); // skip document title
  //   _next(); // skip '#####..'
  // }

  // //G sectionTitle = { CHAR } "@" { ID } NEWLINE "==.." { "#" } NEWLINE;
  // MbclLevelItem _parseSectionTitle() {
  //   var section = MbclLevelItem(MbclLevelItemType.section, _i);
  //   var tokens = _line.split('@');
  //   section.text = tokens[0].trim();
  //   if (tokens.length > 1) {
  //     section.label = tokens[1].trim();
  //   }
  //   _next(); // skip section title
  //   _next(); // skip '==..'
  //   return section;
  // }

  // //G subSectionTitle = { CHAR } "@" { ID } NEWLINE "-----.." { "#" } NEWLINE;
  // MbclLevelItem _parseSubSectionTitle() {
  //   var subSection = MbclLevelItem(MbclLevelItemType.subSection, _i);
  //   var tokens = _line.split('@');
  //   subSection.text = tokens[0].trim();
  //   if (tokens.length > 1) {
  //     subSection.label = tokens[1].trim();
  //   }
  //   _next(); // skip subSection title
  //   _next(); // skip '-----..'
  //   return subSection;
  // }

  // //G block = "---" NEWLINE { "@" ID NEWLINE | LINE | subBlock } "---" NEWLINE;
  // //G subBlock = UPPERCASE_LINE NEWLINE { "@" ID NEWLINE | LINE | subBlock };
  // Block _parseBlock(bool parseSubBlock, int srcLine) {
  //   var block = Block(this);
  //   block.srcLine = srcLine;
  //   if (!parseSubBlock) _next(); // skip "---"
  //   var tokens = _line.split(' ');
  //   for (var k = 0; k < tokens.length; k++) {
  //     if (k == 0) {
  //       block.type = tokens[k];
  //     } else if (tokens[k].startsWith('@')) {
  //       block.label = tokens[k].substring(1);
  //     } else {
  //       block.title += '${tokens[k]} ';
  //     }
  //   }
  //   block.title = block.title.trim();
  //   _next();
  //   BlockPart part = BlockPart();
  //   part.name = 'global';
  //   block.addBlockPart(part);
  //   while (_line.startsWith('---') == false && _line != '§END') {
  //     if (_line.startsWith('@')) {
  //       part = BlockPart();
  //       block.addBlockPart(part);
  //       part.name = _line.substring(1).trim();
  //       _next();
  //     } else if (_line.length >= 3 &&
  //         _line.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
  //         _line.codeUnitAt(0) <= 'Z'.codeUnitAt(0) &&
  //         _line.substring(0, 3) == _line.toUpperCase().substring(0, 3)) {
  //       if (parseSubBlock) {
  //         if (_line.startsWith('END')) {
  //           _next();
  //         }
  //         break;
  //       } else {
  //         block.addSubBlock(_parseBlock(true, srcLine));
  //       }
  //     } else {
  //       part.lines.add(_line);
  //       _next();
  //     }
  //   }
  //   if (!parseSubBlock) {
  //     if (_line.startsWith('---')) {
  //       _next();
  //     } else {
  //       _error(
  //         'block started in line ${block.srcLine} must end with ---',
  //       );
  //     }
  //   }
  //   block.process();
  //   return block;
  // }

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
  // TODO: RENAME METHOD!!
  List<MbclLevelItem> parseParagraph(String raw, [MbclLevelItem? ex]) {
    // skip empty paragraphs
    if (raw.trim().isEmpty) {
      return [MbclLevelItem(MbclLevelItemType.paragraph, _i)];
    }
    // create lexer
    var lexer = Lexer();
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.pushSource('', raw);
    lexer.setTerminals(['**', '#.', '-)']);
    List<MbclLevelItem> res = [];
    while (lexer.isNotEnd()) {
      var part = _parseParagraphPart(lexer, ex);
      switch (part.type) {
        case MbclLevelItemType.itemize:
        case MbclLevelItemType.enumerate:
        case MbclLevelItemType.enumerateAlpha:
        case MbclLevelItemType.singleChoice:
        case MbclLevelItemType.multipleChoice:
          res.add(part);
          break;
        case MbclLevelItemType.lineFeed:
          res.add(MbclLevelItem(MbclLevelItemType.paragraph, _i));
          break;
        default:
          if (res.isNotEmpty && res.last.type == MbclLevelItemType.paragraph) {
            res.last.items.add(part);
          } else {
            var paragraph = MbclLevelItem(MbclLevelItemType.paragraph, _i);
            res.add(paragraph);
            paragraph.items.add(part);
          }
      }
    }
    // remove unnecessary line feeds at end
    while (res.isNotEmpty &&
        res.last.type == MbclLevelItemType.paragraph &&
        res.last.items.isEmpty) {
      res.removeLast();
    }
    return res;
  }

  MbclLevelItem _parseParagraphPart(Lexer lexer, MbclLevelItem? exercise) {
    if (lexer.getToken().col == 1 &&
        (lexer.isTerminal('-') ||
            lexer.isTerminal('#.') ||
            lexer.isTerminal('-)'))) {
      // itemize or enumerate
      return _parseItemize(lexer, exercise);
    } else if (lexer.isTerminal('**')) {
      // bold text
      return _parseBoldText(lexer, exercise);
    } else if (lexer.isTerminal('*')) {
      // italic text
      return _parseItalicText(lexer, exercise);
    } else if (lexer.isTerminal('\$')) {
      // inline math
      return parseInlineMath(lexer, exercise);
    } else if (lexer.isTerminal('@')) {
      // reference
      return _parseReference(lexer);
    } else if (exercise != null && lexer.isTerminal('#')) {
      // input element(s)
      return _parseInputElements(lexer, exercise);
    } else if (exercise != null &&
        lexer.getToken().col == 1 &&
        (lexer.isTerminal('[') || lexer.isTerminal('('))) {
      // single or multiple choice answer
      return _parseSingleOrMultipleChoice(lexer, exercise);
    } else if (lexer.isTerminal('\n')) {
      // line feed
      var isNewParagraph = lexer.getToken().col == 1;
      lexer.next();
      if (isNewParagraph) {
        return MbclLevelItem(MbclLevelItemType.lineFeed, _i);
      } else {
        return MbclLevelItem(MbclLevelItemType.text, _i);
      }
    } else if (lexer.isTerminal('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return _parseTextProperty(lexer, exercise);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      var text = MbclLevelItem(MbclLevelItemType.text, _i);
      text.text = lexer.getToken().token;
      lexer.next();
      return text;
    }
  }

  MbclLevelItem _parseItemize(Lexer lexer, MbclLevelItem? exercise) {
    // '-' for itemize; '#.' for enumerate; '-)' for alpha enumerate
    var typeStr = lexer.getToken().token;
    MbclLevelItemType type = MbclLevelItemType.itemize;
    switch (typeStr) {
      case '-':
        type = MbclLevelItemType.itemize;
        break;
      case '#.':
        type = MbclLevelItemType.enumerate;
        break;
      case '-)':
        type = MbclLevelItemType.enumerateAlpha;
        break;
    }
    var itemize = MbclLevelItem(type, _i);
    int rowIdx;
    while (lexer.getToken().col == 1 &&
        lexer.isTerminal(typeStr) &&
        lexer.isNotEnd()) {
      rowIdx = lexer.getToken().row;
      lexer.next();
      var span = MbclLevelItem(MbclLevelItemType.span, _i);
      itemize.items.add(span);
      while (lexer.isNotNewline() && lexer.isNotEnd()) {
        span.items.add(_parseParagraphPart(lexer, exercise));
      }
      if (lexer.isNewline()) {
        lexer.newline();
      }
      // parse all consecutive lines, that belong to the item. These lines
      // are indicated by preceding spaces.
      while (lexer.getToken().col > 1 && lexer.isNotEnd()) {
        if (lexer.getToken().row - rowIdx > 1) {
          span.items.add(MbclLevelItem(MbclLevelItemType.text, _i, '\n'));
        }
        rowIdx = lexer.getToken().row;
        while (lexer.isNotNewline() && lexer.isNotEnd()) {
          var p = _parseParagraphPart(lexer, exercise);
          span.items.add(p);
        }
        if (lexer.isNewline()) {
          lexer.newline();
        }
      }
    }
    return itemize;
  }

  MbclLevelItem _parseBoldText(Lexer lexer, MbclLevelItem? exercise) {
    lexer.next();
    var bold = MbclLevelItem(MbclLevelItemType.boldText, _i);
    while (lexer.isNotTerminal('**') && lexer.isNotEnd()) {
      bold.items.add(_parseParagraphPart(lexer, exercise));
    }
    if (lexer.isTerminal('**')) lexer.next();
    return bold;
  }

  MbclLevelItem _parseItalicText(Lexer lexer, MbclLevelItem? exercise) {
    lexer.next();
    var italic = MbclLevelItem(MbclLevelItemType.italicText, _i);
    while (lexer.isNotTerminal('*') && lexer.isNotEnd()) {
      italic.items.add(_parseParagraphPart(lexer, exercise));
    }
    if (lexer.isTerminal('*')) lexer.next();
    return italic;
  }

  MbclLevelItem _parseReference(Lexer lexer) {
    lexer.next(); // skip '@'
    var ref = MbclLevelItem(MbclLevelItemType.reference, _i);
    var label = '';
    if (lexer.isIdentifier()) {
      label = lexer.getToken().token;
      lexer.next();
    }
    if (lexer.isTerminal(":")) {
      label += lexer.getToken().token;
      lexer.next();
    }
    if (lexer.isIdentifier()) {
      label += lexer.getToken().token;
      lexer.next();
    }
    ref.label = label;
    return ref;
  }

  MbclLevelItem _parseInputElements(Lexer lexer, MbclLevelItem exercise) {
    lexer.next();
    var inputField = MbclLevelItem(MbclLevelItemType.inputField, _i);
    var data = MbclInputFieldData();
    inputField.inputFieldData = data;
    inputField.id = 'input${createUniqueId()}';
    var exerciseData = exercise.exerciseData as MbclExerciseData;
    exerciseData.inputFields[inputField.id] = data;
    if (lexer.isIdentifier()) {
      data.variableId = lexer.identifier();
      if (exerciseData.variables.contains(data.variableId)) {
        var opType = OperandType.values
            .byName(exerciseData.smplOperandType[data.variableId] as String);
        //input.id = data.variableId;
        switch (opType) {
          case OperandType.int:
            data.type = MbclInputFieldType.int;
            break;
          case OperandType.rational:
            data.type = MbclInputFieldType.rational;
            break;
          case OperandType.real:
            data.type = MbclInputFieldType.real;
            break;
          case OperandType.complex:
            data.type = MbclInputFieldType.complexNormal;
            break;
          case OperandType.matrix:
            data.type = MbclInputFieldType.matrix;
            break;
          case OperandType.set:
            // TODO: intSet, realSet, termSet, complexIntSet, ...
            data.type = MbclInputFieldType.complexIntSet;
            break;
          default:
            exercise.error += ' UNIMPLEMENTED input type ${opType.name}. ';
        }
      } else {
        exercise.error += ' There is no variable "${data.variableId}". ';
      }
    } else {
      exercise.error += ' No variable for input field given. ';
    }
    return inputField;
  }

  MbclLevelItem _parseSingleOrMultipleChoice(
    Lexer lexer,
    MbclLevelItem exercise,
  ) {
    var exerciseData = exercise.exerciseData as MbclExerciseData;
    var isMultipleChoice = lexer.isTerminal('[');
    lexer.next();
    var staticallyCorrect = false;
    var varId = '';
    if (lexer.isTerminal('x')) {
      lexer.next();
      staticallyCorrect = true;
    } else if (lexer.isTerminal(':')) {
      lexer.next();
      if (lexer.isIdentifier()) {
        varId = lexer.identifier();
        if (exerciseData.variables.contains(varId) == false) {
          exercise.error += ' Unknown variable "$varId".';
        }
      } else {
        exercise.error += ' Expected ID after ":".';
      }
    }
    MbclLevelItem root = MbclLevelItem(MbclLevelItemType.multipleChoice, _i);
    if (varId.isEmpty) {
      varId = addStaticBooleanVariable(exerciseData, staticallyCorrect);
    }
    if (isMultipleChoice) {
      if (lexer.isTerminal(']')) {
        lexer.next();
      } else {
        exercise.error += ' Expected "]".';
      }
      root.type = MbclLevelItemType.multipleChoice;
    } else {
      if (lexer.isTerminal(')')) {
        lexer.next();
      } else {
        exercise.error += ' Expected ")".';
      }
      root.type = MbclLevelItemType.singleChoice;
    }

    var inputField = MbclLevelItem(MbclLevelItemType.inputField, _i);
    var inputFieldData = MbclInputFieldData();
    inputField.inputFieldData = inputFieldData;
    inputField.id = 'input${createUniqueId()}';
    inputFieldData.type = MbclInputFieldType.bool;
    inputFieldData.variableId = varId;
    root.items.add(inputField);
    exerciseData.inputFields[inputField.id] = inputFieldData;

    /*
    var option = MbclLevelItem(MbclLevelItemType.multipleChoiceOption);
    var data = MbclSingleOrMultipleChoiceOptionData();
    option.singleOrMultipleChoiceOptionData = data;
    if (root.type == MbclLevelItemType.singleChoice) {
      option.type = MbclLevelItemType.singleChoiceOption;
    }
    data.inputId = 'input${createUniqueId()}';
    data.variableId = varId;
    root.items.add(option);*/

    var span = MbclLevelItem(MbclLevelItemType.span, _i);
    inputField.items.add(span);
    while (lexer.isNotNewline() && lexer.isNotEnd()) {
      span.items.add(_parseParagraphPart(lexer, exercise));
    }
    if (lexer.isTerminal('\n')) lexer.next();
    return root;
  }

  MbclLevelItem _parseTextProperty(Lexer lexer, MbclLevelItem? exercise) {
    // TODO: make sure, that errors are not too annoying...
    lexer.next();
    List<MbclLevelItem> items = [];
    while (lexer.isNotTerminal(']') && lexer.isNotEnd()) {
      items.add(_parseParagraphPart(lexer, exercise));
    }
    if (lexer.isTerminal(']')) {
      lexer.next();
    } else {
      return MbclLevelItem(MbclLevelItemType.error, _i, ' Expected "]".');
    }
    if (lexer.isTerminal('@')) {
      lexer.next();
    } else {
      return MbclLevelItem(MbclLevelItemType.error, _i, ' Expected "@".');
    }
    if (lexer.isIdentifier()) {
      var id = lexer.identifier();
      if (id == 'bold') {
        var bold = MbclLevelItem(MbclLevelItemType.boldText, _i);
        bold.items = items;
        return bold;
      } else if (id == 'italic') {
        var italic = MbclLevelItem(MbclLevelItemType.italicText, _i);
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        var color = MbclLevelItem(MbclLevelItemType.color, _i);
        color.id = id.substring(5); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return MbclLevelItem(
            MbclLevelItemType.error, _i, ' Unknown property $id.');
      }
    } else {
      return MbclLevelItem(
          MbclLevelItemType.error, _i, ' Missing property name. ');
    }
  }

  void _error(String message) {
    // TODO: include file path!
    throw Exception('ERROR:${_i + 1}: $message');
  }
}

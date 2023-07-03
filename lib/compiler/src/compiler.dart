/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:slex/slex.dart';

import '../../mbcl/src/chapter.dart';
import '../../mbcl/src/course.dart';
import '../../mbcl/src/level.dart';
import '../../mbcl/src/unit.dart';

import 'block.dart';
import 'course.dart';
import 'help.dart';
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

  bool disableBlockTitles = false;

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
      if (state == 'global' && line == 'NO_BLOCK_TITLES=true') {
        disableBlockTitles = true;
      } else if (state == 'global' || line.startsWith('UNIT')) {
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
        double posX = 0.0;
        if (lexer.isRealNumber()) {
          posX = lexer.realNumber().toDouble();
        } else {
          posX = lexer.integer().toDouble();
        }
        lexer.terminal(',');
        double posY = 0.0;
        if (lexer.isRealNumber()) {
          posY = lexer.realNumber().toDouble();
        } else {
          posY = lexer.integer().toDouble();
        }
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
        _level?.posX = posX.toDouble();
        _level?.posY = posY.toDouble();
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
    if (disableBlockTitles) {
      _level!.disableBlockTitles = true;
    }
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
    var depthList =
        List<Block?>.filled(0, null, growable: true); // TODO: write comment!!
    var rootBlock = Block(_level!, "ROOT", 0, -1);
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
        currentBlock = Block(_level!, keyword, indentation, srcLine);
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
          var b = Block(_level!, "DEFAULT", indentation, _i + 1);
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

  // TODO: grammar //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };

  int createUniqueId() {
    return _uniqueIdCounter++;
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

  // TODO: grammar //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;

  //// TODO: grammar //G sectionTitle = { CHAR } "@" { ID } NEWLINE "==.." { "#" } NEWLINE;

  //// TODO: grammar //G subSectionTitle = { CHAR } "@" { ID } NEWLINE "-----.." { "#" } NEWLINE;

  // // TODO: grammar //G block = "---" NEWLINE { "@" ID NEWLINE | LINE | subBlock } "---" NEWLINE;
  // //G subBlock = UPPERCASE_LINE NEWLINE { "@" ID NEWLINE | LINE | subBlock };

  /*G // TODO: grammar
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

  void _error(String message) {
    // TODO: include file path!
    throw Exception('ERROR:${_i + 1}: $message');
  }
}

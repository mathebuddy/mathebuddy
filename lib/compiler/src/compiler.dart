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
import 'level.dart';
import 'references.dart';

// TODO: grammar //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };
// TODO: grammar //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;
//// TODO: grammar //G sectionTitle = { CHAR } "@" { ID } NEWLINE "==.." { "#" } NEWLINE;
//// TODO: grammar //G subSectionTitle = { CHAR } "@" { ID } NEWLINE "-----.." { "#" } NEWLINE;
// // TODO: grammar //G block = "---" NEWLINE { "@" ID NEWLINE | LINE | subBlock } "---" NEWLINE;
// //G subBlock = UPPERCASE_LINE NEWLINE { "@" ID NEWLINE | LINE | subBlock };

/// The compiler that translates a set of MBL files into a single MBCL files.
/// The language specification can be found here:
/// https://mathebuddy.github.io/mathebuddy/doc/mbl.html
class Compiler {
  /// The load function that provides the contents of a text file, given by
  /// a file path.
  final String Function(String) loadFile;

  /// The base directory.
  String baseDirectory = '';

  /// The current equation number (reset per level).
  int equationNumberCounter = 1;

  /// The currently processed course.
  MbclCourse? course;

  /// The currently processed chapter.
  MbclChapter? chapter;

  /// The currently processed unit.
  MbclUnit? unit;

  /// The currently processed level.
  MbclLevel? level;

  /// The source code lines of the current input file.
  List<String> srcLines = [];

  /// The index of the current line (starting from 0).
  int currentLineIdx = -1;

  /// The current line contents.
  String currentLine = '';

  /// Whether block titles are invisible.
  bool disableBlockTitles = false;

  /// A counter variable to generate unique IDs.
  int uniqueIdCounter = 0;

  /// Constructor
  Compiler(this.loadFile);

  /// Gets the current course.
  MbclCourse? getCourse() {
    return course;
  }

  /// Starts compilation of an MBL file at [path].
  void compile(String path) {
    print("COMPILING FROM PATH '$path'");
    // extract base directory from path
    baseDirectory = extractDirname(path);
    // compile
    if (path.endsWith('course.mbl')) {
      // processing complete course
      compileCourse(path);
    } else if (path.endsWith('index.mbl')) {
      // processing a single course chapter
      course = MbclCourse();
      course?.debug = MbclCourseDebug.chapter;
      compileChapter(path);
    } else {
      // processing a single course level
      course = MbclCourse();
      course!.debug = MbclCourseDebug.level;
      chapter = MbclChapter();
      course!.chapters.add(chapter!);
      unit = MbclUnit();
      chapter!.units.add(unit!);
      compileLevel(path); // compileLevel(path);
      unit!.levels.add(chapter!.levels[0]);
    }
    // post processing
    postProcessCourse(course as MbclCourse);
    // resolve references
    ReferenceSolver rs = ReferenceSolver(course as MbclCourse);
    rs.run();
  }

  //G course = courseTitle courseAuthor courseChapters;
  //G courseTitle = "TITLE" { ID } "\n";
  //G courseAuthor = "AUTHOR" { ID } "\n";
  //G courseChapters = "CHAPTERS" "\n" { courseChapter };
  //G courseChapter = "(" INT "," INT ")" ID { "!" ID } "\n";
  void compileCourse(String path) {
    // create a new course
    course = MbclCourse();
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
          course?.title = line.substring('TITLE'.length).trim();
        } else if (line.startsWith('AUTHOR')) {
          course?.author = line.substring('AUTHOR'.length).trim();
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
        chapter?.fileId = directoryName;
        chapter?.posX = posX;
        chapter?.posY = posY;
        chapter?.requiresTmp.addAll(requirements);
      }
    }
    // build dependency graph
    for (var i = 0; i < (course as MbclCourse).chapters.length; i++) {
      var chapter = course?.chapters[i] as MbclChapter;
      for (var j = 0; j < chapter.requiresTmp.length; j++) {
        var r = chapter.requiresTmp[j];
        var requiredChapter = course?.getChapterByFileID(r);
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
    chapter = MbclChapter();
    course?.chapters.add(chapter as MbclChapter);
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
          chapter?.title = line.substring('TITLE'.length).trim();
        } else if (line.startsWith('AUTHOR')) {
          chapter?.author = line.substring('AUTHOR'.length).trim();
        } else if (line.startsWith('UNIT')) {
          // TODO: handle units!!
          var unitTitle = line.substring('UNIT'.length).trim();
          state = 'unit';
          unit = MbclUnit();
          unit?.title = unitTitle;
          chapter?.units.add(unit as MbclUnit);
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
        compileLevel(levelPath); // compileLevel(levelPath);
        unit?.levels.add(level as MbclLevel);
        // set chapter meta data
        level?.fileId = fileName;
        level?.posX = posX.toDouble();
        level?.posY = posY.toDouble();
        level?.requiresTmp.addAll(requirements);
        level?.iconData = iconData;
      }
    }
    // build dependency graph
    for (var i = 0; i < (chapter as MbclChapter).levels.length; i++) {
      var level = chapter?.levels[i] as MbclLevel;
      for (var j = 0; j < level.requiresTmp.length; j++) {
        var r = level.requiresTmp[j];
        var requiredLevel = chapter?.getLevelByFileID(r);
        if (requiredLevel == null) {
          _error('Unknown dependency-level "$r".');
        } else {
          level.requires.add(requiredLevel);
        }
      }
    }
  }

  //G level = TODO
  void compileLevel(String path) {
    equationNumberCounter = 1;
    // create a new level
    level = MbclLevel();
    if (disableBlockTitles) {
      level!.disableBlockTitles = true;
    }
    chapter!.levels.add(level as MbclLevel);
    // get level source
    var src = loadFile(path);
    if (src.isEmpty) {
      _error('Level file $path does not exist or is empty.');
    }
    // parse block hierarchy
    var rootBlock = _parseBlockHierarchy(src);
    // process and deep-parse block hierarchy
    parseLevelBlock(rootBlock, this, level!, null, 0, null);
  }

  int createUniqueId() {
    return uniqueIdCounter++;
  }

  void _next() {
    currentLineIdx++;
    if (currentLineIdx < srcLines.length) {
      currentLine = srcLines[currentLineIdx];
    } else {
      currentLine = '§END';
    }
  }

  void _error(String message) {
    // TODO: include file path!
    throw Exception('ERROR:${currentLineIdx + 1}: $message');
  }

  Block _parseBlockHierarchy(String src) {
    // set source, split it into lines, trim these lines and
    // filter out comments of each line
    srcLines = src.split('\n');
    for (var k = 0; k < srcLines.length; k++) {
      var line = srcLines[k];
      var tokens = line.split('%');
      srcLines[k] = tokens[0];
    }
    // init lexer
    currentLineIdx = -1;
    _next();
    // parse
    var depthList =
        List<Block?>.filled(0, null, growable: true); // TODO: write comment!!
    var rootBlock = Block(level!, "ROOT", 0, -1);
    depthList.length = 1;
    depthList[0] = rootBlock;
    var currentBlock = rootBlock;
    while (currentLine != '§END') {
      var trimmed = currentLine.trim();
      var spaces = 0;
      for (var k = 0; k < currentLine.length; k++) {
        if (currentLine[k] == ' ') {
          spaces++;
        } else if (currentLine[k] == '\t') {
          spaces += 4;
        } else {
          break;
        }
      }
      int indentation = spaces ~/ 4;
      indentation += 1; // add one for root element
      // A keyword is fully uppercase; also "_", "-" and "*" are allowed
      // characters.
      // If "=" is followed (directly or after some spaces), we are actually
      // parsing an attribute and NOT a keyword.
      var keyword = "";
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
        var srcLine = currentLineIdx + 1;
        currentBlock = Block(level!, keyword, indentation, srcLine);
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
        var line = currentLine.replaceAll('\t', '    ');
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
                'Hint: Move line ${currentLineIdx + 1} to line ${currentBlock.srcLine + 1}');
          }
        }
        if (isAttribute == false) {
          var b = Block(level!, "DEFAULT", indentation, currentLineIdx + 1);
          b.data = '$line\n';
          currentBlock.children.add(b);
        }
      }
      _next();
    }
    rootBlock.postProcess();
    //print(rootBlock);
    return rootBlock;
  }
}

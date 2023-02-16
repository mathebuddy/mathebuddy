/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbl.html

import { Lexer } from '@multila/multila-lexer';
import { LexerTokenType } from '@multila/multila-lexer/lib/token';

import { Block, BlockPart } from './block';
import {
  MBL_Exercise,
  MBL_Exercise_Text_Input,
  MBL_Exercise_Text_Input_Type,
  MBL_Exercise_Text_Multiple_Choice,
  MBL_Exercise_Text_Single_Choice,
  MBL_Exercise_Text_Single_or_Multi_Choice_Option,
  MBL_Exercise_Text_Variable,
  MBL_Exercise_VariableType,
} from './dataExercise';
import { MBL_Course, MBL_Course_Debug } from './dataCourse';
import { MBL_Chapter } from './dataChapter';
import { MBL_Level, MBL_LevelItem } from './dataLevel';
import { MBL_Section, MBL_SectionType } from './dataSection';
import {
  MBL_Text,
  MBL_Text_Bold,
  MBL_Text_Color,
  MBL_Text_Error,
  MBL_Text_InlineMath,
  MBL_Text_Italic,
  MBL_Text_Itemize,
  MBL_Text_Itemize_Type,
  MBL_Text_Linefeed,
  MBL_Text_Paragraph,
  MBL_Text_Reference,
  MBL_Text_Span,
  MBL_Text_Text,
} from './dataText';
import { MBL_Unit } from './dataUnit';

export class MBL_Compile_Error extends Error {
  constructor(msg: string) {
    super(msg);
    this.name = 'MBL_Compile_Error';
  }
}

export class Compiler {
  private loadFile: (path: string) => string = null;

  private course: MBL_Course = null;
  private chapter: MBL_Chapter = null;
  private unit: MBL_Unit = null;
  private level: MBL_Level = null;

  private srcLines: string[] = [];
  private i = -1; // current line index (starting from 0)
  private line = ''; // current line
  private line2 = ''; // next line
  private paragraph = '';

  private uniqueIdCounter = 0;

  public createUniqueId(): number {
    return this.uniqueIdCounter++;
  }

  public getCourse(): MBL_Course {
    return this.course;
  }

  public compile(path: string, loadFile: (path: string) => string): void {
    // store load function
    this.loadFile = loadFile;
    // compile
    if (path.endsWith('course.mbl')) {
      // processing complete course
      this.compileCourse(path);
    } else if (path.endsWith('index.mbl')) {
      // processing only a course chapter
      this.course = new MBL_Course();
      this.course.debug = MBL_Course_Debug.Chapter;
      this.compileChapter(path);
    } else {
      // processing only a course level
      this.course = new MBL_Course();
      this.course.debug = MBL_Course_Debug.Level;
      this.chapter = new MBL_Chapter();
      this.course.chapters.push(this.chapter);
      this.compileLevel(path);
    }
    // post processing
    this.course.postProcess();
  }

  //G course = courseTitle courseAuthor courseChapters;
  //G courseTitle = "TITLE" { ID } "\n";
  //G courseAuthor = "AUTHOR" { ID } "\n";
  //G courseChapters = "CHAPTERS" "\n" { courseChapter };
  //G courseChapter = "(" INT "," INT ")" ID { "!" ID } "\n";
  public compileCourse(path: string): void {
    // create a new course
    this.course = new MBL_Course();
    // get course description file source
    const src = this.loadFile(path);
    if (src.length == 0) {
      this.error(
        'course description file ' + path + ' does not exist or is empty',
      );
      return;
    }
    // parse
    const lines = src.split('\n');
    let state = 'global';
    let rowIdx = 0;
    for (let line of lines) {
      rowIdx++;
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state === 'global') {
        if (line.startsWith('TITLE'))
          this.course.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this.course.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('CHAPTERS')) state = 'chapter';
        else this.error('unexpected line ' + line);
      } else if (state === 'chapter') {
        const lexer = new Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.TER('(');
        const posX = lexer.INT();
        lexer.TER(',');
        const posY = lexer.INT();
        lexer.TER(')');
        const directoryName = lexer.ID();
        const requirements: string[] = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.push(lexer.ID());
        }
        lexer.END();
        // compile chapter
        const dirname = path.match(/.*\//);
        const chapterPath = dirname + directoryName + '/index.mbl';
        this.compileChapter(chapterPath);
        // set chapter meta data
        this.chapter.file_id = directoryName;
        this.chapter.pos_x = posX;
        this.chapter.pos_y = posY;
        this.chapter.requires_tmp.push(...requirements);
      }
    }
    // build dependency graph
    for (const chapter of this.course.chapters) {
      for (const r of chapter.requires_tmp) {
        const requiredChapter = this.course.getChapterByFileID(r);
        if (requiredChapter == null) this.error('unknown chapter ' + r);
        else chapter.requires.push(requiredChapter);
      }
    }
  }

  //G chapter = chapterTitle chapterAuthor { chapterUnit };
  //G chapterTitle = "TITLE" { ID } "\n";
  //G chapterAuthor = "AUTHOR" { ID } "\n";
  //G chapterUnit = "UNIT" { ID } "\n" { chapterLevel };
  //G chapterLevel = "(" INT "," INT ")" ID { "!" ID } "\n";
  public compileChapter(path: string): void {
    // create a new chapter
    this.chapter = new MBL_Chapter();
    this.course.chapters.push(this.chapter);
    // get chapter index file source
    const src = this.loadFile(path);
    if (src.length == 0) {
      this.error('chapter index file ' + path + ' does not exist or is empty');
      return;
    }
    // parse
    const lines = src.split('\n');
    let state = 'global';
    let rowIdx = 0;
    for (let line of lines) {
      rowIdx++;
      line = line.split('%')[0];
      if (line.trim().length == 0) continue;
      if (state === 'global' || line.startsWith('UNIT')) {
        if (line.startsWith('TITLE'))
          this.chapter.title = line.substring('TITLE'.length).trim();
        else if (line.startsWith('AUTHOR'))
          this.chapter.author = line.substring('AUTHOR'.length).trim();
        else if (line.startsWith('UNIT')) {
          // TODO: handle units!!
          const unitTitle = line.substring('UNIT'.length).trim();
          state = 'unit';
          this.unit = new MBL_Unit();
          this.unit.title = unitTitle;
          this.chapter.units.push(this.unit);
        } else this.error('unexpected line ' + line);
      } else if (state === 'unit') {
        const lexer = new Lexer();
        lexer.enableHyphenInID(true);
        lexer.pushSource(path, line, rowIdx);
        lexer.TER('(');
        const posX = lexer.INT();
        lexer.TER(',');
        const posY = lexer.INT();
        lexer.TER(')');
        const fileName = lexer.ID();
        const requirements: string[] = [];
        while (lexer.isTER('!')) {
          lexer.next();
          requirements.push(lexer.ID());
        }
        lexer.END();
        // compile level
        const dirname = path.match(/.*\//);
        const levelPath = dirname + fileName + '.mbl';
        this.compileLevel(levelPath);
        this.unit.levels.push(this.level);
        // set chapter meta data
        this.level.file_id = fileName;
        this.level.pos_x = posX;
        this.level.pos_y = posY;
        this.level.requires_tmp.push(...requirements);
      }
    }
    // build dependency graph
    for (const level of this.chapter.levels) {
      for (const r of level.requires_tmp) {
        const requiredLevel = this.chapter.getLevelByFileID(r);
        if (requiredLevel == null) this.error('unknown level ' + r);
        else level.requires.push(requiredLevel);
      }
    }
  }

  //G level = { levelTitle | sectionTitle | subSectionTitle | block | paragraph };
  public compileLevel(path: string): void {
    // create a new level
    this.level = new MBL_Level();
    this.chapter.levels.push(this.level);
    // get level source
    const src = this.loadFile(path);
    if (src.length == 0)
      this.error('level file ' + path + ' does not exist or is empty');
    // set source, split it into lines, trim these lines and
    // filter out comments of each line
    this.srcLines = src.split('\n');
    for (let k = 0; k < this.srcLines.length; k++) {
      const line = this.srcLines[k].trim();
      const tokens = line.split('%');
      this.srcLines[k] = tokens[0];
    }
    // init lexer
    this.i = -1;
    this.next();
    // parse
    while (this.line !== '§END') {
      if (this.line2.startsWith('#####')) {
        this.pushParagraph();
        this.parseLevelTitle();
      } else if (this.line2.startsWith('=====')) {
        this.pushParagraph();
        this.level.items.push(this.parseSectionTitle());
      } else if (this.line2.startsWith('-----')) {
        this.pushParagraph();
        this.level.items.push(this.parseSubSectionTitle());
      } else if (this.line === '---') {
        this.pushParagraph();
        this.level.items.push(this.parseBlock(false));
      } else {
        this.paragraph += this.line + '\n';
        this.next();
      }
    }
    this.pushParagraph();
  }

  private pushParagraph(): void {
    if (this.paragraph.trim().length > 0) {
      this.level.items.push(this.parseParagraph(this.paragraph));
      this.paragraph = '';
    }
  }

  private next(): void {
    this.i++;
    if (this.i < this.srcLines.length) {
      this.line = this.srcLines[this.i];
    } else this.line = '§END';
    if (this.i + 1 < this.srcLines.length) {
      this.line2 = this.srcLines[this.i + 1];
    } else this.line2 = '§END';
  }

  //G levelTitle = { CHAR } "@" { ID } NEWLINE "#####.." { "#" } NEWLINE;
  private parseLevelTitle(): void {
    const tokens = this.line.split('@');
    this.level.title = tokens[0].trim();
    if (tokens.length > 1) {
      this.level.label = tokens[1].trim();
    }
    this.next(); // skip document title
    this.next(); // skip '#####..'
  }

  //G sectionTitle = { CHAR } "@" { ID } NEWLINE "=====.." { "#" } NEWLINE;
  private parseSectionTitle(): MBL_Section {
    const section = new MBL_Section(MBL_SectionType.Section);
    const tokens = this.line.split('@');
    section.text = tokens[0].trim();
    if (tokens.length > 1) {
      section.label = tokens[1].trim();
    }
    this.next(); // skip section title
    this.next(); // skip '=====..'
    return section;
  }

  //G subSectionTitle = { CHAR } "@" { ID } NEWLINE "-----.." { "#" } NEWLINE;
  private parseSubSectionTitle(): MBL_Section {
    const subSection = new MBL_Section(MBL_SectionType.SubSection);
    const tokens = this.line.split('@');
    subSection.text = tokens[0].trim();
    if (tokens.length > 1) {
      subSection.label = tokens[1].trim();
    }
    this.next(); // skip subSection title
    this.next(); // skip '-----..'
    return subSection;
  }

  //G block = "---" NEWLINE { "@" ID NEWLINE | LINE } "---" NEWLINE;
  // TODO: grammar for subblocks
  private parseBlock(parseSubBlock: boolean): MBL_LevelItem {
    const block = new Block(this);
    block.srcLine = this.i;
    if (!parseSubBlock) this.next(); // skip "---"
    const tokens = this.line.split(' ');
    for (let k = 0; k < tokens.length; k++) {
      if (k == 0) block.type = tokens[k];
      else if (tokens[k].startsWith('@')) block.label = tokens[k];
      else block.title += tokens[k] + ' ';
    }
    block.title = block.title.trim();
    this.next();
    let part: BlockPart = new BlockPart();
    part.name = 'global';
    block.parts.push(part);
    while (this.line !== '---' && this.line !== '§END') {
      if (this.line.startsWith('@')) {
        part = new BlockPart();
        block.parts.push(part);
        part.name = this.line.substring(1).trim();
        this.next();
      } else if (
        this.line.length >= 3 &&
        this.line[0] >= 'A' &&
        this.line[0] <= 'Z' &&
        this.line.substring(0, 3) === this.line.toUpperCase().substring(0, 3)
      ) {
        if (parseSubBlock) break;
        else block.parts.push(this.parseBlock(true));
      } else {
        part.lines.push(this.line);
        this.next();
      }
    }
    if (!parseSubBlock) {
      if (this.line === '---') this.next();
      else
        this.error(
          'block started in line ' + block.srcLine + ' must end with ---',
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
  public parseParagraph(raw: string, ex: MBL_Exercise = null): MBL_Text {
    // skip empty paragraphs
    if (raw.trim().length == 0)
      //return new ParagraphItem(ParagraphItemType.Text);
      return new MBL_Text_Text(); // TODO: OK??
    // create lexer
    const lexer = new Lexer();
    lexer.enableEmitNewlines(true);
    lexer.enableUmlautInID(true);
    lexer.pushSource('', raw);
    lexer.setTerminals(['**', '#.', '-)']);
    const paragraph = new MBL_Text_Paragraph();
    while (lexer.isNotEND())
      paragraph.items.push(this.parseParagraph_part(lexer, ex));
    return paragraph;
  }

  private parseParagraph_part(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
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
      const isNewParagraph = lexer.getToken().col == 1;
      lexer.next();
      if (isNewParagraph) return new MBL_Text_Linefeed();
      else return new MBL_Text_Text();
    } else if (lexer.isTER('[')) {
      // text properties: e.g. "[text in red color]@color1"
      return this.parseTextProperty(lexer, exercise);
    } else {
      // text tokens (... or yet unimplemented paragraph items)
      const text = new MBL_Text_Text();
      text.value = lexer.getToken().token;
      lexer.next();
      return text;
    }
    throw new Error('this should never happen!');
  }

  private parseItemize(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    // '-' for itemize; '#.' for enumerate; '-)' for alpha enumerate
    const typeStr = lexer.getToken().token;
    let type: MBL_Text_Itemize_Type;
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
    const itemize = new MBL_Text_Itemize(type);
    while (lexer.getToken().col == 1 && lexer.isTER(typeStr)) {
      lexer.next();
      const span = new MBL_Text_Span();
      itemize.items.push(span);
      while (lexer.isNotNEWLINE() && lexer.isNotEND())
        span.items.push(this.parseParagraph_part(lexer, exercise));
      if (lexer.isNEWLINE()) lexer.NEWLINE();
    }
    return itemize;
  }

  private parseBoldText(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    lexer.next();
    const bold = new MBL_Text_Bold();
    while (lexer.isNotTER('**') && lexer.isNotEND())
      bold.items.push(this.parseParagraph_part(lexer, exercise));
    if (lexer.isTER('**')) lexer.next();
    return bold;
  }

  private parseItalicText(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    lexer.next();
    const italic = new MBL_Text_Italic();
    while (lexer.isNotTER('*') && lexer.isNotEND())
      italic.items.push(this.parseParagraph_part(lexer, exercise));
    if (lexer.isTER('*')) lexer.next();
    return italic;
  }

  private parseInlineMath(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    lexer.next();
    const inlineMath = new MBL_Text_InlineMath();
    while (lexer.isNotTER('$') && lexer.isNotEND()) {
      const tk = lexer.getToken().token;
      const isId = lexer.getToken().type === LexerTokenType.ID;
      lexer.next();
      if (isId && exercise != null && tk in exercise.variables) {
        const v = new MBL_Exercise_Text_Variable();
        v.variableId = tk;
        inlineMath.items.push(v);
      } else {
        const text = new MBL_Text_Text();
        text.value = tk;
        inlineMath.items.push(text);
      }
    }
    if (lexer.isTER('$')) lexer.next();
    return inlineMath;
  }

  private parseReference(lexer: Lexer): MBL_Text {
    lexer.next();
    const ref = new MBL_Text_Reference();
    if (lexer.isID()) {
      ref.label = lexer.getToken().token;
      lexer.next();
    }
    return ref;
  }

  private parseInputElements(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    lexer.next();
    let id = '';
    const input = new MBL_Exercise_Text_Input();
    input.input_id = 'input' + this.createUniqueId();
    if (lexer.isID()) {
      id = lexer.ID();
      if (id in exercise.variables) {
        const v = exercise.variables[id];
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
            exercise.error += 'UNIMPLEMENTED input type ' + v.type + '. ';
        }
      } else {
        exercise.error = 'there is no variable "' + id + '". ';
      }
    } else {
      exercise.error = 'no variable for input field given. ';
    }
    return input;
  }

  private parseSingleOrMultipleChoice(
    lexer: Lexer,
    exercise: MBL_Exercise,
  ): MBL_Text {
    const isMultipleChoice = lexer.isTER('[');
    lexer.next();
    let staticallyCorrect = false;
    let varId = '';
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
    let element:
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
    const option = new MBL_Exercise_Text_Single_or_Multi_Choice_Option();
    option.input_id = 'input' + this.createUniqueId();
    option.variable = varId;
    element.items.push(option);
    const span = new MBL_Text_Span();
    option.text = span;
    while (lexer.isNotNEWLINE() && lexer.isNotEND())
      span.items.push(this.parseParagraph_part(lexer, exercise));
    if (lexer.isTER('\n')) lexer.next();
    return element;
  }

  private parseTextProperty(lexer: Lexer, exercise: MBL_Exercise): MBL_Text {
    // TODO: make sure, that errors are not too annoying...
    lexer.next();
    const items: MBL_Text[] = [];
    while (lexer.isNotTER(']') && lexer.isNotEND())
      items.push(this.parseParagraph_part(lexer, exercise));
    if (lexer.isTER(']')) lexer.next();
    else return new MBL_Text_Error('expected ]');
    if (lexer.isTER('@')) lexer.next();
    else return new MBL_Text_Error('expected @');
    if (lexer.isID()) {
      const id = lexer.ID();
      if (id === 'bold') {
        const bold = new MBL_Text_Bold();
        bold.items = items;
        return bold;
      } else if (id === 'italic') {
        const italic = new MBL_Text_Italic();
        italic.items = items;
        return italic;
      } else if (id.startsWith('color')) {
        const color = new MBL_Text_Color();
        color.key = parseInt(id.substring(5)); // TODO: check if INT
        color.items = items;
        return color;
      } else {
        return new MBL_Text_Error('unknown property ' + id);
      }
    } else return new MBL_Text_Error('missing property name');
  }

  private error(message: string): void {
    // TODO: include file path!
    throw new MBL_Compile_Error('ERROR:' + (this.i + 1) + ': ' + message);
  }
}

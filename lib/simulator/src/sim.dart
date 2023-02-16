/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { compareTerms } from '@mathebuddy/mathebuddy-math-runtime/src';

import {
  MBL_Course,
  MBL_Course_Debug,
} from '@mathebuddy/mathebuddy-compiler/src/dataCourse';
import { MBL_Definition } from '@mathebuddy/mathebuddy-compiler/src/dataDefinition';
import { MBL_Equation } from '@mathebuddy/mathebuddy-compiler/src/dataEquation';
import { MBL_Error } from '@mathebuddy/mathebuddy-compiler/src/dataError';
import {
  MBL_Exercise,
  MBL_Exercise_Text_Input,
  MBL_Exercise_Text_Multiple_Choice,
  MBL_Exercise_Text_Variable,
  MBL_Exercise_VariableType,
} from '@mathebuddy/mathebuddy-compiler/src/dataExercise';
import {
  MBL_Level,
  MBL_LevelItem,
} from '@mathebuddy/mathebuddy-compiler/src/dataLevel';
import { MBL_Section } from '@mathebuddy/mathebuddy-compiler/src/dataSection';
import { MBL_Table } from '@mathebuddy/mathebuddy-compiler/src/dataTable';
import {
  MBL_Text,
  MBL_Text_AlignCenter,
  MBL_Text_Bold,
  MBL_Text_Color,
  MBL_Text_InlineMath,
  MBL_Text_Itemize,
  MBL_Text_Paragraph,
  MBL_Text_Span,
  MBL_Text_Text,
} from '@mathebuddy/mathebuddy-compiler/src/dataText';
import {
  complexNormalFormKeyboardLayout,
  complexSetKeyboardLayout,
  integerKeyboardLayout,
  integerSetKeyboardLayout,
  realNumberKeyboardLayout,
  termKeyboardLayout,
} from './keyboardLayouts';

import { htmlSafeString } from './html';
import { Keyboard } from './keyboard';

import { MathJax } from './mathjax';
import { matrix2tex, set2tex, term2tex } from './tex';

const yellow = '#ceab39';
const red = '#c56663';
const green = '#b1c752';
//const blue = '#1800d8';

enum CheckState {
  AllCorrect = 'all-correct',
  Mistakes = 'mistakes',
  Incomplete = 'incomplete',
}

class ExerciseData {
  private sim: Simulator;

  expectedValues: { [inputId: string]: string } = {};
  expectedTypes: { [inputId: string]: string } = {};
  studentValues: { [inputId: string]: string } = {};
  htmlElements: { [inputId: string]: HTMLElement } = {};

  constructor(sim: Simulator) {
    this.sim = sim;
  }

  colorizeHTMLElements(color: string): void {
    for (const inputId in this.htmlElements) {
      const htmlElement = this.htmlElements[inputId];
      htmlElement.style.color = color;
    }
  }

  check(): CheckState {
    for (const inputId in this.expectedTypes) {
      const expectedType = this.expectedTypes[inputId].trim();
      const expectedValue = this.expectedValues[inputId].trim();
      const studentValue = this.studentValues[inputId].trim();
      switch (expectedType) {
        case 'bool':
          if (studentValue === 'unset') return CheckState.Incomplete;
          if (expectedValue !== studentValue) {
            this.sim.appendToLog(
              `INFO: Incorrect answer for boolean input "${inputId}". Correct answer is "${expectedValue}".`,
            );
            return CheckState.Mistakes;
          }
          break;
        default: {
          let ok = false;
          try {
            ok = compareTerms(expectedValue, studentValue);
          } catch (e) {
            this.sim.appendToLog(
              `Error comparing answer '${studentValue}' to expected solution '${expectedValue}': ` +
                e.toString(),
            );
          }
          if (ok == false) {
            this.sim.appendToLog(
              `INFO: Incorrect answer for input "${inputId}". Correct answer is "${expectedValue}".`,
            );
            return CheckState.Mistakes;
          }
          break;
        }
      }
    }
    return CheckState.AllCorrect;
  }
}

export class Simulator {
  private log = '';
  private logUpdateFunction: () => void = null;

  private course: MBL_Course = null;
  private exerciseData: { [exerciseId: string]: ExerciseData } = {};

  private currentExercise: MBL_Exercise = null;
  private currentExerciseInstanceIndex = 0;
  private currentExerciseData: ExerciseData = null;
  private currentExerciseHTMLElement: HTMLDivElement = null;

  private mathjaxInst: MathJax = null;

  private parentDOM: HTMLElement = null;

  private keyboard: Keyboard = null;

  constructor(parent: HTMLElement, keyboardElement: HTMLElement) {
    this.parentDOM = parent;
    this.mathjaxInst = new MathJax();

    this.keyboard = new Keyboard(keyboardElement);
  }

  public setLogUpdateFunction(f: () => void): void {
    this.logUpdateFunction = f;
  }

  public setCourse(course: MBL_Course): void {
    this.course = course;
  }

  public appendToLog(msg: string): void {
    console.log(msg);
    this.log += msg + '\n';
    this.logUpdateFunction();
  }

  public getLog(): string {
    return htmlSafeString(this.log);
  }

  public getHTML(): string {
    const html = this.parentDOM.innerHTML;
    return htmlSafeString(html);
  }

  public getMBCL(): string {
    const json = JSON.stringify(this.course.toJSON(), null, 2);
    return htmlSafeString(json);
  }

  public generateDOM(): boolean {
    this.parentDOM.innerHTML = '';
    switch (this.course.debug) {
      case MBL_Course_Debug.Level:
        this.parentDOM.appendChild(
          this.generateLevel(this.course.chapters[0].levels[0]),
        );
        //this.parentDOM.appendChild(h4);
        break;
      default:
        this.error(
          'Simulator.generateDOM(..): unimplemented ' + this.course.debug,
        );
        break;
    }
    this.info('... ready');
    return true;
  }

  private generateLevel(level: MBL_Level): HTMLElement {
    const root = document.createElement('div');
    // title
    const title = document.createElement('h2');
    title.innerHTML =
      '<i class="fa-solid fa-ellipsis-vertical"></i>&nbsp;' +
      level.title.toUpperCase();
    title.classList.add('text-start', 'py-2');
    root.appendChild(title);
    // level items
    for (const item of level.items) {
      const itemHTML = this.generateLevelItem(item);
      if (itemHTML != null) root.appendChild(itemHTML);
    }
    return root;
  }

  private generateLevelItem(item: MBL_LevelItem): HTMLElement {
    switch (item.type) {
      case 'section': {
        const section = <MBL_Section>item;
        const element = document.createElement('h1');
        element.innerHTML = section.text;
        return element;
      }
      case 'subsection': {
        const section = <MBL_Section>item;
        const element = document.createElement('h2');
        element.innerHTML = section.text;
        return element;
      }
      case 'subsubsection': {
        const section = <MBL_Section>item;
        const element = document.createElement('h3');
        element.innerHTML = section.text;
        return element;
      }
      case 'equation': {
        const equation = <MBL_Equation>item;
        const element = document.createElement('div');
        element.classList.add('text-center');
        let tex = equation.value;
        if (equation.numbering > 0) tex += '~~(' + equation.numbering + ')';
        const html = this.mathjaxInst.tex2svgBlock(tex);
        element.innerHTML = ' ' + html + ' ';
        return element;
      }
      case 'definition':
      case 'theorem': {
        const definition = <MBL_Definition>item;
        const element = document.createElement('div');
        element.classList.add('my-1', 'p-1');
        element.classList.add('border', 'border-dark');
        for (const subItem of definition.items) {
          element.appendChild(this.generateLevelItem(subItem));
        }
        return element;
      }
      case 'exercise': {
        // handle error
        if ((<MBL_Exercise>item).error.length > 0) {
          const ex = <MBL_Exercise>item;
          const message = ex.error;
          const element = document.createElement('div');
          element.classList.add('col', 'mb-3', 'p-1');
          element.style.backgroundColor = '#FF0000';
          const p = document.createElement('p');
          element.appendChild(p);
          p.innerHTML =
            'EXERCISE "' + ex.title + '" contains ERROR(s): <br/>' + message;
          return element;
        }
        // get exercise data
        this.currentExercise = <MBL_Exercise>item;
        this.currentExerciseInstanceIndex = Math.floor(
          Math.random() * this.currentExercise.instances.length,
        );
        const data = new ExerciseData(this);
        this.exerciseData[this.currentExercise.label] = data;
        this.currentExerciseData = data;
        // create DOM elements
        // (a) outer DIV
        const element = document.createElement('div');
        this.currentExerciseHTMLElement = element;
        element.classList.add('col', 'mb-3', 'p-0');
        element.style.backgroundColor = '#353535';
        element.style.color = 'white';
        element.style.borderStyle = 'solid';
        element.style.borderRadius = '8px';
        element.style.borderColor = yellow;
        // (b) inner DIV
        const content = document.createElement('div');
        content.classList.add('px-2');
        element.appendChild(content);
        // (c) title
        const title = document.createElement('h4');
        content.appendChild(title);
        title.classList.add('text-start', 'pt-2');
        title.innerHTML =
          '<span style="font-size:14pt">&nbsp;<i class="fa-solid fa-pencil"></i></span>&nbsp;' +
          this.currentExercise.title;
        content.appendChild(this.generateTextItem(this.currentExercise.text));
        // (d) evaluation button
        const checkButton = document.createElement('div');
        element.appendChild(checkButton);
        checkButton.classList.add('w-100', 'text-center');
        checkButton.style.backgroundColor = yellow;
        checkButton.style.cursor = 'pointer';
        checkButton.style.fontSize = '16pt';
        // check button behavior
        checkButton.innerHTML = '<i class="fa-solid fa-question"></i>';
        {
          const _data = this.currentExerciseData;
          const _element = element;
          const _checkButton = checkButton;
          checkButton.addEventListener('click', () => {
            switch (_data.check()) {
              case CheckState.AllCorrect:
                _element.style.borderColor = green;
                _checkButton.style.backgroundColor = green;
                _checkButton.innerHTML = '<i class="fa-solid fa-check"></i>';
                _data.colorizeHTMLElements(green);
                break;
              case CheckState.Mistakes:
                _element.style.borderColor = red;
                _checkButton.style.backgroundColor = red;
                _checkButton.innerHTML = '<i class="fa-solid fa-xmark"></i>';
                _data.colorizeHTMLElements(yellow);
                setTimeout(() => {
                  checkButton.innerHTML =
                    '<i class="fa-solid fa-question"></i>';
                }, 1000);
                break;
              case CheckState.Incomplete:
                _checkButton.innerHTML = '<i class="fa-solid fa-hammer"></i>';
                _data.colorizeHTMLElements(yellow);
                setTimeout(() => {
                  checkButton.innerHTML =
                    '<i class="fa-solid fa-question"></i>';
                }, 1000);
                break;
            }
          });
        }
        // return DOM element
        return element;
      }
      case 'table': {
        const table = <MBL_Table>item;
        const element = document.createElement('div');
        const p = document.createElement('p');
        p.classList.add('text-center');
        p.innerHTML = table.title;
        element.appendChild(p);
        const tableElement = document.createElement('table');
        element.appendChild(tableElement);
        tableElement.classList.add('table');
        if (table.head.columns.length > 0) {
          const thead = document.createElement('thead');
          tableElement.appendChild(thead);
          for (const column of table.head.columns) {
            const th = document.createElement('th');
            th.scope = 'col';
            thead.appendChild(th);
            th.appendChild(this.generateTextItem(column));
          }
        }
        const tbody = document.createElement('tbody');
        tableElement.appendChild(tbody);
        for (const row of table.rows) {
          const tr = document.createElement('tr');
          tbody.appendChild(tr);
          for (const column of row.columns) {
            const td = document.createElement('td');
            tr.appendChild(td);
            td.appendChild(this.generateTextItem(column));
          }
        }
        return element;
      }
      case 'paragraph':
      case 'align_center': {
        return this.generateTextItem(item);
      }
      default:
        this.warning('generateLevelItem(..): unimplemented type: ' + item.type);
    }
    return document.createElement('span');
  }

  private generateTextItem(item: MBL_Text): HTMLElement {
    switch (item.type) {
      case 'paragraph': {
        const paragraph = <MBL_Text_Paragraph>item;
        const p = document.createElement('p');
        //p.style.backgroundColor = '#ff0000';
        p.classList.add('py-0');
        p.style.fontSize = '12pt';
        for (const paragraphItem of paragraph.items)
          p.appendChild(this.generateTextItem(paragraphItem));
        return p;
      }
      case 'align_left':
      case 'align_center':
      case 'align_right': {
        const align = <MBL_Text_AlignCenter>item;
        const element = document.createElement('div');
        switch (item.type) {
          case 'align_left':
            element.classList.add('text-start');
            break;
          case 'align_center':
            element.classList.add('text-center');
            break;
          case 'align_right':
            element.classList.add('text-end');
            break;
        }
        for (const subItem of align.items)
          element.appendChild(this.generateTextItem(subItem));
        return element;
      }
      case 'text': {
        const text = <MBL_Text_Text>item;
        const element = document.createElement('span');
        element.innerHTML = text.value;
        return element;
      }
      case 'linefeed': {
        const span = document.createElement('span');
        span.innerHTML = '<br/><br/>';
        return span;
      }
      case 'span': {
        const span = <MBL_Text_Span>item;
        const element = document.createElement('span');
        for (const subItem of span.items)
          element.appendChild(this.generateTextItem(subItem));
        return element;
      }
      case 'bold': {
        const bold = <MBL_Text_Bold>item;
        const element = document.createElement('strong');
        element.classList.add('px-1');
        for (const subItem of bold.items)
          element.appendChild(this.generateTextItem(subItem));
        return element;
      }
      case 'italic': {
        const italic = <MBL_Text_Bold>item;
        const element = document.createElement('em');
        element.classList.add('px-1');
        for (const subItem of italic.items)
          element.appendChild(this.generateTextItem(subItem));
        return element;
      }
      case 'color': {
        const color = <MBL_Text_Color>item;
        const element = document.createElement('span');
        element.classList.add('px-1');
        switch (color.key) {
          case 0:
            element.style.color = 'rgb(0,0,0)';
            break;
          case 1:
            element.style.color = 'rgb(255,0,0)';
            break;
          case 2:
            element.style.color = 'rgb(0,0,255)';
            break;
          case 3:
            element.style.color = 'rgb(0,255,0)';
            break;
          default:
            this.warning(
              'generateTextItem(..): unimplemented color key: ' + color.key,
            );
        }
        for (const subItem of color.items)
          element.appendChild(this.generateTextItem(subItem));
        return element;
      }
      case 'itemize':
      case 'enumerate':
      case 'enumerate_alpha': {
        const itemize = <MBL_Text_Itemize>item;
        let element: HTMLUListElement | HTMLOListElement;
        switch (item.type) {
          case 'itemize':
            element = document.createElement('ul');
            break;
          case 'enumerate':
            element = document.createElement('ol');
            break;
          case 'enumerate_alpha':
            element = document.createElement('ol');
            element.type = 'a';
            break;
        }
        for (const subItem of itemize.items) {
          const li = document.createElement('li');
          element.appendChild(li);
          li.appendChild(this.generateTextItem(subItem));
        }
        return element;
      }
      case 'inline_math': {
        const inlineMath = <MBL_Text_InlineMath>item;
        const element = document.createElement('span');
        element.classList.add('m-1');
        let tex = '';
        for (const subItem of inlineMath.items) {
          switch (subItem.type) {
            case 'text': {
              const text = <MBL_Text_Text>subItem;
              tex += text.value;
              break;
            }
            case 'variable': {
              const variable = <MBL_Exercise_Text_Variable>subItem;
              const v = this.currentExercise.variables[variable.variableId];
              const value =
                this.currentExercise.instances[
                  this.currentExerciseInstanceIndex
                ].values[variable.variableId];
              switch (v.type) {
                case MBL_Exercise_VariableType.Bool:
                case MBL_Exercise_VariableType.Int:
                case MBL_Exercise_VariableType.Real:
                case MBL_Exercise_VariableType.Complex:
                  tex += value;
                  break;
                case MBL_Exercise_VariableType.IntSet:
                case MBL_Exercise_VariableType.RealSet:
                  tex += set2tex(value);
                  break;
                case MBL_Exercise_VariableType.Matrix:
                  tex += matrix2tex(value);
                  break;
                case MBL_Exercise_VariableType.Term:
                  tex += term2tex(value);
                  break;
                default:
                  this.warning(
                    'generateTextItem(..):inline_math:variable: ' +
                      'unimplemented type: ' +
                      v.type,
                  );
              }
              break;
            }
            default:
              this.warning(
                'generateTextItem(..):inline_math: unimplemented type: ' +
                  subItem.type,
              );
          }
        }
        const html = this.mathjaxInst.tex2svgInline(tex);
        element.innerHTML = ' ' + html + ' ';
        return element;
      }
      case 'text_input': {
        const input = <MBL_Exercise_Text_Input>item;

        const data = this.currentExerciseData;
        if (this.currentExercise.instances.length > 0) {
          data.expectedValues[input.input_id] =
            this.currentExercise.instances[
              this.currentExerciseInstanceIndex
            ].values[input.variable];

          //console.log(this.currentExercise.title);

          data.expectedTypes[input.input_id] =
            this.currentExercise.variables[input.variable].type;
          data.studentValues[input.input_id] = '';
        } else {
          console.log(
            'ERROR: exercise ' +
              this.currentExercise.title +
              ': cannot create data for text_input!',
          );
        }

        const element = document.createElement('span');
        data.htmlElements[input.input_id] = element;
        element.style.fontSize = '18pt';
        element.style.color = yellow;
        element.style.verticalAlign = 'center';
        element.style.paddingLeft = '3px';
        element.innerHTML =
          '&nbsp;&nbsp;<b><i class="fa-regular fa-keyboard" style="cursor:crosshair;"></i></b>&nbsp;&nbsp;';
        {
          const _exerciseElement = this.currentExerciseHTMLElement;
          const _data = data;
          element.addEventListener('click', () => {
            _exerciseElement.scrollIntoView({
              behavior: 'smooth',
            });
            // TODO: select keyboard layout!
            this.keyboard.setInputText('');
            this.keyboard.setListener((text: string): void => {
              _data.studentValues[input.input_id] = text;
              if (text.trim().length === 0) {
                element.innerHTML =
                  '&nbsp;&nbsp;<b><i class="fa-regular fa-keyboard" style="cursor:crosshair;"></i></b>&nbsp;&nbsp;';
              } else {
                element.innerHTML = this.mathjaxInst.tex2svgBlock(
                  term2tex(text),
                );
              }
            });
            this.keyboard.setInputText(_data.studentValues[input.input_id]);

            const type = data.expectedTypes[input.input_id];
            switch (type) {
              case 'int':
                this.keyboard.show(integerKeyboardLayout, false);
                break;
              case 'int_set':
                this.keyboard.show(integerSetKeyboardLayout, true);
                break;
              case 'real':
                this.keyboard.show(realNumberKeyboardLayout, false);
                break;
              case 'complex':
                this.keyboard.show(complexNormalFormKeyboardLayout, true);
                break;
              case 'complex_set':
                this.keyboard.show(complexSetKeyboardLayout, true);
                break;
              default:
                this.keyboard.show(termKeyboardLayout, true);
                this.appendToLog('text_input: unimplemented type ' + type);
            }

            const solution = _data.expectedValues[input.input_id];
            this.keyboard.setSolutionText(
              `&nbsp;<i class="fa-regular fa-lightbulb"></i>&nbsp;${solution}`,
            );
          });
        }
        return element;
      }
      case 'multiple_choice': {
        const mc = <MBL_Exercise_Text_Multiple_Choice>item;
        const element = document.createElement('table');
        // todo: randomize order
        const data = this.currentExerciseData;
        // create shuffled order
        const n = mc.items.length;
        const order: number[] = [];
        for (let i = 0; i < n; i++) {
          order.push(i);
        }
        for (let i = 0; i < n; i++) {
          const k1 = Math.floor(Math.random() * n);
          const k2 = Math.floor(Math.random() * n);
          const t = order[k1];
          order[k1] = order[k2];
          order[k2] = t;
        }
        // render options
        for (let i = 0; i < n; i++) {
          const option = mc.items[order[i]];
          data.expectedValues[option.input_id] =
            this.currentExercise.instances[
              this.currentExerciseInstanceIndex
            ].values[option.variable];
          data.expectedTypes[option.input_id] =
            this.currentExercise.variables[option.variable].type;
          data.studentValues[option.input_id] = 'unset';

          const tr = document.createElement('tr');
          tr.classList.add('p-1');
          element.appendChild(tr);

          // check box
          const tdCheck = document.createElement('td');
          tdCheck.classList.add('p-1');
          tdCheck.style.minWidth = '42px';
          tr.appendChild(tdCheck);

          data.htmlElements[option.input_id] = tdCheck;

          const correct = data.expectedValues[option.input_id] === 'true';
          const solutionHint = `<span style="font-size:8pt;"><i class="fa-${
            correct ? 'solid' : 'regular'
          } fa-lightbulb"></i></span>`;

          tdCheck.innerHTML =
            '<i class="fa-regular fa-circle-question" ></i>' + solutionHint;
          tdCheck.style.cursor = 'crosshair';
          tdCheck.style.fontSize = '18pt';
          tdCheck.style.color = yellow;

          {
            const _inputId = option.input_id;
            const _data = data;
            tr.addEventListener('click', () => {
              switch (_data.studentValues[_inputId]) {
                case 'unset':
                case 'false': {
                  tdCheck.innerHTML =
                    '<i class="fa-regular fa-circle-check" ></i>';
                  //tdCheck.style.color = inputColorBlue; // inputColorGreen;
                  _data.studentValues[_inputId] = 'true';
                  break;
                }
                case 'true': {
                  tdCheck.innerHTML =
                    '<i class="fa-regular fa-circle-xmark" ></i>';
                  //tdCheck.style.color = inputColorBlue; //inputColorRed;
                  _data.studentValues[_inputId] = 'false';
                  break;
                }
              }
            });
          }

          // text
          const tdText = document.createElement('td');
          tdText.classList.add('p-1');
          tr.appendChild(tdText);
          tdText.appendChild(this.generateTextItem(option.text));
        }

        return element;
      }
      case 'error': {
        const error = <MBL_Error>item;
        const element = document.createElement('div');
        element.classList.add('text-danger', 'border', 'border-dark');
        const p = document.createElement('p');
        element.appendChild(p);
        p.innerHTML = error.message;
        return element;
      }
      default:
        this.warning('generateTextItem(..): unimplemented type: ' + item.type);
    }
    return document.createElement('span');
  }

  info(message: string): void {
    console.log('SIM:INFO:' + message);
    this.log += 'SIM:INFO:' + message + '\n';
  }

  warning(message: string): void {
    console.log('SIM:WARNING:' + message);
    this.log += 'SIM:WARNING:' + message + '\n';
  }

  error(message: string): void {
    console.log('SIM:ERROR:' + message);
    this.log += 'SIM:ERROR:' + message + '\n';
  }
}

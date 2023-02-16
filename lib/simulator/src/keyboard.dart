/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

export class KeyboardKey {
  value = ''; // special values: "!BACKSPACE!", "!ENTER!"
  text = '';
  i = 0;
  j = 0;
  rows = 1;
  cols = 1;
}

export class KeyboardLayout {
  rows = 4;
  cols = 4;
  keys: KeyboardKey[] = [];

  constructor(numRows: number, numCols: number) {
    this.rows = numRows;
    this.cols = numCols;
    const n = this.rows * this.cols;
    for (let k = 0; k < n; k++) this.keys.push(null);
  }

  static parse(src: string): KeyboardLayout {
    // TODO: error checks
    const lines = src.split('\n');
    const rowData: string[][] = [];
    for (let line of lines) {
      line = line.trim();
      if (line.length == 0) continue;
      const tokens = line.split(' ');
      const row: string[] = [];
      for (let token of tokens) {
        token = token.trim();
        if (token.length > 0) row.push(token);
      }
      rowData.push(row);
    }
    const numRows = rowData.length;
    const numCols = rowData[0].length;
    const layout = new KeyboardLayout(numRows, numCols);
    const processedIndices: string[] = [];
    for (let i = 0; i < numRows; i++) {
      for (let j = 0; j < numCols; j++) {
        const data = rowData[i][j];
        const idx = '' + i + ',' + j;
        if (processedIndices.includes(idx)) continue;
        let rowSpan = 1;
        let colSpan = 1;
        for (let k = i; k < numRows; k++) {
          for (let l = j; l < numCols; l++) {
            const data2 = rowData[k][l];
            const idx2 = '' + k + ',' + l;
            if (data === data2) {
              processedIndices.push(idx2);
              if (k - i + 1 > rowSpan) rowSpan = k - i + 1;
              if (l - j + 1 > colSpan) colSpan = l - j + 1;
            }
          }
        }
        layout.addKey(i, j, rowSpan, colSpan, data);
        processedIndices.push(idx);
      }
    }
    return layout;
  }

  resize(numRowsNew: number, numColsNew: number): void {
    const keysNew: KeyboardKey[] = [];
    for (let k = 0; k < numRowsNew * numColsNew; k++) keysNew.push(null);
    for (let i = 0; i < numRowsNew; i++) {
      for (let j = 0; j < numColsNew; j++) {
        if (i >= this.rows || j >= this.cols) continue;
        keysNew[i * numColsNew + j] = this.keys[i * this.cols + j];
      }
    }
    this.rows = numColsNew;
    this.cols = numColsNew;
    this.keys = keysNew;
  }

  addKey(
    rowIndex: number,
    columnIndex: number,
    rowSpan: number,
    columnSpan: number,
    value: string,
  ): void {
    const key = new KeyboardKey();
    this.keys[rowIndex * this.cols + columnIndex] = key;
    key.i = rowIndex;
    key.j = columnIndex;
    key.rows = rowSpan;
    key.cols = columnSpan;
    key.value = value;
    switch (value) {
      case '*':
        key.text = '&bullet;';
        break;
      case '!B': // backspace
        key.text = '<i class="fa-solid fa-delete-left"></i>';
        break;
      case '!E': // enter
        key.text = '<i class="fa-solid fa-check-double"></i>';
        break;
      case 'pi':
        key.text = '&pi;';
        break;
      default:
        key.text = value;
    }
  }

  removeKey(rowIndex: number, columnIndex: number): void {
    this.keys[rowIndex * this.cols + columnIndex] = null;
  }
}

export class Keyboard {
  private parent: HTMLElement = null;

  private inputText = '';
  private inputTextHTMLElement: HTMLSpanElement = null;
  private solutionHTMLElement: HTMLSpanElement = null;

  private listener: (text: string) => void;

  constructor(parent: HTMLElement) {
    this.parent = parent;
  }

  hide(): void {
    this.parent.style.display = 'none';
  }

  setInputText(inputText: string): void {
    this.inputText = inputText;
  }

  setSolutionText(solution: string): void {
    if (this.solutionHTMLElement == null) {
      console.log('called Keyboard.setSolutionText(..) before show()');
      return;
    }
    this.solutionHTMLElement.innerHTML = solution;
  }

  setListener(fct: (text: string) => void): void {
    this.listener = fct;
  }

  show(layout: KeyboardLayout, showPreview: boolean): void {
    this.parent.innerHTML = '';
    // div row
    let row = document.createElement('div');
    row.classList.add('row');
    this.parent.appendChild(row);
    // div column
    let col = document.createElement('div');
    row.appendChild(col);
    col.classList.add('col', 'text-center');
    // typed input
    this.inputTextHTMLElement = document.createElement('span');
    this.inputTextHTMLElement.innerHTML = this.inputText;
    this.inputTextHTMLElement.style.color = 'white';
    this.inputTextHTMLElement.style.fontSize = '18pt';
    //this.inputTextHTMLElement.style.borderBottomStyle = 'solid';
    //this.inputTextHTMLElement.style.borderColor = 'white';
    //this.inputTextHTMLElement.style.borderWidth = '2px';
    this.inputTextHTMLElement.style.marginTop = '8px';
    this.inputTextHTMLElement.style.paddingLeft = '3px';
    this.inputTextHTMLElement.style.paddingRight = '3px';
    col.appendChild(this.inputTextHTMLElement);
    if (showPreview == false) {
      const br = document.createElement('br');
      col.appendChild(br);
      this.inputTextHTMLElement.style.display = 'none';
    }
    // table
    const table = document.createElement('table');
    table.style.margin = '0 auto';
    table.style.padding = '0 0 0 0';
    const cells: HTMLTableCellElement[] = [];
    for (let i = 0; i < layout.rows; i++) {
      const tr = document.createElement('tr');
      table.appendChild(tr);
      for (let j = 0; j < layout.cols; j++) {
        const key = layout.keys[i * layout.cols + j];
        if (key == null) continue;
        const td = document.createElement('td');
        cells.push(td);
        tr.appendChild(td);
        td.style.backgroundColor = 'white';
        td.style.borderRadius = '6px';
        td.style.borderWidth = '4px';
        td.style.borderStyle = 'solid';
        td.style.borderColor = '#b1c752';
        td.style.color = '#b1c752';
        td.style.paddingLeft = '7px';
        td.style.paddingTop = '0px';
        td.style.paddingRight = '7px';
        td.style.paddingBottom = '0px';
        td.style.minWidth = '32px';
        //td.style.maxHeight = '14px';
        td.style.fontSize = '17pt';
        td.style.cursor = 'crosshair';
        if (key.rows > 1) td.rowSpan = key.rows;
        if (key.cols > 1) td.colSpan = key.cols;
        td.innerHTML = key.text;
        {
          const _value = key.value;
          td.addEventListener('click', () => {
            switch (_value) {
              case '!B': // backspace
                if (this.inputText.length > 0) {
                  this.inputText = this.inputText.substring(
                    0,
                    this.inputText.length - 1,
                  );
                }
                break;
              case '!E': // enter
                this.hide();
                break;
              default:
                this.inputText += _value;
            }
            this.listener(this.inputText);
            this.inputTextHTMLElement.innerHTML = this.inputText;
          });
        }
      }
    }
    col.appendChild(table);
    // solution preview (for debugging purposes)
    row = document.createElement('div');
    row.classList.add('row');
    this.parent.appendChild(row);
    col = document.createElement('div');
    col.classList.add('col', 'text-start');
    row.appendChild(col);
    this.solutionHTMLElement = document.createElement('span');
    this.solutionHTMLElement.innerHTML = '';
    this.solutionHTMLElement.style.marginTop = '0pt';
    this.solutionHTMLElement.style.paddingTop = '0pt';
    this.solutionHTMLElement.style.fontSize = '11pt';
    this.solutionHTMLElement.style.color = 'white';
    col.appendChild(this.solutionHTMLElement);
    // make keyboard visible
    this.parent.style.display = 'block';
  }
}

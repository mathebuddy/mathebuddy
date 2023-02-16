/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// code in this file was partly taken from
// https://codesandbox.io/s/vwffw?file=/index.js

import { mathjax } from 'mathjax-full/js/mathjax';
import { TeX } from 'mathjax-full/js/input/tex';
import { SVG } from 'mathjax-full/js/output/svg';
import { RegisterHTMLHandler } from 'mathjax-full/js/handlers/html';
import { AllPackages } from 'mathjax-full/js/input/tex/AllPackages';
import { LiteAdaptor } from 'mathjax-full/js/adaptors/liteAdaptor';
import { MathDocument } from 'mathjax-full/js/core/MathDocument.js';

export class MathJax {
  adaptor: LiteAdaptor = null;
  html: MathDocument<any, any, any> = null;

  constructor() {
    this.adaptor = new LiteAdaptor();
    RegisterHTMLHandler(this.adaptor);
    this.html = mathjax.document('', {
      InputJax: new TeX({ packages: AllPackages }),
      OutputJax: new SVG({ fontCache: 'none' }),
    });
  }

  /*convertHTML(htmlIn: string): string {
    let htmlOut = '';
    let eqn = '';
    let isEqn = false;
    const n = htmlIn.length;
    for (let i = 0; i < n; i++) {
      const ch = htmlIn[i];
      const ch2 = i + 1 < n ? htmlIn[i + 1] : '';
      if (ch == '\\' && ch2 == '(') {
        isEqn = true;
        i++;
        continue;
      } else if (ch == '\\' && ch2 == ')') {
        isEqn = false;
        i++;
        if (eqn.length > 0) {
          htmlOut += this.tex2svgInline(eqn);
        }
        eqn = '';
        continue;
      }
      if (isEqn) eqn += ch;
      else htmlOut += ch;
    }
    return htmlOut;
  }*/

  addMacros(equation: string): string {
    return (
      '\\def\\RR{\\mathbb{R}}' +
      '\\def\\NN{\\mathbb{N}}' +
      '\\def\\ZZ{\\mathbb{Z}}' +
      '\\def\\CC{\\mathbb{C}}' +
      '\\def\\QQ{\\mathbb{Q}}' +
      '\\newcommand{\\mat}[1]{\\begin{pmatrix}#1\\end{pmatrix}}' +
      equation
    );
  }

  tex2svgInline(equation: string): string {
    equation = this.addMacros(equation);
    return this.adaptor.innerHTML(
      this.html.convert(equation, { display: false }),
    );
  }

  tex2svgBlock(equation: string): string {
    equation = this.addMacros(equation);
    return this.adaptor.innerHTML(
      this.html.convert(equation, { display: true }),
    );
  }
}

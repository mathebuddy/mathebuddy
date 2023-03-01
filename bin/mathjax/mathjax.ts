/**
 * mathe:buddy - eine gamifizierte Lern-App für die Hoehere Mathematik
 * (c) 2022 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// code in this file was partly taken from
// https://codesandbox.io/s/vwffw?file=/index.js

import { mathjax } from "mathjax-full/js/mathjax";
import { TeX } from "mathjax-full/js/input/tex";
import { SVG } from "mathjax-full/js/output/svg";
import { RegisterHTMLHandler } from "mathjax-full/js/handlers/html";
import { AllPackages } from "mathjax-full/js/input/tex/AllPackages";
import { LiteAdaptor } from "mathjax-full/js/adaptors/liteAdaptor";
import { MathDocument } from "mathjax-full/js/core/MathDocument.js";

export class MathJax {
  adaptor: LiteAdaptor;
  html: MathDocument<any, any, any>;

  constructor() {
    this.adaptor = new LiteAdaptor();
    RegisterHTMLHandler(this.adaptor);
    this.html = mathjax.document("", {
      InputJax: new TeX({ packages: AllPackages }),
      OutputJax: new SVG({ fontCache: "none" }),
    });
  }

  tex2svgInline(equation: string): string {
    return this.adaptor.innerHTML(
      this.html.convert(equation, { display: false })
    );
  }

  tex2svgBlock(equation: string): string {
    return this.adaptor.innerHTML(
      this.html.convert(equation, { display: true })
    );
  }
}

/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { MBL_BlockItem } from './dataBlock';
import { MBL_Equation } from './dataEquation';
import { JSONValue } from './dataJSON';
import { MBL_Text } from './dataText';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- DEFINITION --------

export enum MBL_DefinitionType {
  Definition = 'definition',
  Theorem = 'theorem',
  Lemma = 'lemma',
  Corollary = 'corollary',
  Proposition = 'proposition',
  Conjecture = 'conjecture',
  Axiom = 'axiom',
  Claim = 'claim',
  Identity = 'identity',
  Paradox = 'paradox',
}

export class MBL_Definition extends MBL_BlockItem {
  type: MBL_DefinitionType;
  items: (MBL_Equation | MBL_Text)[] = [];
  constructor(type: MBL_DefinitionType) {
    super();
    this.type = type;
  }
  postProcess(): void {
    for (const i of this.items) i.postProcess();
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      title: this.title,
      label: this.label,
      error: this.error,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

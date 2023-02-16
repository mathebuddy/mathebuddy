/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { MBL_BlockItem } from './dataBlock';
import { JSONValue } from './dataJSON';
import { MBL_Text, MBL_Text_Text } from './dataText';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- FIGURE --------

export class MBL_Figure extends MBL_BlockItem {
  type = 'figure';
  filePath = '';
  data = '';
  caption: MBL_Text = new MBL_Text_Text();
  options: MBL_Figure_Option[] = [];
  postProcess(): void {
    // TODO
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      title: this.title,
      label: this.label,
      error: this.error,
      file_path: this.filePath,
      data: this.data,
      caption: this.caption.toJSON(),
      options: this.options.map((option) => '' + option),
    };
  }
}

export enum MBL_Figure_Option {
  Width25 = 'width-25',
  Width33 = 'width-33',
  Width50 = 'width-50',
  Width66 = 'width-66',
  Width75 = 'width-75',
  Width100 = 'width-100',
}

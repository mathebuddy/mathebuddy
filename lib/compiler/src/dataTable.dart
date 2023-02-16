/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { MBL_BlockItem } from './dataBlock';
import { JSONValue } from './dataJSON';
import { MBL_Text } from './dataText';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- TABLE --------

export class MBL_Table extends MBL_BlockItem {
  type = 'table';
  head: MBL_Table_Row = new MBL_Table_Row();
  rows: MBL_Table_Row[] = [];
  options: MBL_Table_Option[] = [];
  postProcess(): void {
    this.head.postProcess();
    for (const row of this.rows) row.postProcess();
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      title: this.title,
      label: this.label,
      error: this.error,
      head: this.head.toJSON(),
      rows: this.rows.map((row) => row.toJSON()),
      options: this.options.map((option) => option.toString()),
    };
  }
}

export class MBL_Table_Row {
  columns: MBL_Text[] = [];
  postProcess(): void {
    for (const column of this.columns) column.postProcess();
  }
  toJSON(): JSONValue {
    return {
      columns: this.columns.map((column) => column.toJSON()),
    };
  }
}

export enum MBL_Table_Option {
  AlignLeft = 'align_left',
  AlignCenter = 'align_center',
  AlignRight = 'align_right',
}

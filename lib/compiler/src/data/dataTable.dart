/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataBlock.dart';
import 'dataText.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- TABLE --------

class MBL_Table extends MBL_BlockItem {
  String type = 'table';
  MBL_Table_Row head = new MBL_Table_Row();
  List<MBL_Table_Row> rows = [];
  List<MBL_Table_Option> options = [];

  void postProcess() {
    this.head.postProcess();
    for (var i = 0; i < this.rows.length; i++) {
      var row = this.rows[i];
      row.postProcess();
    }
  }

  Map<String, Object> toJSON() {
    return {
      "type": this.type,
      "title": this.title,
      "label": this.label,
      "error": this.error,
      "head": this.head.toJSON(),
      "rows": this.rows.map((row) => row.toJSON()),
      "options": this.options.map((option) => option.toString()),
    };
  }
}

class MBL_Table_Row {
  List<MBL_Text> columns = [];

  void postProcess() {
    for (var i = 0; i < this.columns.length; i++) {
      var column = this.columns[i];
      column.postProcess();
    }
  }

  Map<String, Object> toJSON() {
    return {
      "columns": this.columns.map((column) => column.toJSON()),
    };
  }
}

enum MBL_Table_Option {
  AlignLeft,
  AlignCenter,
  AlignRight,
}

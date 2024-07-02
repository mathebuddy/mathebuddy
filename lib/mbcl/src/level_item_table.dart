/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'level_item.dart';

class MbclTableData {
  MbclLevelItem table;
  MbclTableRow head;
  List<MbclTableRow> rows = [];
  List<MbclTableOption> options = [];

  MbclTableData(this.table) : head = MbclTableRow(table);

  Map<String, dynamic> toJSON() {
    return {
      "head": head.toJSON(),
      "rows": rows.map((e) => e.toJSON()).toList(),
      "options": options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    head = MbclTableRow(table);
    head.fromJSON(src["head"]);
    rows = [];
    int n = src["rows"].length;
    for (var i = 0; i < n; i++) {
      var row = MbclTableRow(table);
      row.fromJSON(src["rows"][i]);
      rows.add(row);
    }
    options = [];
    n = src["options"].length;
    for (var i = 0; i < n; i++) {
      options.add(MbclTableOption.values.byName(src["options"][i]));
    }
  }
}

class MbclTableRow {
  MbclLevelItem table;
  List<MbclLevelItem> columns = [];

  MbclTableRow(this.table);

  Map<String, dynamic> toJSON() {
    return {"columns": columns.map((e) => e.toJSON()).toList()};
  }

  fromJSON(Map<String, dynamic> src) {
    columns = [];
    int n = src["columns"].length;
    for (var i = 0; i < n; i++) {
      var column = MbclLevelItem(table.level, MbclLevelItemType.error, -1);
      column.fromJSON(src["columns"][i]);
      columns.add(column);
    }
  }
}

enum MbclTableOption {
  alignLeft,
  alignCenter,
  alignRight,
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'parse.dart';
import 'term.dart';

Map<num, Term> table = {};

// TODO: extend table!
void _createTable() {
  var parser = Parser();

  var testxxx = parser.parse("1/3", splitIdentifiers: false);
  var testyyy = testxxx.eval({});

  var list = ["sqrt(2)/2", "sqrt(3)/2", "1/2", "1/3"];
  for (var i = 0; i < 2; i++) {
    for (var j = 0; j < list.length; j++) {
      var str = list[j];
      if (i == 1) str = "-$str";
      var term = parser.parse(str, splitIdentifiers: false);
      var value = term.eval({}).real / term.eval({}).denominator;
      table[value] = term;
    }
  }
  //print(table);
  var bp = 1337;
}

Term? number2Term(num x) {
  var eps = 1e-14; // TODO
  if (table.isEmpty) {
    _createTable();
  }
  // TODO: this is slow...
  for (var value in table.keys) {
    if ((x - value).abs() < eps) {
      return table[value];
    }
  }
  return null;
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'level_item.dart';

class MbclEquationData {
  MbclLevelItem equation;
  MbclLevelItem? math;
  int number = 0;
  bool leftAligned = false;

  MbclEquationData(this.equation);

  Map<String, dynamic> toJSON() {
    return {
      "math": math?.toJSON(),
      "number": number,
      "leftAligned": leftAligned,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    math = MbclLevelItem(equation.level, MbclLevelItemType.error, -1);
    math?.fromJSON(src["math"]);
    number = src["number"];
    leftAligned = src["leftAligned"] as bool;
  }
}

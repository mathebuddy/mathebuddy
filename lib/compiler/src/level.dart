/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/level.dart';

class MBCL_Level extends MBCL_Level__ABSTRACT {
  @override
  void postProcess() {
    for (var i = 0; i < this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
  }
}

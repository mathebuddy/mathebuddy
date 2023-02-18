/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataLevel.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

class MBL_NewPage extends MBL_LevelItem {
  MBL_NewPage() : super(MBL_LevelItemType.NewPage);

  void postProcess() {
    /* empty */
  }

  Map<String, Object> toJSON() {
    return {
      "type": this.type,
    };
  }
}

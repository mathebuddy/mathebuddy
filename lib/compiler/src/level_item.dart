/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../mbcl/src/level_item.dart';

class MBCL_LevelItem extends MBCL_LevelItem__ABSTRACT {
  MBCL_LevelItem(MBCL_LevelItemType type, [text = '']) : super(type) {
    this.text = text;
  }

  @override
  void postProcess() {
    // TODO: implement postProcess
  }
}

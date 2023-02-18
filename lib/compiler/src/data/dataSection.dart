/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataLevel.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- SECTION --------

enum MBL_SectionType {
  Section,
  SubSection,
  SubSubSection,
}

class MBL_Section extends MBL_LevelItem {
  MBL_SectionType subType;
  String text = '';
  String label = '';

  MBL_Section(this.subType) : super(MBL_LevelItemType.Section);

  void postProcess() {
    /* empty */
  }

  Map<String, Object> toJSON() {
    return {
      "type": this.type,
      "subType": this.subType,
      "text": this.text,
      "label": this.label,
    };
  }
}

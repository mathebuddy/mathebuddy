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

// -------- FIGURE --------

class MBL_Figure extends MBL_BlockItem {
  String type = 'figure';
  String filePath = '';
  String data = '';
  MBL_Text caption = new MBL_Text_Text();
  List<MBL_Figure_Option> options = [];

  void postProcess() {
    // TODO
  }

  Map<String, Object> toJSON() {
    return {
      "type": this.type,
      "title": this.title,
      "label": this.label,
      "error": this.error,
      "file_path": this.filePath,
      "data": this.data,
      "caption": this.caption.toJSON(),
      "options": this.options.map((option) => '' + option.name),
    };
  }
}

enum MBL_Figure_Option {
  Width25,
  Width33,
  Width50,
  Width66,
  Width75,
  Width100,
}

/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataBlock.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- ERROR --------

class MBL_Error extends MBL_BlockItem {
  String type = 'error';
  String message = '';

  MBL_Error();

  void postProcess() {
    /* empty */
  }

  Map<Object, Object> toJSON() {
    return {
      type: this.type,
      title: this.title,
      label: this.label,
      error: this.error,
      message: this.message,
    };
  }
}

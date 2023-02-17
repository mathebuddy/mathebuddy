/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:html';

void setTextInput(String elementId, String value) {
  (document.getElementById(elementId) as InputElement).value = value;
}

void setTextArea(String id, String value) {
  (document.getElementById(id) as TextAreaElement).value = value;
}

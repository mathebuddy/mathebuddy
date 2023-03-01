/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

class TeXNode {
  bool isList;
  List<TeXNode> items = [];
  String tk = '';
  TeXNode? sub = null;
  TeXNode? sup = null;

  double scaling = 1.0;
  int x = 0;
  int y = 0;
  int width = 0;
  int height = 0;
  String svgPathId = '';

  TeXNode(this.isList, this.items);

  @override
  String toString() {
    if (isList) {
      var s = '{';
      for (var i = 0; i < items.length; i++) {
        if (i > 0) s += ' ';
        var item = items[i];
        s += item.toString();
      }
      s += '}';
      return s;
    } else {
      var s = tk;
      if (this.sub != null) {
        s += '_' + this.sub.toString();
      }
      if (this.sup != null) {
        s += '^' + this.sup.toString();
      }
      return s;
    }
  }
}

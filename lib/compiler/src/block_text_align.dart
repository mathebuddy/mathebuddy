/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'block.dart';

MbclLevelItem processTextAlign(Block block, MbclLevelItemType type) {
  var align = MbclLevelItem(type);
  for (var part in block.parts) {
    switch (part.name) {
      case 'global':
        align.items
            .addAll(block.compiler.parseParagraph(part.lines.join("\n")));
        break;
      default:
        align.error += 'Unexpected part "${part.name}".';
    }
  }
  block.processSubblocks(align);
  return align;
}

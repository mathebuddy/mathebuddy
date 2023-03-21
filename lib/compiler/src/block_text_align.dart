/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'block.dart';

MbclLevelItem processTextAlign(Block block, MbclLevelItemType type) {
  var align = MbclLevelItem(type);
  for (var blockItem in block.items) {
    if (blockItem.type == BlockItemType.subBlock) {
      block.processSubblock(align, blockItem.subBlock!);
      continue;
    }
    var part = blockItem.part!;
    switch (part.name) {
      case 'global':
        align.items
            .addAll(block.compiler.parseParagraph(part.lines.join("\n")));
        break;
      default:
        align.error += 'Unexpected part "${part.name}".';
    }
  }
  return align;
}

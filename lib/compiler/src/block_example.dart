/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'block.dart';

MbclLevelItem processExample(Block block) {
  var example = MbclLevelItem(MbclLevelItemType.example);
  example.title = block.title;
  example.label = block.label;
  for (var blockItem in block.items) {
    if (blockItem.type == BlockItemType.subBlock) {
      block.processSubblock(example, blockItem.subBlock!);
      continue;
    }
    var part = blockItem.part!;
    switch (part.name) {
      case 'global':
        example.items
            .addAll(block.compiler.parseParagraph(part.lines.join("\n")));
        break;
      default:
        example.error += 'Unexpected part "${part.name}".';
    }
  }
  return example;
}

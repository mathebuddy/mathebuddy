/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'block.dart';

MbclLevelItem processTable(Block block) {
  int i;
  var table = MbclLevelItem(MbclLevelItemType.table, block.srcLine);
  var data = MbclTableData();
  table.tableData = data;
  table.title = block.title;
  for (var blockItem in block.items) {
    if (blockItem.type == BlockItemType.subBlock) {
      block.processSubblock(table, blockItem.subBlock!);
      continue;
    }
    var part = blockItem.part!;
    switch (part.name) {
      case 'global':
        if (part.lines.join('\n').trim().isNotEmpty) {
          table.error += 'Some of your code '
              '("${part.lines.join('\n').trim().substring(0, 10)}...")'
              ' is not inside a tag (e.g. "@code" or "@text").';
        }
        break;
      case 'options':
        for (var line in part.lines) {
          line = line.trim();
          if (line.isEmpty) continue;
          switch (line) {
            case 'align-left':
              data.options.add(MbclTableOption.alignLeft);
              break;
            case 'align-center':
              data.options.add(MbclTableOption.alignCenter);
              break;
            case 'align-right':
              data.options.add(MbclTableOption.alignRight);
              break;
            default:
              table.error += 'Unknown option "$line".';
          }
        }
        break;
      case 'text':
        i = 0;
        for (var line in part.lines) {
          line = line.trim();
          // TODO: "&" may also be used in math-mode!!
          var columnStrings = line.split('&');
          var row = MbclTableRow();
          if (i == 0) {
            data.head = row;
          } else {
            data.rows.add(row);
          }
          for (var columnString in columnStrings) {
            var columnText = block.compiler.parseParagraph(columnString);
            if (columnText.length != 1 ||
                columnText[0].type != MbclLevelItemType.paragraph) {
              table.error += 'Table cell is not pure text.';
              row.columns
                  .add(MbclLevelItem(MbclLevelItemType.text, -1, 'error'));
            } else {
              row.columns.add(columnText[0]);
            }
          }
          i++;
        }
        break;
      default:
        table.error += 'Unexpected part "${part.name}".';
        break;
    }
  }
  return table;
}

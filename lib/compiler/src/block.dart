/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import '../../mbcl/src/level_item.dart';

import 'compiler.dart';

import 'block_definition.dart';
import 'block_equation.dart';
import 'block_example.dart';
import 'block_exercise.dart';
import 'block_figure.dart';
import 'block_table.dart';
import 'block_text_align.dart';
import 'block_text.dart';

/*
---
EXAMPLE Addition of complex numbers @ex:myExample
@options
blub
EQUATION
z_1=1+3i ~~ z_2=2+4i ~~ z_1+z_2=3+7i
---
*/

class BlockPart {
  String name = '';
  List<String> lines = [];
}

class Block {
  String type = '';
  String title = '';
  String label = '';
  List<BlockPart> parts = []; // e.g. "@options ..."
  List<Block> subBlocks = []; // e.g. "EQUATION ..."
  int srcLine = 0;
  List<MbclLevelItem> levelItems = [
    MbclLevelItem(MbclLevelItemType.error, 'Block unprocessed.')
  ];
  final Compiler compiler;

  Block(this.compiler);

  void process() {
    switch (type) {
      case 'DEFINITION':
        levelItems = [processDefinition(this, MbclLevelItemType.defDefinition)];
        break;
      case 'THEOREM':
        levelItems = [processDefinition(this, MbclLevelItemType.defTheorem)];
        break;
      case 'LEMMA':
        levelItems = [processDefinition(this, MbclLevelItemType.defLemma)];
        break;
      case 'COROLLARY':
        levelItems = [processDefinition(this, MbclLevelItemType.defCorollary)];
        break;
      case 'PROPOSITION':
        levelItems = [
          processDefinition(this, MbclLevelItemType.defProposition)
        ];
        break;
      case 'CONJECTURE':
        levelItems = [processDefinition(this, MbclLevelItemType.defConjecture)];
        break;
      case 'AXIOM':
        levelItems = [processDefinition(this, MbclLevelItemType.defAxiom)];
        break;
      case 'CLAIM':
        levelItems = [processDefinition(this, MbclLevelItemType.defClaim)];
        break;
      case 'IDENTITY':
        levelItems = [processDefinition(this, MbclLevelItemType.defIdentity)];
        break;
      case 'PARADOX':
        levelItems = [processDefinition(this, MbclLevelItemType.defParadox)];
        break;
      case 'LEFT':
        levelItems = [processTextAlign(this, MbclLevelItemType.alignLeft)];
        break;
      case 'CENTER':
        levelItems = [processTextAlign(this, MbclLevelItemType.alignCenter)];
        break;
      case 'RIGHT':
        levelItems = [processTextAlign(this, MbclLevelItemType.alignRight)];
        break;
      case 'EQUATION':
        levelItems = [processEquation(this, true)];
        break;
      case 'EQUATION*':
        levelItems = [processEquation(this, false)];
        break;
      case 'EXAMPLE':
        levelItems = [
          processExample(
            this,
          )
        ];
        break;
      case 'EXERCISE':
        levelItems = [processExercise(this)];
        break;
      case 'TEXT':
        levelItems = processText(this);
        break;
      case 'TABLE':
        levelItems = [processTable(this)];
        break;
      case 'FIGURE':
        levelItems = [processFigure(this)];
        break;
      case 'NEWPAGE':
        levelItems = [MbclLevelItem(MbclLevelItemType.newPage)];
        break;
      default:
        levelItems = [
          MbclLevelItem(MbclLevelItemType.error, 'Unknown block type "$type".')
        ];
    }
  }

  void processSubblocks(MbclLevelItem item) {
    for (var sub in subBlocks) {
      sub.process();
      var type = item.type;
      if (type.name.startsWith('def')) type = MbclLevelItemType.defDefinition;
      if (mbclSubBlockWhiteList.containsKey(type) &&
          (mbclSubBlockWhiteList[type] as List<MbclLevelItemType>)
              .contains(sub.levelItems[0].type)) {
        item.items.addAll(sub.levelItems);
      } else {
        item.error += 'Error: Subblock type ${sub.levelItems[0].type.name}'
            ' is not allowed for ${type.name}! ';
      }
    }
  }
}

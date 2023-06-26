/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// import 'package:slex/slex.dart';

// import '../../mbcl/src/level_item.dart';

// import 'block.dart';
// import 'math.dart';

// MbclLevelItem processEquation(
//     Block block, bool numbering, MbclLevelItem? exercise) {
//   var aligned = block.type.startsWith("ALIGNED-");

//   var equation = MbclLevelItem(MbclLevelItemType.equation, block.srcLine);
//   var data = MbclEquationData();
//   equation.equationData = data;
//   var equationNumber = "-1";
//   if (numbering) {
//     equationNumber = block.compiler.equationNumber.toString();
//     block.compiler.equationNumber++;
//   }
//   equation.id = equationNumber;
//   equation.title = block.title;
//   equation.label = block.label;
//   for (var blockItem in block.items) {
//     if (blockItem.type == BlockItemType.subBlock) {
//       block.processSubblock(equation, blockItem.subBlock!);
//       continue;
//     }
//     var part = blockItem.part!;
//     switch (part.name) {
//       /*case 'options':
//         for (var line in part.lines) {
//           line = line.trim();
//           if (line.isEmpty) continue;
//           switch (line) {
//             case 'aligned':
//               //data.options.add(MbclEquationOption.aligned);
//               aligned = true;
//               break;
//             default:
//               equation.error += 'Unknown option "$line".';
//           }
//         }
//         break;*/
//       case 'global':
//       case 'text':
//         {
//           List<String> nonEmptyLines = [];
//           for (var line in part.lines) {
//             if (line.trim().isEmpty) continue;
//             nonEmptyLines.add(line);
//           }
//           equation.text += nonEmptyLines.join('\n');
//           if (aligned) {
//             equation.text = '\\begin{matrix}[ll]${equation.text}\\end{matrix}';
//           }
//         }
//         break;
//       default:
//         equation.error += 'Unexpected part "${part.name}".';
//         break;
//     }
//   }
//   // compile math
//   var lexer = Lexer();
//   lexer.pushSource('', equation.text);
//   data.math = parseInlineMath(lexer, exercise);
//   data.math!.type = MbclLevelItemType.displayMath;
//   equation.text = '';

//   return equation;
// }

/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'math-runtime-playground.dart' as mathPlay;
import 'smpl-playground.dart' as smplPlay;
import 'mbl-playground.dart' as mblPlay;
import 'tex-playground.dart' as texPlay;
import 'sim.dart' as sim;

void main() async {
  mathPlay.mathRuntimePlayground();
  smplPlay.smplPlayground();
  mblPlay.mblPlayground();
  texPlay.texPlayground();
  sim.init();
  //var files = await getFilesFromDir('demo/');
  //print(files.toString());
}

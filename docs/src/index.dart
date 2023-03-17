/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'chat_playground.dart' as chat_play;
import 'math_runtime_playground.dart' as math_play;
import 'mbl_playground.dart' as mbl_play;
import 'sim.dart' as sim;
import 'smpl_playground.dart' as smpl_play;
import 'tex_playground.dart' as tex_play;

void main() async {
  math_play.mathRuntimePlayground();
  smpl_play.smplPlayground();
  mbl_play.mblPlayground();
  tex_play.texPlayground();
  chat_play.chatPlayground();
  sim.init();
}

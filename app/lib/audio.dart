/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements audio feedback.

library mathe_buddy_app;

import 'package:audioplayers/audioplayers.dart';

enum AppAudioId {
  passedExercise,
  failedExercise,
}

class AppAudio {
  static void play(AppAudioId id) async {
    var player = AudioPlayer();
    switch (id) {
      case AppAudioId.passedExercise:
        await player.setSource(AssetSource("sfx/pass.wav"));
        await player.resume();
        break;
      case AppAudioId.failedExercise:
        await player.setSource(AssetSource("sfx/fail.wav"));
        await player.resume();
        break;
    }
  }
}

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements audio feedback.

// TODO: Android-bug: https://github.com/bluefireteam/audioplayers/issues/1706

import 'package:audioplayers/audioplayers.dart';

var appAudio = AppAudio();

enum AppAudioId {
  passedExercise,
  failedExercise,
}

class AppAudio {
  AudioPlayer? audioPlayerPass;
  AudioPlayer? audioPlayerFail;

  /// The initialization must be triggered AFTER a button press.
  /// Otherwise, web browsers reject to play audio.
  initAfterButtonPress() {
    if (audioPlayerPass == null) {
      audioPlayerPass = AudioPlayer();
      audioPlayerFail = AudioPlayer();
      audioPlayerPass!.setSource(AssetSource("sfx/pass.wav"));
      audioPlayerFail!.setSource(AssetSource("sfx/fail.wav"));
    }
  }

  void play(AppAudioId id) async {
    if (audioPlayerPass == null || audioPlayerFail == null) {
      print("ERROR: cannot play audio, since it was not initialized before!");
      return;
    }
    switch (id) {
      case AppAudioId.passedExercise:
        {
          await audioPlayerPass!.stop();
          await audioPlayerPass!.resume();
          //var xx = AudioPlayer();
          //xx.play(AssetSource("sfx/pass.wav"));
          break;
        }
      case AppAudioId.failedExercise:
        {
          await audioPlayerFail!.stop();
          await audioPlayerFail!.resume();
          break;
        }
    }
  }
}

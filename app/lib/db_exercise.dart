/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

library mathe_buddy_app;

import 'package:mathebuddy/main.dart';

var textFeedbackOK = {
  "en": ["well done", "awesome", "great"],
  "de": ["gut gemacht", "super", "awesome", "toll", "weiter so"]
};

var textFeedbackERR = {
  "en": ["try again", "no", "incorrect"],
  "de": ["versuch's nochmal", "leider falsch", "nicht richtig"]
};

var iconsFeedbackOK = [
  "hand-clap",
  "emoticon-happy-outline",
  "check-outline",
  "heart-outline"
];

var iconsFeedbackERR = ["emoticon-sad-outline", "emoticon-cry-outline"];

String getFeedbackText(bool ok) {
  if (ok) {
    return (textFeedbackOK[language]!.toList()..shuffle()).first;
  } else {
    return (textFeedbackERR[language]!.toList()..shuffle()).first;
  }
}

String getFeedbackIcon(bool ok) {
  if (ok) {
    return (iconsFeedbackOK.toList()..shuffle()).first;
  } else {
    return (iconsFeedbackERR.toList()..shuffle()).first;
  }
}

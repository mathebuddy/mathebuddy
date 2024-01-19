import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/mbcl/src/award.dart';

/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

var awardsDatabase = {
  "3-days-in-row": {
    "en": "Trained 3 days in a row",
    "de": "3 Tage hintereinander geübt"
  },
  "5-days-in-row": {
    "en": "Trained 5 days in a row",
    "de": "5 Tage hintereinander geübt"
  },
  "10-days-in-row": {
    "en": "Trained 10 days in a row",
    "de": "10 Tage hintereinander geübt"
  },
};

List<MbclAward> _awardList = [];

List<MbclAward> getAwardList() {
  if (_awardList.isEmpty) {
    for (var awardId in awardsDatabase.keys) {
      var awardTextEn = awardsDatabase[awardId]!["en"]!;
      var awardTextDe = awardsDatabase[awardId]!["de"]!;
      _awardList.add(MbclAward(awardId, awardTextEn, awardTextDe, null));
    }
  }
  return _awardList;
}

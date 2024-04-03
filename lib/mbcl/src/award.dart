/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

enum MbclAwardType {
  passedFirstLevel,
  passedFirstUnit,
  passedFirstChapter,
  passedFirstGame,
  played3daysInRow,
  played5daysInRow,
  played10daysInRow,
}

class MbclAwards {
  // <AwardId, UnixTime>  time is 0 in case the award is not yet received
  Map<String, int> awards = {};

  // list of awards that have not yet been shown as popup
  List<MbclAwardType> notShownAwards = [];

  MbclAwards() {
    for (var type in MbclAwardType.values) {
      awards[type.name] = 0;
    }
  }

  Map<String, dynamic> toJSON() {
    return awards;
  }

  void removeAllAwards() {
    for (var key in awards.keys) {
      awards[key] = 0;
    }
  }

  bool isAwardEnabled(MbclAwardType type) {
    return awards.containsKey(type.name);
  }

  MbclAwardType? popNotShownAward() {
    if (notShownAwards.isNotEmpty) {
      var res = notShownAwards.last;
      notShownAwards.removeLast();
      return res;
    }
    return null;
  }

  /// returns true, if the award is new
  bool enableAwardConditionally(MbclAwardType type) {
    var alreadyAchieved = awards[type.name]! > 0;
    if (alreadyAchieved) return false;
    awards[type.name] = DateTime.now().millisecondsSinceEpoch;
    notShownAwards.add(type);
    return true;
  }

  fromJSON(Map<String, dynamic> src) {
    for (var entry in src.entries) {
      var awardId = entry.key;
      var unixTimeReceived = entry.value;
      if (awards.containsKey(awardId)) {
        awards[awardId] = unixTimeReceived;
      }
    }
  }

  getText(String id, String language) {
    switch (id) {
      case "passedFirstLevel":
        return language == "en"
            ? "Passed the first level"
            : "Erstes Level geschafft";
      case "passedFirstUnit":
        return language == "en"
            ? "Passed the first unit"
            : "Erste Unit geschafft";
      case "passedFirstChapter":
        return language == "en"
            ? "Passed the first chapter"
            : "Erstes Kapitel geschafft";
      case "passedFirstGame":
        return language == "en"
            ? "Played the first game"
            : "Erstes Spiel gespielt";
      case "played3daysInRow":
        return language == "en"
            ? "Trained 3 days in a row"
            : "3 Tage hintereinander gespielt";
      case "played5daysInRow":
        return language == "en"
            ? "Trained 5 days in a row"
            : "5 Tage hintereinander gespielt";
      case "played10daysInRow":
        return language == "en"
            ? "Trained 10 days in a row"
            : "10 Tage hintereinander gespielt";
      default:
        return "ERROR: UNIMPLEMENTED AWARD TEXT";
    }
  }
}

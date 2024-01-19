/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

class MbclAward {
  final String id;
  final String textEn;
  final String textDe;
  DateTime? dateTime; // null, if award was NOT earned

  MbclAward(this.id, this.textEn, this.textDe, this.dateTime);
}

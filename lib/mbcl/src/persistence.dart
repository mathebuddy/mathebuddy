/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mbcl;

abstract class MbclPersistence {
  MbclPersistence();
  Future<String> readFile(String localPath);
  void writeFile(String localPath, String data);
}

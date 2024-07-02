/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library math_runtime;

bool isInteger(num x) {
  var eps = 1e-14; // TODO
  if (x != double.infinity && x != double.negativeInfinity) {
    if (x is int || (x - x.round()).abs() < eps) {
      return true;
    }
  }
  return false;
}

int gcd(int x, int y) {
  while (y != 0) {
    var t = y;
    y = x % y;
    x = t;
  }
  return x;
}

bool isAlpha(String tk) {
  if (tk.isEmpty) return false;
  return tk.codeUnitAt(0) == '_'.codeUnitAt(0) ||
      (tk.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          tk.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
      (tk.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          tk.codeUnitAt(0) <= 'z'.codeUnitAt(0));
}

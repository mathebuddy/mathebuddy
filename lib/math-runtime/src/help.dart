/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

bool isInteger(num x) {
  var eps = 1e-14; // TODO
  if (x != double.infinity && x != double.negativeInfinity) {
    if (x is int || (x - x.round()).abs() < eps) {
      return true;
    }
  }
  return false;
}

/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

String extractDirname(String path) {
  if (path.contains('/') == false) return '';
  return path.substring(0, path.lastIndexOf('/') + 1);
}

/*void main() {
  var x = 'xyz/abc/def.ghi';
  x = 'def.ghi';
  var y = extractDirname(x);
  var bp = 1337;
}
*/

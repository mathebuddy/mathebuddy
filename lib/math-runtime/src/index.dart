/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'parse.dart';
import 'term.dart';

Term parse(String termSrc) {
  var parser = new Parser();
  return parser.parse(termSrc);
}

/*
void main() {
  var t = parse('x^2');
  print(t.toString());
}*/

/*export function compareTerms(
  t1Str: string,
  t2Str: string,
  epsilon = 1e-12,
): boolean {
  t1Str = t1Str.trim();
  t2Str = t2Str.trim();
  if (t1Str.length == 0 || t2Str.length == 0)
    throw new Error('One of the strings to compare is empty.');
  const parser = new Parser();
  const t1 = parser.parse(t1Str);
  const t2 = parser.parse(t2Str);
  return t1.compareNumerically(t2, epsilon);
}
*/

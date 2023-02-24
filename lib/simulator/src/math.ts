/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// TODO: only use mathebuddy-math-runtime for math!!

/*
export class MathIntSet {
  private values: number[] = [];

  //G intSet = "{" { INT } "}";
  parse(s: string): boolean {
    s = s.trim().replace('/ /g', '');
    if (s.length < 2) return false;
    if (s[0] != '{' || s[s.length - 1] != '}') return false;
    s = s.substring(1, s.length - 1);
    const v = s.split(',');
    for (const vi of v) this.values.push(parseInt(vi));
    console.log(this.values);
    return true;
  }

  compare(s: MathIntSet): boolean {
    if (this.values.length != s.values.length) return false;
    for (const u of this.values) {
      let found = false;
      for (const v of s.values) {
        if (u == v) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }
}

export function compareIntSets(a: string, b: string): boolean {
  const setA = new MathIntSet();
  if (setA.parse(a) == false) return false;
  const setB = new MathIntSet();
  if (setB.parse(b) == false) return false;
  return setA.compare(setB);
}
*/

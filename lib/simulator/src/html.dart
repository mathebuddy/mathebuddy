/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

export function htmlSafeString(s: string): string {
  s = s.replace(/</g, '&lt;');
  s = s.replace(/>/g, '&gt;');
  s = s.replace(/\n/g, '<br/>');
  s = s.replace(/ /g, '&nbsp;');
  s = s.replace(/"/g, '&quot;');
  s = s.replace(/'/g, '&#039;');
  return s;
}

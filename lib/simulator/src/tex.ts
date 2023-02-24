/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

/**
 * example: "[[1,2],[3,4]]" -> "\begin{pmatrix}1&2\\3&4\end{pmatrix}"
 * @param m
 * @returns
 */
export function matrix2tex(m: string): string {
  let tex = m.replace(/\],\[/g, '\\\\');
  tex = tex.replace(/,/g, '&');
  tex = tex.replace(/\[/g, '');
  tex = tex.replace(/\]/g, '');
  tex = '\\begin{pmatrix}' + tex + '\\end{pmatrix}';
  //console.log(m);
  //console.log(tex);
  return tex;
}

export function set2tex(s: string): string {
  const tex = s.replace(/{/g, '\\{').replace(/}/g, '\\}');
  return tex;
}

export function term2tex(t: string): string {
  if (t.startsWith('(') && t.endsWith(')')) t = t.substring(1, t.length - 1);
  let tex = t.replace(/\*/g, ' \\cdot ');
  tex = tex.replace(/sin\(/g, '\\sin(');
  tex = tex.replace(/cos\(/g, '\\cos(');
  tex = tex.replace(/tan\(/g, '\\tan(');
  tex = tex.replace(/exp\(/g, '\\exp(');
  tex = tex.replace(/\{/g, '\\{');
  tex = tex.replace(/\}/g, '\\}');
  return tex;
}

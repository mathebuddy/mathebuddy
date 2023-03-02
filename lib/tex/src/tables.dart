/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

const Map<String, int> numArgs = {"\\frac": 2, "\\mathbb": 1, "\\mathcal": 1};

//TEMPLATE: "": {"code": "", "w": 600, "d": 0},
const table = {
  "\\cap": {"code": "MJX-1-TEX-N-2229", "w": 600, "d": 0},
  "\\cdot": {"code": "MJX-1-TEX-N-22C5", "w": 300, "d": 100},
  "\\circ": {"code": "MJX-1-TEX-N-2218", "w": 600, "d": 0},
  "\\cup": {"code": "MJX-1-TEX-N-222A", "w": 600, "d": 0},
  "\\downarrow": {"code": "MJX-1-TEX-N-2193", "w": 1400, "d": 200},
  "\\Downarrow": {"code": "MJX-1-TEX-N-21D3", "w": 1400, "d": 200},
  "\\exists": {"code": "MJX-1-TEX-N-2203", "w": 600, "d": 0},
  "\\forall": {"code": "MJX-1-TEX-N-2200", "w": 600, "d": 0},
  "\\geq": {"code": "MJX-1-TEX-N-2265", "w": 600, "d": 0},
  "\\in": {"code": "MJX-1-TEX-N-2208", "w": 750, "d": 100},
  "\\infty": {"code": "MJX-1-TEX-N-221E", "w": 600, "d": 0},
  "\\land": {"code": "MJX-1-TEX-N-2227", "w": 600, "d": 0},
  "\\leftarrow": {"code": "MJX-1-TEX-N-2190", "w": 1400, "d": 200},
  "\\Leftarrow": {"code": "MJX-1-TEX-N-21D0", "w": 1400, "d": 200},
  "\\leftharpoondown": {"code": "MJX-1-TEX-N-21BD", "w": 1400, "d": 200},
  "\\leftharpoonup": {"code": "MJX-1-TEX-N-21BC", "w": 1400, "d": 200},
  "\\leftrightarrow": {"code": "MJX-1-TEX-N-2194", "w": 1400, "d": 200},
  "\\Leftrightarrow": {"code": "MJX-1-TEX-N-21D4", "w": 1400, "d": 200},
  "\\leq": {"code": "MJX-1-TEX-N-2264", "w": 600, "d": 0},
  "\\longmapsto": {"code": "MJX-1-TEX-N-27FC", "w": 1400, "d": 200},
  "\\lor": {"code": "MJX-1-TEX-N-2228", "w": 600, "d": 0},
  "\\mapsto": {"code": "MJX-1-TEX-N-21A6", "w": 600, "d": 0},
  "\\nearrow": {"code": "MJX-1-TEX-N-2197", "w": 1400, "d": 200},
  "\\notin": {"code": "MJX-1-TEX-N-2209", "w": 750, "d": 100},
  "\\nwarrow": {"code": "MJX-1-TEX-N-2196", "w": 1400, "d": 200},
  "\\rightarrow": {"code": "MJX-1-TEX-N-2192", "w": 1400, "d": 200},
  "\\Rightarrow": {"code": "MJX-1-TEX-N-21D2", "w": 1400, "d": 200},
  "\\rightharpoondown": {"code": "MJX-1-TEX-N-21C1", "w": 1400, "d": 200},
  "\\rightharpoonup": {"code": "MJX-1-TEX-N-21C0", "w": 1400, "d": 200},
  "\\rightleftharpoons": {"code": "MJX-1-TEX-V-21CC", "w": 1400, "d": 200},
  "\\searrow": {"code": "MJX-1-TEX-N-2198", "w": 1400, "d": 200},
  "\\swarrow": {"code": "MJX-1-TEX-N-2199", "w": 1400, "d": 200},
  "\\times": {"code": "MJX-1-TEX-N-D7", "w": 600, "d": 0},
  "\\to": {"code": "MJX-1-TEX-N-2192", "w": 600, "d": 0},
  "\\uparrow": {"code": "MJX-1-TEX-N-2191", "w": 1400, "d": 200},
  "\\Uparrow": {"code": "MJX-1-TEX-N-21D1", "w": 1400, "d": 200},
  "\\Updownarrow": {"code": "MJX-1-TEX-N-21D5", "w": 1400, "d": 200},
};

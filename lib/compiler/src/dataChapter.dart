/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { JSONValue } from './dataJSON';
import { MBL_Level } from './dataLevel';
import { MBL_Unit } from './dataUnit';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- CHAPTER --------

export class MBL_Chapter {
  file_id = ''; // all references go here; label is only used for searching
  title = '';
  label = '';
  author = '';
  pos_x = -1;
  pos_y = -1;
  requires: MBL_Chapter[] = [];
  requires_tmp: string[] = []; // only used while compiling
  units: MBL_Unit[] = [];
  levels: MBL_Level[] = [];

  getLevelByLabel(label: string): MBL_Level {
    for (const level of this.levels) if (level.label === label) return level;
    return null;
  }

  getLevelByFileID(fileID: string): MBL_Level {
    for (const level of this.levels) if (level.file_id === fileID) return level;
    return null;
  }

  postProcess(): void {
    for (const l of this.levels) l.postProcess();
  }

  toJSON(): JSONValue {
    return {
      file_id: this.file_id,
      title: this.title,
      author: this.author,
      label: this.label,
      pos_x: this.pos_x,
      pos_y: this.pos_y,
      requires: this.requires.map((req) => req.file_id),
      units: this.units.map((unit) => unit.toJSON()),
      levels: this.levels.map((level) => level.toJSON()),
    };
  }
}

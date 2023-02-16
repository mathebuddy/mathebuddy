/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import { MBL_Chapter } from './dataChapter';
import { JSONValue } from './dataJSON';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- COURSE --------

export enum MBL_Course_Debug {
  No = 'no',
  Chapter = 'chapter',
  Level = 'level',
}

export class MBL_Course {
  debug = MBL_Course_Debug.No;
  title = '';
  author = '';
  mbcl_version = 1;
  date_modified = Math.floor(Date.now() / 1000);
  chapters: MBL_Chapter[] = [];

  getChapterByLabel(label: string): MBL_Chapter {
    for (const chapter of this.chapters)
      if (chapter.label === label) return chapter;
    return null;
  }

  getChapterByFileID(fileID: string): MBL_Chapter {
    for (const chapter of this.chapters)
      if (chapter.file_id === fileID) return chapter;
    return null;
  }

  postProcess(): void {
    for (const ch of this.chapters) ch.postProcess();
  }

  toJSON(): JSONValue {
    return {
      debug: this.debug,
      title: this.title,
      author: this.author,
      mbcl_version: this.mbcl_version,
      date_modified: this.date_modified,
      chapters: this.chapters.map((chapter) => chapter.toJSON()),
    };
  }
}

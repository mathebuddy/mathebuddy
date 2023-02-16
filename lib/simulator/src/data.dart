/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// Data structures defined in this file is used to cast JSON input data.
// Interface MBL_Item is an aggregated representation.

/*
export interface MBL_Course {
  debug: 'no' | 'chapter' | 'level';
  title: string;
  author: string;
  mbcl_version: string;
  date_modified: number;
  chapters: MBL_Chapter[];
}

export interface MBL_Chapter {
  file_id: string;
  title: string;
  author: string;
  pos_x: number;
  pos_y: number;
  requires: string[];
  units: MBL_Unit[];
  levels: MBL_Level[];
}

export interface MBL_Unit {
  title: string;
  levels: string[];
}

export interface MBL_Level {
  file_id: string;
  title: string;
  pos_x: number;
  pos_y: number;
  requires: string[];
  items: MBL_Item[];
}

export interface MBL_Item {
  type:
    | 'new_page'
    | 'definition'
    | 'theorem'
    | 'lemma'
    | 'corollary'
    | 'proposition'
    | 'conjecture'
    | 'axiom'
    | 'claim'
    | 'identity'
    | 'paradox'
    | 'error'
    | 'example'
    | 'exercise'
    | 'figure'
    | 'section'
    | 'subsection'
    | 'subsubsection'
    | 'table'
    | 'paragraph'
    | 'inline_math'
    | 'bold'
    | 'italic'
    | 'itemize'
    | 'enumerate'
    | 'enumerate_alpha'
    | 'span'
    | 'align_left'
    | 'align_center'
    | 'align_right'
    | 'text'
    | 'linefeed'
    | 'color'
    | 'variable'
    | 'text_input'
    | 'multiple_choice'
    | 'single_choice';
  title: string;
  label: string;
  error: string;
  items: MBL_Item;
  value: string;
  numbering: number;
  options:
    | 'align_left'
    | 'align_center'
    | 'align_right'
    | 'align_equals'
    | 'width-25'
    | 'width-33'
    | 'width-50'
    | 'width-66'
    | 'width-75'
    | 'width-100';
  code: string;
  variables: { [id: string]: MBL_Variable };
  instances: MBL_Instance[];
  text: MBL_Item | string;
  caption: MBL_Item;
  data: string;
  head: MBL_Item[];
  rows: MBL_Item[];
  columns: MBL_Item[];
  key: number;
  message: string;
}

export interface MBL_Variable {
  type:
    | 'bool'
    | 'int'
    | 'int_set'
    | 'real'
    | 'real_set'
    | 'complex'
    | 'complex_set'
    | 'vector'
    | 'matrix'
    | 'term';
}

export interface MBL_Instance {
  values: { [id: string]: string };
}
*/

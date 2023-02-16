# Mathe:Buddy Compiled Language (MBCL) Reference

<!-- start-for-website -->

---

**NOTE**
This reference is in work-in-progress state. We are planning to release version 1.0 by end of 2022.

---

This document describes the syntax of the _mathe:buddy compiled language (MBCL)_,
which can be used to express mathematical based online courses technically.

## Introduction

MBCL is a JSON-based format defined for the mathe:buddy App.
Each MBCL-JSON file stores a complete course, defined by the Mathe:Buddy Language (MBL).

MBL is intended to be used by course creators, i.e. humans, while MBCL is a pure computer language.

This document assumes detailed knowledge about MBL. Definitions are not repeated here.

The reference compiler to translate MBL to MBCL can be found on [GitHub](https://github.com/mathebuddy/mathebuddy-compiler.git).

## JSON Specification

### Intrinsic Data Types

We use the following intrinsic data types.

- `IDENTIFIER`

  Examples: `"hello"`, `"x314"`, `"_1337"`, `"AFFE"`

- `UNIQUE_IDENTIFIER`

  An identifier that is only given once per course.

  Example: `"x123"`

- `STRING`

  Example: `"hello, world!"`

- `INTEGER`

  Example: `1337`

- `REAL`

  Example: `3.14159`

- `BOOLEAN`

  Examples: `true`, `false`

- `UNIX_TIMESTAMP`

  (Time in seconds since 1.1.1970 00:00)

  Example: `1669712632`

- `MATH_STRING = int | real | complex | int_set | vector | matrix;`:

  The following strings represent mathematical objects (in EBNF notation):

  - Integers numbers: `int = INTEGER;`

    Example: `"3"`

  - Real numbers: `real = REAL;`

    Example: `"-3.14"`

  - Complex numbers: `complex = REAL "+" REAL "i" | REAL "-" REAL "i";`

    Example: `"3-3i"`

  - Set of integer numbers: `int_set = "{" [ INT { "," INT } ] "}";`

    Example: `"{1,3,5}"`

  - Vectors: `vector = "[" [ REAL { "," REAL } ] "]";`

    Example: `"[-1337,2.71,9.81]"`

  - Matrices: `matrix = "[" vector { "," vector } "]";`

    Example: `"[[1,2],[3,4]]"`

  - Terms: TODO

### Custom JSON Datatype Definition Language

We use the following custom notation instead of JSON-schema in this document to denote the structure of data.

_(Note: JSON-schema is NOT used, since its notation is rather long s.t. the context can only be grasped hardly.)_

- `A = { "x":IDENTIFIER, "y":B }; B = { "z": INTEGER };` denotes an object type with name `A` and attributes `x` and `y`. The value of attribute `x` must be an identifier, while attribute `y` is an object of type `B`.

  _JSON-Example that is accepted by the grammar defined above:_

  `{"x": "leet", "y": {"z": 1337}}`

- `X = {"a":INTEGER|STRING};` denotes alternative definitions for attribute `a`.

  _JSON-Examples that are accepted by the grammar defined above:_

  `{"a":"xx"}` &nbsp; or &nbsp; `{"a":314}` &nbsp; or &nbsp; `{"a":42}`

- `Y = {"x":"txt"} | INTEGER;` denotes alternative definitions for object `Y`.

  _JSON-Examples (fragments only) that are accepted by the grammar defined above:_

  `{"x":"txt"}` &nbsp; or &nbsp; `1337` &nbsp; or &nbsp; `271`

- `Z = {"k":INTEGER[]};` denotes that attribute `k` is an array of type integer.

  _JSON-Examples that are accepted by the grammar defined above:_

  `{"k":[1,1,2,3,5,8,13]}` &nbsp; or &nbsp; `{"k":[]}`

- `abstract(W) = {abstract("a"):IDENTIFIER, "b":STRING};` `V extends W = {"a":"xyz", "c":REAL};` declares an abstract object type `W` and an object type `V` that inherits all attributes from `W`. Abstract object types and attributes can not be instantiated.

  _JSON-Example that is accepted by the grammar defined above:_

  `{"a":"xyz","b":"hello, world","c":3.14159}`

- `M = { "id": IDENTIFIER }; N = { "ref": IDENTIFIER<M.id> };` declares two object types `M` and `N`. Attribute `ref` in `N` must hold an identifier of some actual instance of `M`.

  _JSON-Example that is accepted by the grammar defined above:_

  `{"id":"myId"}` &nbsp; for `M` and &nbsp; `{"ref":"myId"}` &nbsp; for `N`

- `O = { IDENTIFIER: INT };` denotes a dictionary-like object type.

  _JSON-Example that is accepted by the grammar defined above:_

  `{"a":1,"b":5,"pi":314}`

## Courses

A course represents the root of an MBCL file.
It contains a set of chapters.

```
COURSE = {
  "title": STRING,
  "author": STRING,
  "mbcl_version": INTEGER,
  "date_modified": UNIX_TIMESTAMP,
  "debug": "no" | "chapter" | "level",
  "chapters": CHAPTER[]
};
```

- if `debug` is not `no`, then only one `chapter` or one `level` is provided for debugging purposes

Example:

```json
{
  "title": "higher math 1",
  "author": "TH Koeln",
  "mbcl_version": 1,
  "date_modified": 1669712632,
  "debug_level": false,
  "chapters": []
}
```

## Chapters

A chapter consists of a set of levels.

```
CHAPTER = {
  "file_id": STRING,
  "title": STRING,
  "pos_x": INTEGER,
  "pos_y": INTEGER,
  "requires": IDENTIFIER<CHAPTER.file_id>[],
  "units": UNIT[],
  "levels": LEVEL[]
};
```

Example:

```json
{
  "file_id": "cmplx",
  "title": "Complex Numbers",
  "label": "cmplx",
  "pos_x": 0,
  "pos_y": 0,
  "requires": [],
  "units": [],
  "levels": []
}
```

## Levels

A level defines a part of course, consisting of e.g. text, exercises and games.

```
LEVEL = {
  "file_id": STRING,
  "title": STRING,
  "pos_x": INTEGER,
  "pos_y": INTEGER,
  "requires": IDENTIFIER<LEVEL.file_id>[],
  "items": LEVEL_ITEM[]
};
```

```
LEVEL_ITEM = SECTION | TEXT | EQUATION | DEFINITION | EXERCISE
           | FIGURE | TABLE | NEWPAGE;
```

```
UNIT = {
  "title": STRING,
  "levels": IDENTIFIER<LEVEL.file_id>[]
};
```

## Sectioning

A _title_ is used as level title.
(Sub-)Sections subdivide a level.

```
SECTION = {
  "type": "section" | "subsection" | "subsubsection",
  "text": STRING,
  "label": IDENTIFIER
};
```

## Paragraphs

A paragraph hierarchically defines a part of text, including format options and equations, alignment, enumerations etc.

```
TEXT = {
  "type": "paragraph" | "inline_math" | "bold" | "italic" | "itemize"
        | "enumerate" | "enumerate_alpha" | "span"
        | "align_left" | "align_center" | "align_right",
  "items": TEXT[]
} | {
  "type": "text",
  "value": STRING
} | {
  "type": "linefeed"
} | {
  "type": "color",
  "key": INTEGER
} | {
  "type": "reference",
  "label": IDENTIFIER<SECTION.label|BLOCK_ITEM.label>
} | {
  "type": "error",
  "message": STRING
};
```

The following example represents a paragraph containing an italic text &nbsp;&nbsp; _Hello, world $x^2 + y^2$!_ &nbsp;&nbsp; that ends with a line feed.

```json
{
  "type": "paragraph",
  "items": [
    {
      "type": "italic",
      "items": [
        { "type": "text", "value": "Hello, world" },
        { "type": "inline_math", "items": [{"type":"text","value":"x^2+y^2"}]}
        { "type": "text", "value": "!" }
      ]
    },
    {
      "type": "linefeed"
    }
  ]
}
```

## Block Items

For example display style equations, figures and exercises are called _block items_.
The following abstract type defines attributes that are common to all block items.

```
abstract(BLOCK_ITEM) = {
  abstract("type"): IDENTIFIER,
  "title": STRING,
  "label": IDENTIFIER
  "error": STRING
};
```

Attribute `error` is used to indicate syntax errors in the MBL definition.

## Display Style Equations

A (numbered) equation is rendered in display style by the following object.

```
EQUATION extends BLOCK_ITEM = {
  "type": "equation",
  "value": STRING,
  "numbering": INTEGER,
  "options": EQUATION_OPTION[]
};
```

```
EQUATION_OPTION = "align_left" | "align_center" | "align_right" | "align_equals";
```

If attribute `numbering` is set to a negative value, the numbering is not displayed.

## Definitions

A definition (and in the same way a theorem, lemma, ...) is rendered as block.
It may contain text and display-style equation items.

```
DEFINITION extends BLOCK_ITEM = {
  "type": "definition" | "theorem" | "lemma" | "corollary" | "proposition"
        | "conjecture" | "axiom" | "claim" | "identity" | "paradox",
  "items": DEFINITION_ITEM[]
};
```

```
DEFINITION_ITEM = EQUATION | TEXT;
```

## Examples

```
EXAMPLE extends DEFINITION = {
  "type": "example"
};
```

## Exercises

An exercise includes a set variables with values that can be used in the question text or as answers.

The attribute `instance` defines concrete values for each variable.
Randomized questions may have multiple (distinct) instances.

```
EXERCISE extends BLOCK_ITEM = {
  "type": "exercise",
  "variables": {
    IDENTIFIER: EXERCISE_VARIABLE
  },
  "instances": EXERCISE_INSTANCE[],
  "text": EXERCISE_TEXT
};
```

_Note: a `label` is created automatically, if none is provided._

Exercise text is extended to the following types:

- `variable` refers to a question variable and displays the value of the the chosen instance.
- `text_input` renders one or more text-based input field(s); dependent of the actual variable type.
  - Attribute `input_require` lists a set of identifiers that must be input by the student (e.g. `["sin"]` to require using the sine-function).
  - Attribute `input_forbid` is the opposite to `input_require`.
  - Attribute `width` controls the width of the input field(s). <!-- TODO: specify unit! -->
- `choices_input` lists a set of `count` buttons, where one given answer is correct and the other answers are incorrect.
- `multiple_choice` declares a set of answers of a multi-choice question
- `single_choice` declares a set of answers of a single-choice question

```
EXERCISE_TEXT extends TEXT = {
  "type": "variable",
  "variable": IDENTIFIER<EXERCISE.VARIABLES>
} | {
  "type": "text_input",
  "input_id": UNIQUE_IDENTIFIER,
  "input_type": "int" | "real"
              | "complex_normal" | "complex_polar"
              | "int_set" | "int_set_n_args"
              | "vector" | "vector_flex"
              | "matrix" | "matrix_flex_rows" | "matrix_flex_cols" | "matrix_flex"
              | "term",
  "input_require": IDENTIFIER[],
  "input_forbid": IDENTIFIER[],
  "variable": IDENTIFIER<EXERCISE.VARIABLES>,
  "width": INTEGER
} | {
  "type": "choices_input",
  "input_id": UNIQUE_IDENTIFIER,
  "variable": IDENTIFIER<EXERCISE.VARIABLES>,
  "count": INTEGER
} | {
  "type": "multiple_choice" | "single_choice",
  "input_id": UNIQUE_IDENTIFIER,
  "items": EXERCISE_SINGLE_MULTIPLE_CHOICE_OPTION[]
};
```

```
EXERCISE_VARIABLE = {
  "type": "bool" | "int" | "int_set" | "real" | "real_set"
        | "complex" | "complex_set" | "vector" | "matrix" | "term"
};
```

```
EXERCISE_INSTANCE = {
  IDENTIFIER<EXERCISE.VARIABLES>: MATH_STRING
};
```

```
EXERCISE_SINGLE_MULTIPLE_CHOICE_OPTION = {
  "variable": IDENTIFIER<EXERCISE.VARIABLES>,
  "text": TEXT
};
```

<!--
TODO: scoring

TODO: gap exercise, arrangement exercise, timed exercise
-->

## Figures

A figure renders a graphics file, as well as an optional caption.

```
FIGURE extends BLOCK_ITEM = {
  "file_path": STRING,
  "data": STRING,
  "caption": MBL_TEXT,
  "options": FIGURE_OPTION[]
};
```

- either `file_path` or `data` must be set.
- `data` represents an image in base64 encoding.

```
FIGURE_OPTION = "width_X";
```

- `X` denotes the width as percentage of screen width.

## Tables

A table renders tabular data.

```
TABLE extends BLOCK_ITEM = {
  "options": TABLE_OPTION[],
  "head": TABLE_ROW,
  "rows": TABLE_ROW[]
};
```

```
TABLE_ROW = {
  "columns": MBL_TEXT[];
}
```

<!--
TODO: must restrict `TEXT`
-->

```
TABLE_OPTION = "align_left" | "align_center" | "align_right";
```

## Page Breaks

```
NEWPAGE = {
  "type": "new_page"
};
```

## Errors

An error block is used for development purposes only.
It is used, if a course developer defined a block type that is unknown (or unimplemented).

```
ERROR extends BLOCK_ITEM = {
  "type": "error",
  "message": STRING
};
```

## Compressed Courses

The MBCL file size can be reduced by using LZ-based compression [npm-package](https://www.npmjs.com/package/lz-string).

<!--
TODO: compression format, hex, ...
TODO: encryption with password
-->

_Author: Andreas Schwenk, TH Köln_

<!-- Mathe:Buddy Language (MBL) -->

---

**NOTE**
This reference guide is in work-in-progress state. We are planning to release version 1.0 by mid of 2023.

---

This document describes the syntax of the _mathe:buddy language (MBL)_,
which can be used to create mathematical based online courses.
MBL describes contents as well as randomized training exercises.
It is also used to structure large courses with many levels and keeps track of the contents dependencies.
Tags can be inserted to transform the definition into a semantical network.
The latter can be used for example in chat bots or didactical learning concepts;
e.g. smart repetition for optimized memoization.

Some concepts of MBL are taken (or copied) from other formal languages:

- Text formatting is inspired from `Markdown`, as it provides a very expressive and memorable syntax.
- `TeX` is used for equations, as most mathematical staff at universities is firm to that language.
- `SMPL`, which is developed in parallel to `MBL`, is a general purpose language with focus on expressive math. It is used to generate random variables in exercises, as well as to calculate sample solutions.

<!-- TODO: implement such tags in to the language! -->

The language definition of MBL is independent of concrete implementations.
All concepts can be transferred to other learning management systems.

Visit [https://github.com/mathebuddy/mathebuddy-public-courses](https://github.com/mathebuddy/mathebuddy-public-courses) for practical examples, written in MBL.

## Hello, world!

The following lines define a trivial level page:

```
My first level
###############

Welcome to mathe:buddy!
```

## Typography

This section describes the text structuring and text formatting features.

- `Level Title`

  A level title is the main heading of a level file. Example:

  ```
  My Course Title @myLabel
  ###############
  ```

  Five or more hashtags (`#`) are required. Labels are optional.

- `Sections`

  A level can be separated into sections (headlines). Example:

  ```
  My Section @sec:myLabel
  ==========
  ```

  Five or more equal signs (`=`) are required. Labels are optional. We suggest to use prefix `sec:` for section labels, but this is optional.

- `Subsections`

  A section can be subdivided into one or multiple subsections. Example:

  ```
  My Subsection @subsec:myLabel
  -------------
  ```

  Five or more dashes (`-`) are required. Labels are optional. We suggest to use prefix `subsec:` for subsection labels, but this is optional.

- `Paragraphs`

  A paragraph consists of one or multiple lines of continuous text. Example:

  ```
  This is text within a paragraph.
  Even this text stands in a new line, it is compiled to be written directly behind the last line.

  An empty line starts a new paragraph.
  ```

- `Definitions, Theorems, Lemmas, ...`

  Definitions, Theorems etc. are embedded into a _block_ that syntactically starts and ends with each a line of three dashes (`---`). Examples:

  ```
  ---
  DEFINITION Positive @def:positive
  For any integer $n$, $n$ is **positive** if $n>0$.
  ---
  ```

  ```
  ---
  THEOREM The Aristotelian Syllogism @thm:socrates
  If every man is mortal and Socrates is a man, then Socrates is mortal.
  ---
  ```

  The runtime environment may replace tag names with corresponding terms of the local language.

  The complete list of supported tags is `DEFINITION`, `THEOREM`, `LEMMA`, `COROLLARY`, `PROPOSITION`, `CONJECTURE`, `AXIOM`, `CLAIM`, `IDENTITY`, `PARADOX`.

- `Examples`

  Examples are embedded into a _block_ that syntactically starts and ends with each a line of three dashes (`---`).

  ```
  ---
  EXAMPLE Addition of complex numbers @ex:myExample
  $z_1=1+3i ~~ z_2=2+4i ~~ z_1+z_2=3+7i$
  ---
  ```

  Full line equations can be inserted as described in subsection "nesting of blocks below. Example:

  ```
  ---
  EXAMPLE Addition of complex numbers @ex:myExample
  EQUATION
  z_1=1+3i ~~ z_2=2+4i ~~ z_1+z_2=3+7i
  ---
  ```

- `Bold, Italic and Colored Text`

  Basic text formatting options are bold text, italic text and colored text. Examples:

  ```
  Some **bold** text. Some *italic* text.
  The word [sky]@color1 is written in primary color.
  [Some text written in the secondary color.]@color2.
  You can also write [bold text]@bold and [italic text]@italic similar to color notation.
  ```

  Colors are only defined implicitly. The exact rendering depends on the runtime environment. We restricted the degree of freedom per design to force uniformly presented courses. `color0` defines black color in all cases.

- `Alignment`

  The default alignment of paragraphs is left.
  Block types `LEFT`, `CENTER` and `RIGHT` change the alignment.

  Example:

  ```
  ---
  CENTER
  This text is centered.
  ---
  ```

- `Links and References`

  Each section, subsection, equation, exercise, ... can be labeled at declaration. A label has the form `@PREFIX:LABEL`, with identifiers for `PREFIX` and `LABEL`.
  Using prefixes is optional.

  A link to a labeled object can be placed in paragraph text. One has to write `@PREFIX:LABEL` again.

  The order of declaration and reference is arbitrary.

  <!-- TODO: references to other levels.. -->

  Example:

  ```
  An introduction is given in @sec:intro.

  Intro @sec:intro
  =====
  ```

  We suggest to use the following prefixes:

  | prefix    | used for    |
  | --------- | ----------- |
  | `sec:`    | sections    |
  | `subsec:` | subsections |
  | `ex:`     | exercises   |
  | `fig:`    | figures     |
  | `eq:`     | equation    |
  | `tab:`    | table       |
  | `def:`    | definition  |
  | `thm:`    | theorem     |

  References to other files should be avoided, if destination levels are possibly unplayable/locked (read section [course structure](#course-structure)).

  A link to a labeled object in another file is denoted by `@PATH/PREFIX:LABEL`, where `PATH` is the relative file path within the current course, without file extension (`.mbl`). _Example: To link to theorem `thm:taylor` in file `../diff/taylor.mbl`, write `@../diff/intro/thm:taylor`._

  It is also feasible to insert generic references with the asterisk operator (`*`). For example, `@ex:taylor*` links to the set of all exercises that have a label starting with `ex:taylor` (e.g. `ex:taylor-simple`, `ex:taylor2`, ...). The runtime environment inserts comma separated links.

- `Comments`

  All characters after `%` are ignored by the compiler, until the current line ends.

  Comments can e.g. be used to make notes to other developers, or temporarily hide unfinished stuff. Example:

  ```
  This text is displayed in the output. % only a course developer can read this.
  ```

- `Page Breaks`

  A level can be scrolled vertically by the student. Doom-scrolling should be avoided (not only) for didactical reasons. Page breaks can be inserted by a `NEWPAGE`-_block_. Example:

  ```
  ---
  NEWPAGE
  ---
  ```

- Nesting of blocks:

  In general, format blocks are used in a sequence, i.e. a new block starts after the last block ended.

  In some cases, a nesting of blocks is needed.
  The following example uses text alignment and an equation within a `DEFINITION`:

  ```
  ---
  DEFINITION My definition @def:myDef
  Some paragraph text here.

  CENTER
  This text is center aligned.

  EQUATION @myEquation
  x^2 + y^2 = z^2

  TEXT
  Another paragraph here.
  ---
  ```

  Inner blocks do not use `---` as separator.
  Note in the example, that `TEXT` is used to leave equation mode.

## Equations

We distinguish two kinds of equations:
_inline equations_ are embedded into a text of a paragraph.
_Full equations_ are rendered in one or more separate lines.
The latter are numbered by default.

Equations are encoded in `TeX` notation.

- `Inline Equations`

  An inline equation is embedded into a pair of dollar signs. Example:

  ```
  Einstein's famous formula is $E=mc^2$. It defines the energy $E$ of ...
  ```

- `Full Equations` (equations in display math mode)

  Full equations are embedded into a block with keyword `EQUATION`. Example:

  ```
  ---
  EQUATION @eq:myLabel
  a^2 + b^2 = c^2
  ---
  ```

  The label is optional.

  A numbering is displayed right to the equation per default.
  An asterisk `*` hides the numbering. Example:

  ```
  ---
  EQUATION* @eq:myLabel
  a^2 + b^2 = c^2
  ---
  ```

  Equations can be labeled with `@`.
  For example, `@eq:myLabel` is displayed $Eq~(1)$ (depends on the runtime environment).

- Options

  Equations can be configured with the following options:

  Option `align-left` left aligns the equation.

  Option `align-equals` renders each specified line of the equation in a separate line and aligns it to the first equal sign (`=`) of each row.

  Example:

  ```
  ---
  EQUATION
  @options
  align-left
  align-equals
  @text
  (x+1)^2 = (x+1)(x+1)
          = x^2 + x + x + 1
          = x^2 + 2x + 1
  ---
  ```

- Abbreviations

  Equations are written in plain `TeX` code.
  In some cases, the notation is rather long.
  We introduce some abbreviations for a shorter notation.
  The following table lists all implemented abbreviations:

  | type         | plain tex                                                                                    | short notation                  |     |
  | ------------ | -------------------------------------------------------------------------------------------- | ------------------------------- | --- |
  | $\mathbb{R}$ | `\mathbb{R}`                                                                                 | `\RR`                           |     |
  | $\mathbb{N}$ | `\mathbb{N}`                                                                                 | `\NN`                           |     |
  | $\mathbb{Z}$ | `\mathbb{Z}`                                                                                 | `\ZZ`                           |     |
  | $\mathbb{C}$ | `\mathbb{C}`                                                                                 | `\CC`                           |     |
  | matrix       | `\begin{pmatrix}` <br> &nbsp;&nbsp;`A & B\\` <br> &nbsp;&nbsp;`C & D\\` <br> `\end{pmatrix}` | `\mat{A&B\\C&D}` <br> <br> <br> |     |

  Using abbreviations is optional.

<!-- (TODO: extend table) -->

## Figures

SMPL provides syntax to plot function graphs.

All other figures must be generated with external tools.
We highly recommend to generate files in the `SVG` (Scalable Vector Graphics) format using [Inkscape](https://inkscape.org)).

- `Function Plots`

  Functions graphs are described in a _block_ with keyword `FIGURE`.

  Example:

  ```
  ---
  FIGURE My Plot @fig:functions
  @options
    width-75
  @code
    let f(x) = x^2
    let g(x) = 2*x
    figure {
      x_axis(-5, 5, "x")  % x-min, y-max, label
      y_axis(-0.5, 4.5, "y")
      function(f)
      function(g)
      circle(0, 0, 0.1)   % x, y, radius
      circle(2, 4, 0.1)
    }
  @caption
    Some functions $f$ and $g$
  ---
  ```

  Part `@code` defines two functions $f(x)$ anf $g(x)$.
  Function `figures2d()` generates a new plot variable.

<!-- TODO: write more text -->

<!--  OLD
Axis definition is done by &nbsp;&nbsp; `xaxis LABEL from MIN to MAX` &nbsp;&nbsp; for the x-axis and &nbsp;&nbsp; `yaxis LABEL from MIN to MAX` &nbsp;&nbsp; for the y-axis.

`colorX` changes the current color. All subsequent plots are drawn in that color. `X` is an integer value for the color key.

`plot F` renders a function curve `F` that is specified as term. An exact definition is essential. In particular, all multiplication operators (`*`) must be denoted explicitly. The exact syntax is described in the SMPL documentation.

Keyword `coord X Y` renders a small circle at position $(X,Y)$.
-->

- `Figures`

  A figure displays an image file. It is highly recommended to use `*.svg` as file format (scalable vector graphics). Example:

  ```
  ---
  FIGURE My figure title @fig:myFigure
  @options
    width-75
  @path
    images/myImage.svg
  ---
  ```

  Option `width-P` specifies the displayed width with a percentage value for `P`. E.g. `width-75` renders the figure with 75 % of the display width. Default is `width-100`.

## Itemizations and Enumerations

- `Itemize`

  An itemization lists a set of bullet points. Example:

  ```
  My itemization:
  - first item
  - second item
  - third item
  ```

  A line that starts with a dash (`-`) is rendered as bullet point.

- `Enumeration (numbers)`

  Enumerations list a sequence of numbered items. Example:

  ```
  My enumeration:
  #. first item
  #. second item
  #. third item
  ```

  A line that starts with a hashtag following a dot (`#.`) is rendered with numbering (1, 2, ...).

- `Enumeration (letters)`

  Alphabetical enumerations list a sequence of items. Example:

  ```
  My enumeration:
  -) first item
  -) second item
  -) third item
  ```

  A line that starts with a dash following a closing parenthesis (`-)`) is rendered with preceding letters `a)`, ` b)`, ... .

_Note: Hierarchical itemizations are not supported for didactical reasons, as well as a mobile friendly presentation._

## Tables

A table is described by a _block_ with keyword `TABLE`.
Each row of the table is written without line break.
Columns are separated by `&`.
The first row is considered as headline.

Example:

```
---
TABLE title @tab:label
@options
  align-left
@text
  $x$ & $f(x)$
  1   & 1
  2   & 4
  3   & 9
---
```

The alignment option `align-X` specifies the placing of the table. Parameter `X` is one of `left`, `center`, `right`.
Default is `align-center`.

## Exercises

Exercises provide interactive elements to the course.
For example, multiple choice questions display multiple answers, from which students have to select all correct ones to gather scores.

Most exercises contain a `@code` part to generate randomized variables and to calculate the sample solution.
It is denoted in the _Simple Math Programming Language (SMPL)_.
The documentation can be found [here](https://app.f07-its.fh-koeln.de/docs-smpl.html).

The following paragraphs describe all implemented exercise types.

- `Calculation Exercises`

  This type of exercise asks students to solve a question with one or more numeric solutions.
  Solutions can be scalars, vectors, matrices or sets.

  ```
  ---
  EXERCISE My exercise @ex:myLabel
  @code
    let x/y = rand(1, 5)
    let z = x + y
    let A/B = rand<2,3>(-5,-5)
    let C = A + B
  @text
    Calculate $ x+y= $ #z
    Calculate $ xA+B= $ #C
  ---
  ```

  _Note: `let x/y = rand(1, 5)` is an abbreviation for `let x = rand(1, 5); let y = rand(1, 5);` with guarantee that $x \neq y$_

  Part `@code` draws random variables and generates the sample solution.

  Part `@texts` describes the question text. Typography, itemizations, equations, etc. can be included, as described above.
  Input fields are generated for patterns `#V`, where `V` is a valid variable from part `@code`.
  Take care, that input fields are _not_ inserted within equations.

  Variables in math mode (inline equations embedded into dollar signs) are substituted by values of code variables by default.
  In the example above, $x$ is e.g. shown as $3$ (depending on the present value for $x$). If the variable identifiers should be rendered instead, the concerned variable name must written in quotes, e.g. &nbsp;&nbsp;`$ "x" + "y" $`&nbsp;&nbsp; (spacing is optional).

  <!-- TODO: number of random instances; default 10 -->

  Input Types:

  - `integers and real numbers`

    Without any options, an input field is generated for each input with `#V`, for a variable `V` from part `@code`.
    The student has to type in the answer on a numeric keyboard.

    If option `choices-X` is given, a set of `X` possible answers is shown.
    Only one these answers is a correct one.
    All other answers are incorrect.
    The student has to select the correct solution to gather scoring.

    Example:

    ```
    ---
    EXERCISE Multiplication
    @options
      choices-4
    @code
      let x/y = rand(10,20)
      let z = x * y
    @text
      Calculate $x * y=$ #z
    ---
    ```

  - `complex numbers`

    Per default, two input fields of the form &nbsp;&nbsp; `[ ] + [ ]i` &nbsp;&nbsp; are shown to enter the solution in normal form.

    If the option `polar-form` is given, then the student as to enter the solution in polar form.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```
    ---
    EXERCISE Complex addition
    @options
      polar-form
    @code
      let x/y = complex(rand(10,20), rand(10,20))
      let z = x + y
    @text
      Calculate $x + y=$ #z
    ---
    ```

  - `sets`

    Per default, if the set has length $n$, then $n$ input fields are shown to enter the solution from a numeric keyboard.

    If option `n-args` is given, students must figure out the number of solution fields on their own.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```
    ---
    EXERCISE Linear Equations
    @options
      n-args
    @code
      let s = {-2, 2}
    @text
      Solve $x^2 - 4 = 0$.
      $x=$ #s
    ---
    ```

  - `matrices`

    Per default, an input matrix is shown with a text field for each element of the solution matrix.

    If option `n-rows` is given, students must figure out the number of solution rows on their own.

    If option `n-cols` is given, students must figure out the number of solution columns on their own.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```
    ---
    EXERCISE Matrix Operations
    @options
      n-rows
      n-cols
    @code
      let A/B/C = rand<3,3>(0, 5)  % 3x3-matrices
      let D = A*B + C
    @text
      Calculate $A*B + C=$ #D
    ---
    ```

  - `vectors`

    Exercises with vector solutions are technically matrix exercises with the number of rows, or columns respectively, set to one.

  - `terms`

    ```
    ---
    EXERCISE Simple Integration @ex:intSimple
    @options
      term-tokens-1.5
    @code
      F(x) = 1/3*x^3 + 7*x
    @text
      Solve $\int (x^2+7) \dx =$  #F  $+C$
    ---
    ```

    Without any option, the student is required to enter `1/3*x^3 + 7*x` (or an algebraic equivalent solution) on a keyboard.

    Option `term-tokens-X` lists a set of buttons.
    Each button represents a part of the solution term.
    In the example, buttons `[1/3]`, `[*]`, `[x^3]`, `[+]`, `[7]`, `[x]` are shown in random order.
    The student has to click on the buttons to construct the solution.
    Attribute `X` represents the overhead factor, i.e. the number of additional buttons with (most likely) useless options.
    The example sets `X` to `1,5`.
    In this case 9 instead of 6 buttons are shown (e.g. `[1/5]`, `[/]`, `[x^4]`).

    Option `forbid-X` does not allow `X`in the solution term. For example `forbid-sin` forbids to use the sinus function.
    List of supported values for `X` (in alphabetical order): `abs`, `acos`, `asin`, `atan`, `cos`, `exp`, `log`, `sin`, `tan`.
    For multiple forbiddings, repeat the `forbid-X` option with different identifiers for `X`.

    Option `require-X` forces the student to use `X` in the answer. The set of supported values is equal to the definition of `forbid-X`.

    <!-- TODO: equivalency, ... -->
    <!-- TODO: exercise with fraction answer -->

- Scoring of answers

  Per default, each input field is weighted with 1 score. And the total score per exercise is defined as sum of scores of the input fields.

  Example for custom scoring:

  ```
  ---
  EXERCISE Scoring example
  @options
    scores-5        % total score of the exercise (5/3 for fa; 10/3 for fb)
    score-fa-1      % relative score for solution fa
    score-fb-2      % relative score for solution fb
  @code
    let a = rand(2,4)
    let b = rand(5,8)
    let fa = fac(a)
    let fb = fac(b)
  @text
    Calculate $ a! = $ #fa
    Calculate $ b! = $ #fb
  ---
  ```

  Option `scores-X` defines that `X` is the total score for the exercise a student can receive at maximum.

  Option `score-V-X` defines that `X` is the maximum score for solution variable `V`.

  The sum of all `score-V-Xi` must _not_ necessarily be equal to `score-V-X`.

- `Static Multiple Choice Exercise`

  Multiple choice exercises list a set of answers, which can be selected or deselected by the student with checkboxes.
  Correct answers are indicated by `[x]`.
  Incorrect answers are indicated by `[ ]`.
  Example:

  ```
  ---
  EXERCISE My Multiple Choice Exercise @ex:myMultiChoice
  @options
    static-order
  @text
    [x] This answer is correct.
    [ ] This answer is incorrect.
    [x] This answer is correct.
  ---
  ```

  Each correct answer is scored with 1 points, each wrong answer is scored with -1 points. The total score of the exercise can be weighted with option `scores-X`, where `X` is the total score.

  Answers are displayed in random order per default.
  Option `static-order` suppresses random shuffling.

- `Dynamic Multiple Choice Exercise`

  Dynamic multiple choice exercises calculate the correctness of answers at runtime. Example:

  ```
  ---
  EXERCISE My dynamic Multiple Choice Exercise @ex:myMultiChoice
  @code
    let x/y/z/w = rand(10,20)    % no pair of x, y, z, w is equal
    let c1 = x > w
    let c2 = y > w
    let c3 = z > w
  @text
    [:c1] $x > w$
    [:c2] $y > w$
    [:c3] $z > w$
    [x]   $1 > 0$    % statically true
    [ ]   $1 < 0$    % statically false
  ---
  ```

  Correctness of an answer is determined by a boolean variable `V`, in the form `[:V]`.

  You are allowed to mix static and dynamic answers:
  If variable `x` is a boolean variable, then `[:x]` is correct (incorrect) if $x$ is true (false).
  The notation `[x]` indicates that the answer is _always_ true.

- `Single Choice Exercise`

  In single choice exercises, exactly one answer is true.
  All other answers are wrong.
  Instead of check boxes, radio buttons are displayed.

  ```
  ---
  EXERCISE My Multiple Choice Exercise @ex:myMultiChoice
  @text
    (x) This answer is correct.
    ( ) This answer is incorrect.
    ( ) This answer is incorrect.
  ---
  ```

  The definition of single choice exercises is similar to the definition of multiple choice exercises.
  We use round parentheses `( )`, instead of brackets `[ ]`.

  For dynamic single choice exercises, the exercise designer must take care, that no more than one option is correct.
  In case of more than one correct answers, the behavior is undefined.

- `Gap Exercise`

  Gap exercises provide an input field to enter words within fluent paragraph text.

  ```
  ---
  EXERCISE My Gap Exercise @ex:myLabel
  @options
    show-length
    restricted-keyboard
  @text
    Garfield is a #"cat". Rain is #"wet".
  ---
  ```

  Option `show-length` hints the number of characters of the solution word.

  Option `restricted-keyboard` displays a context-sensitive keyboard that only shows characters needed for the solution.
  E.g. for the first answer `cat` from the example, the student only sees keys `[A]`, `[C]` and `[T]`.

- `Arrangement Exercise`

  Arrangement exercises show a sequence of strings or numbers that must be reordered by the student.

  <!-- TODO: string arrangement -->

  ```
  ---
  EXERCISE Title @ex:label
  @options
    accept-immediately
  @code
    let n = rand(5,10)          % length
    let f = zeros(1,n)          % row vector for the sequence
    f[1] = 1                    % f[0]=0, f[1]=1
    for (let i=2; i<n; i++) {   % calc sequence iteratively
      f[i] = f[i-2] + f[i-1]
    }
  @text
    Arrange the following numbers to get the first numbers of the Fibonacci sequence: #:order(s,f)
  ---
  ```

  _Preface: The answer field `#f` would ask the student to type in the elements of the row vector: `[0, 1, 1, 2, 3, 5, ...]`._

  Writing &nbsp;&nbsp;`#:order(v)`&nbsp;&nbsp; lists a randomly shuffled form of vector `v`.
  The student is required to reorder the vector to finally get vector `v`.

  The option `accept-immediately` accepts the answer immediately when it is correct.
  If the option is missing, then the student needs to submit the solution explicitly.

- `Timed Exercise`

  A timed exercise is repeatedly shown.
  Each instance uses different variables.
  Quick and correct responses results in a large high score.
  This question type might test, if students are already trained well to a specific topic.

  ```
  ---
  EXERCISE Title @ex:label
  @options
    timed-3
    accelerate
    multi-choice-4
    stop-on-error-1
  @code
    let x:y = rand(20,50)
    let z = x + y
  @text
    Calculate $x+y=$ #z
  ---
  ```

  Option `timed-X` enables timing. The student has `X` seconds to give an answer.

  Option `accelerate` decreases time per question.

  Option `multi-choice-X` lists `X` options per question.

  Option `stop-on-error-X` stops asking after `X` incorrect answers.

## Course Structure

Large courses need to be structured into multiple files.
We use the following terms in the subsequent sections:

- `Course`: an entire course, e.g. "higher math 1".
- `Chapter`: a logical chapter of a course, e.g. "complex numbers".
- `Unit`: a learning unit of a chapter, e.g. "basics of complex numbers", "complex functions, sequences and series".
- `Level`: a basic part of a unit, e.g. "normal form", "polar form", "absolute value".

A course consists of multiple `*.mbl` files.
The file hierarchy is `/COURSE/CHAPTER/LEVEL_FILE.mbl`.
Thus, each file represents a level of the course.
Units are defined in index files (see below).

Example folder hierarchy for a course _higher math 1_ (`hm1`):

```
hm1/course.mbl
...
hm1/cmplx/index.mbl
hm1/cmplx/start.mbl
hm1/cmplx/intro.mbl
hm1/cmplx/normal.mbl
hm1/cmplx/conj.mbl
hm1/cmplx/conj-props.mbl
hm1/cmplx/abs.mbl
hm1/cmplx/polar.mbl
...
hm1/diff/index.mbl
hm1/diff/...
...
```

File `course.mbl` contains general meta data for the course and lists all chapters.

Each chapter directory is organized by an index file, named `index.mbl`.
The format of index files is described in the next section.

## Level Index Files (`index.mbl`)

An index file defines meta data for a chapter. It also lists all files and its dependencies.

> hm1/cmplx/index.mbl

```
% a comment line

TITLE Complex Numbers
AUTHOR TH Koeln

UNIT Complex Basics
(2,0) start
(1,0) gauss       !start
(3,1) normal      !start
(3,2) conj        !normal
(4,2) conj-props  !conj
(3,3) abs         !conj
(2,4) polar       !abs

UNIT Complex Functions, Sequences, Series
...
```

Each chapter consists of a set of units.

Each unit consists of a set of levels.
A unit can be represented by a (directed) graph $G=(V,E)$ with $V$ the levels and $E$ the dependencies between levels.

Each level is described by an `*.mbl` file.
A level is only playable, if all presuming levels have been passed successfully.
At least one level must have no presuming level.

All Levels of a unit are listed below the `UNIT UNIT_NAME` entry.
Each level is described in the form: `(X,Y) A !B !C !D ...`.

- Coordinates `(X,Y)` describe the position of node $v \in V(G)$, where `(0,0)` is interpreted as _top-left_.

- File `A` is the level.

- Files `!B`, `!C`, ... (with `!`-prefix) represent the requirements of `A`, i.e. level `A` depends on levels `B`, `C`, ....

- Requirements for other course chapters can be denoted by relative paths, e.g. `!../basics/sets` requires level `sets.mbl` in chapter `basics`.

Since all units are stored in the same file directory, prefixes to file names may be helpful.

Example:

```
...
UNIT Complex Basics
(2,0) basics-start
(1,0) basics-gauss       !basics-start
(3,1) basics-normal      !basics-start
...

UNIT Complex Functions, Sequences, Series
(0,0) fss-start
...
```

## Course Description File (`course.mbl`)

The course description file `course.mbl` is similar organized to level index files.

It mainly lists all chapters and its dependencies.

Example:

```
TITLE A Short Demo Course

AUTHOR TH Koeln

CHAPTERS
(0,0) basics
(2,0) essentials  !basics
(1,1) advanced    !basics !essentials
```

_Author: Andreas Schwenk, TH Köln_

<!--
# TODO

- add preview images in this document
- add links to web-simulator (not public)
- chatbot code
- repetition, ...
- indexing / glossary

-->

<!-- MatheBuddy Language (MBL) -->

(only available in English)

This document outlines the syntax of the `MatheBuddy Language (MBL)`, designed for creating math-based online courses. `MBL` supports both content structuring and the generation of randomized training exercises. It is especially suited for organizing large, multi-level courses and managing content dependencies efficiently. Additionally, semantic tags can be added to transform the structure into a semantic network, which can be leveraged in applications like chatbots or adaptive learning strategies, such as smart repetition for optimized memorization.

Several concepts in MBL are inspired by other formal languages:

- Text formatting draws from `Markdown`, known for its expressive and easy-to-remember syntax.
- `TeX` is employed for equations, as it is the standard language used by most academic staff in mathematics departments.
- `SMPL`, developed alongside MBL, is a general-purpose language with a focus on mathematical expression. It is used to generate random variables in exercises and compute sample solutions.

Although originally developed for the MatheBuddy Learning app, the `MBL` language is designed to be platform-independent, allowing for easy integration into other learning management systems.

For a comprehensive collection of example courses, visit the public repository: [MatheBuddy Public Courses](https://github.com/mathebuddy/mathebuddy-public-courses).

## File Format

MBL files are written in UTF-8 encoded text and use the `*.mbl` file extension. Typically, an `*.mbl` file represents a level, which is a self-contained module designed to explain specific content to students. These files include text, equations, figures, and exercises.

The chapter _Course Structure_ will detail how to organize a full course, comprising multiple chapters, units, and levels.

## Hello, world!

The following example defines a simple level page with only the title and a single paragraph of text.

```mbl
My first level
###############

Welcome to MatheBuddy!
```

Here's an improved version of the provided section:

## Typography

This section outlines the text structuring and formatting features in MBL.

- **Level Title**: The main heading of a level file, defined with at least four hashtags (`#`). Labels are optional.

  Example:

  ```mbl
  My Course Title @myLabel
  ###############
  ```

- **Sections**: Levels can be divided into sections using at least four equal signs (`=`). Labels are optional, and it is recommended to use the prefix `sec:` for section labels.

  Example:

  ```mbl
  My Section @sec:myLabel
  ==========
  ```

- **Subsections**: Sections can be further subdivided with subsections, using at least four dashes (`-`). Labels are optional, and it is recommended to use the prefix `subsec:` for subsection labels.

  Example:

  ```mbl
  My Subsection @subsec:myLabel
  -------------
  ```

- **Paragraphs**: A paragraph consists of one or more lines of continuous text. New paragraphs start after an empty line.

  Example:

  ```mbl
  This is a sentence within a paragraph.
  Although the next sentence starts on a new line,
  it will still appear directly after the previous one without any gap.

  A new paragraph begins here.
  ```

- **Bold, Italic, and Colored Text**: Basic text formatting options include bold, italic, and colored text. Use `**` for bold, `*` for italic, and square brackets with a color code for colored text.

  Example:

  ```mbl
  This text is **bold**. This one is *italic*.
  The word [beautiful]@color1 is displayed in the primary color."
  ```

  The specific colors depend on the runtime environment, but `color0` is always black.

- **Definitions and Theorems**: Definitions, theorems, and similar elements are structured in blocks. All lines in a block are indented by four spaces.

  Examples:

  ```mbl
  DEFINITION Positive @def:positive
      A number $n$ is **positive** if $n > 0$.

  THEOREM The Aristotelian Syllogism @thm:socrates
      If all men are mortal and Socrates is a man, then Socrates is mortal.
  ```

  The list of supported tags is: `AXIOM`, `CLAIM`, `CONJECTURE`, `COROLLARY`, `DEFINITION`, `EXAMPLE`, `IDENTITY`, `LEMMA`, `PARADOX`, `PROPOSITION`, `THEOREM`, `PROOF`.

- **Examples**: Examples are also formatted in blocks, indented by four spaces.

  Example:

  ```mbl
  EXAMPLE Complex Number Addition @ex:myExample
      $z_1 = 1 + 3i$, $z_2 = 2 + 4i$,
      so $z_1 + z_2 = 3 + 7i$.
  ```

- **Alignment**: Text alignment can be adjusted using the `LEFT`, `CENTER`, and `RIGHT` blocks.

  Example:

  ```mbl
  CENTER
      This text is centered.
  ```

- **Links and References**: Sections, exercises, and other objects can be labeled with `@PREFIX:LABEL`, allowing for easy cross-referencing.

  Example:

  ```mbl
  Refer to section @sec:intro for an introduction.

  Intro @sec:intro
  =====
  ```

  Suggested prefixes include `sec:` for sections, `ex:` for exercises, and `fig:` for figures.

- **Comments**: Comments are indicated by `%` and ignored by the compiler until the end of the line.

  Example:

  ```mbl
  This is visible text.
  % This comment is visible to developers only.
  ```

- **Page Breaks**: To minimize excessive vertical scrolling, page breaks can be added using the `NEWPAGE` block.

  Example:

  ```mbl
  NEWPAGE
  ```

- **Block Nesting**: Blocks can be nested, with deeper levels created by additional indentation. The `END` keyword can be used to close a block explicitly.

  Example:

  ```mbl
  DEFINITION My Definition @def:myDef
      Some explanation here.
      CENTER
          This text is centered.
      EQUATION
          x^2 + y^2 = z^2
      Additional explanation here.
  ```

## Equations

We differentiate between two types of equations:

- **Inline equations** are embedded within the text of a paragraph.
- **Block equations** are rendered on separate lines, typically with numbering.

Equations are written using `TeX` notation.

- **Inline Equations**:  
  Inline equations are enclosed within dollar signs (`$`).

  Example:

  ```mbl
  Einstein’s renowned equation, $E=mc^2$,
  defines the relationship between energy ($E$) and mass ($m$),
  with $c$ representing the speed of light.
  ```

- **Block Equations** (display math mode):  
  Block equations are enclosed within an `EQUATION` block.

  Example:

  ```mbl
  EQUATION @eq:myLabel
      a^2 + b^2 = c^2
  ```

  - Labels are optional and allow referencing the equation (e.g., `@eq:myLabel`).
  - By default, equations are numbered. To suppress numbering, use an asterisk (`*`):

  ```mbl
  EQUATION* @eq:myLabel
      a^2 + b^2 = c^2
  ```

  Equations can be referenced in the text, e.g., `@eq:myLabel`, and will be displayed based on the runtime environment (e.g., as $Eq~(1)$).

- **Aligned Equations**:  
  For better readability, equations with multiple steps or operations can be aligned vertically.  
  Use an ampersand (`&`) for alignment, and end each line with a double backslash (`\\`). Example:

  ```mbl
  ALIGNED-EQUATION
      (x+1)^2 &= (x+1)(x+1) \\
              &= x^2 + x + x + 1 \\
              &= x^2 + 2x + 1 \\
  ```

  _Note: The final linefeed (`\\`) is optional. Consistent spacing around `&` is recommended for clarity._

- **Abbreviations**:  
  To simplify the notation, some commonly used mathematical symbols have shorthand versions. The following table lists available abbreviations:

  | Symbol       | `TeX` Code   | Abbreviation |
  | ------------ | ------------ | ------------ |
  | $\mathbb{R}$ | `\mathbb{R}` | `\RR`        |
  | $\mathbb{N}$ | `\mathbb{N}` | `\NN`        |
  | $\mathbb{Z}$ | `\mathbb{Z}` | `\ZZ`        |
  | $\mathbb{C}$ | `\mathbb{C}` | `\CC`        |

  Abbreviations are optional but can enhance readability for common symbols.

<!-- TODO: old from here on -->

## Figures

SMPL provides syntax to plot function graphs.

All other figures must be generated with external tools.
We highly recommend to generate files in the `SVG` (Scalable Vector Graphics) format using [Inkscape](https://inkscape.org)).

- `Figures`

  A figure displays an image file. It is highly recommended to use `*.svg` as file format (scalable vector graphics). Example:

  ```mbl
  FIGURE My figure title @fig:myFigure
      WIDTH=75
      PATH=images/myImage.svg
  ```

  Attribute `width-P` specifies the displayed width with a percentage value for `P`. E.g. `width-75` renders the figure with 75 % of the display width. Default is `width-100`.

- `Function Plots`

  Functions graphs are described in a _block_ with keyword `FIGURE`.

  Example:

  ```mbl
  FIGURE My Plot @fig:functions
      WIDTH=75
      CODE
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
      CAPTION
          Some functions $f$ and $g$
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

## Itemizations and Enumerations

- `Itemize`

  An itemization lists a set of bullet points. Example:

  ```mbl
  My itemization:
  - first item
  - second item
  - third item
  ```

  A line that starts with a dash (`-`) is rendered as bullet point.

- `Enumeration (numbers)`

  Enumerations list a sequence of numbered items. Example:

  ```mbl
  My enumeration:
  #. first item
  #. second item
  #. third item
  ```

  A line that starts with a hashtag following a dot (`#.`) is rendered with numbering (1, 2, ...).

- `Enumeration (letters)`

  Alphabetical enumerations list a sequence of items. Example:

  ```mbl
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

```mbl
TABLE My table title  @tab:label
    ALIGN=left
    $x$ & $f(x)$
    1   & 1
    2   & 4
    3   & 9
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

  ```mbl
  EXERCISE My exercise  @ex:myLabel
      CODE
          let x/y = rand(1, 5)
          let z = x + y
          let A/B = rand<2,3>(-5,5)
          let C = A + B
      Calculate $ x+y= $ #z
      Calculate $ A+B= $ #C
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

    ```mbl
    EXERCISE Multiplication
        CHOICES=4
        CODE
            let x/y = rand(10,20)
            let z = x * y
        Calculate $x * y=$ #z
    ```

  - `complex numbers`

    Per default, two input fields of the form &nbsp;&nbsp; `[ ] + [ ]i` &nbsp;&nbsp; are shown to enter the solution in normal form.

    If the option `polar-form` is given, then the student as to enter the solution in polar form.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```mbl
    EXERCISE Complex addition
        CODE
            let x/y = complex(rand(10,20), rand(10,20))
            let z = x + y
        Calculate $x + y=$ #polar(z)
    ```

  - `sets`

    Per default, if the set has length $n$, then $n$ input fields are shown to enter the solution from a numeric keyboard.

    If option `n-args` is given, students must figure out the number of solution fields on their own.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```mbl
    EXERCISE Linear Equations
        FLEX_ELEMENTS=true
        CODE
            let s = {-2, 2}
        Solve $x^2 - 4 = 0$.
        $x=$ #s
    ```

  - `matrices`

    Per default, an input matrix is shown with a text field for each element of the solution matrix.

    If option `n-rows` is given, students must figure out the number of solution rows on their own.

    If option `n-cols` is given, students must figure out the number of solution columns on their own.

    Option `choices-X` renders `X` buttons, where one of them shows the correct solution (refer to exercise type `integers and real numbers`).

    Example:

    ```mbl
    EXERCISE Matrix Operations
        FLEX_ROWS=true
        FLEX_COLS=true
        CODE
            let A/B/C = rand<3,3>(0, 5)    % 3x3-matrices
            let D = A*B + C
        Calculate $A*B + C=$ #D
    ```

  - `vectors`

    Exercises with vector solutions are technically matrix exercises with the number of rows, or columns respectively, set to one.

  - `terms`

    ```mbl
    EXERCISE Simple Integration  @ex:intSimple
        CODE
            let F(x) = (1/3) x^3 + 7x
        Solve $\int (x^2+7) dx = #build_term(F),score=2 +C$
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

  ```mbl
  EXERCISE Scoring example
      SCORES=5   % total score of the exercise (5/3 for fa; 10/3 for fb)
      CODE
          let a = rand(2,4)
          let b = rand(5,8)
          let fa = fac(a)
          let fb = fac(b)
      Calculate $ a! = $ #fa,score=1   % relative score for solution fa is 1
      Calculate $ b! = $ #fb,score=2   % relative score for solution fb is 2
  ```

  Option `scores-X` defines that `X` is the total score for the exercise a student can receive at maximum.

  Option `score-V-X` defines that `X` is the maximum score for solution variable `V`.

  The sum of all `score-V-Xi` must _not_ necessarily be equal to `score-V-X`.

- `Static Multiple Choice Exercise`

  Multiple choice exercises list a set of answers, which can be selected or deselected by the student with checkboxes.
  Correct answers are indicated by `[x]`.
  Incorrect answers are indicated by `[ ]`.
  Example:

  ```mbl
  EXERCISE My Multiple Choice Exercise  @ex:myMultiChoice
      ORDER=static
      Choose the right answers:
      [x] This answer is correct.
      [ ] This answer is incorrect.
      [x] This answer is correct.
  ```

  Each correct answer is scored with 1 points, each wrong answer is scored with -1 points. The total score of the exercise can be weighted with option `scores-X`, where `X` is the total score.

  Answers are displayed in random order per default.
  Option `static-order` suppresses random shuffling.

- `Dynamic Multiple Choice Exercise`

  Dynamic multiple choice exercises calculate the correctness of answers at runtime. Example:

  ```mbl
  EXERCISE My dynamic Multiple Choice Exercise
      CODE
          let x/y/z/w = rand(10, 20)     % no pair of x, y, z, w is equal
          let c1 = x > w
          let c2 = y > w
          let c3 = z > w
      Choose the correct answer(s):
      [:c1] $x > w$
      [:c2] $y > w$
      [:c3] $z > w$
      [x]   $1 > 0$    % statically true
      [ ]   $1 < 0$    % statically false
  ```

  Correctness of an answer is determined by a boolean variable `V`, in the form `[:V]`.

  You are allowed to mix static and dynamic answers:
  If variable `x` is a boolean variable, then `[:x]` is correct (incorrect) if $x$ is true (false).
  The notation `[x]` indicates that the answer is _always_ true.

- `Single Choice Exercise`

  In single choice exercises, exactly one answer is true.
  All other answers are wrong.
  Instead of check boxes, radio buttons are displayed.

  ```mbl
  EXERCISE My Single Choice Exercise  @ex:myMultiChoice
      (x) This answer is correct.
      ( ) This answer is incorrect.
      ( ) This answer is incorrect.
  ```

  The definition of single choice exercises is similar to the definition of multiple choice exercises.
  We use round parentheses `( )`, instead of brackets `[ ]`.

  For dynamic single choice exercises, the exercise designer must take care, that no more than one option is correct.
  In case of more than one correct answers, the behavior is undefined.

- `Gap Exercise`

  Gap exercises provide an input field to enter words within fluent paragraph text.

  ```mbl
  EXERCISE My Gap Exercise  @ex:myLabel
      SHOW_GAP_LENGTH=true
      SHOW_REQUIRED_LETTERS_ONLY=true
      Garfield is a #"cat". Rain is #"wet".
  ```

  Option `show-length` hints the number of characters of the solution word.

  Option `restricted-keyboard` displays a context-sensitive keyboard that only shows characters needed for the solution.
  E.g. for the first answer `cat` from the example, the student only sees keys `[A]`, `[C]` and `[T]`.

- `Arrangement Exercise`

  Arrangement exercises show a sequence of strings or numbers that must be reordered by the student.

  <!-- TODO: string arrangement -->

  ```mbl
  EXERCISE Arrangement exercise
      ARRANGE=true
      ACCEPT_IMMEDIATELY=true
      CODE
          let n = rand(5,10)          % length
          let f = zeros<n>()          % vector for the sequence
          f[0] = 0
          f[1] = 1
          for k from 2 to n-1 {       % calc sequence iteratively
              f[k] = f[k-2] + f[k-1]
          }
      Arrange the following numbers to get the first numbers of the Fibonacci sequence: #f
  ```

  Note the use of `k` for the loop variable. A variable named `i` would be considered as complex number `0+1*i`.

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

  ```mbl
  EXERCISE Timed exercise
      TIMER=3
      ACCELERATE=true
      STOP_AFTER_ERRORS=1
      CHOICES=4
      CODE
          let x:y = rand(20,50)
          let z = x + y
      Calculate $ x + y = #z $
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

```mbl
% a comment line

TITLE
    Complex Numbers

AUTHOR
    TH Koeln

UNIT Complex Basics
    (2,0) start                   ICON icons/start.svg
    (1,0) gauss       !start      ICON icons/gauss.svg
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

- (Optional) Icons in SVG format can be inserted by keyword `ICON`.

Since all units are stored in the same file directory, prefixes to file names may be helpful.

Example:

```mbl
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

```mbl
TITLE
    A Short Demo Course

AUTHOR
    TH Koeln

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

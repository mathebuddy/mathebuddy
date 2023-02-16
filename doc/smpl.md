# Simple Math Programming Language (SMPL) Reference

<!-- start-for-website -->

---

**NOTE**
This reference guide is in work-in-progress state. We are planning to release version 1.0 by end of 2022.

---

This document describes the _Simple Math Programming Language (SMPL)_.

SMPL is a math-oriented programming language that can be interpreted in the browser. Its primary use is for the _mathe:buddy app_.

SMPL is (mostly) an imperative, typed language. Its syntax is basically a subset of _JavaScript_, but extends with intrinsic mathematical data types (e.g. terms, sets and matrices) and operator overloading for these types.

The language definition of SMPL is independent of concrete implementations.
A reference implementation can be found [here](https://github.com/mathebuddy/mathebuddy-smpl).
Visit our online [playground](https://mathebuddy.github.io/mathebuddy-smpl/).

SMPL is heavily used by the [mathe:buddy language](https://app.f07-its.fh-koeln.de/docs-mbl.html).

### History Notes

Many concepts (and also parts of the source code) are taken from the _Simple E-Learning Language_ [SELL](https://sell.f07-its.fh-koeln.de).
Compared to SELL, SMPL is _Turing Complete_, but lacks an interactive e-learning environment.

## First Example

The following example program creates two $3 \times 3$-matrices $A$ and $B$, with random (integral) entries in range [-5,5] without zero.
Both matrices are numerically unequal. The product of $A$ and $B$ is finally assigned to variable $C$.

```
% multiplication of two 3x3-matrices
let A/B = randZ<3,3>(-5,5);
let C = A * B;
```

The example demonstrates some of the key features of SMPL:

- very short syntax
- flexible randomization functions
- operator overloading

The following _Python_ program is similar to the two lines of SMPL code above (but not semantically equivalent, since it generates zero-elements in some cases).

```python
import numpy
A = numpy.round(numpy.random.rand(3,3)*10) - 5
while True:
  B = numpy.round(numpy.random.rand(3,3)*10) - 5
  if not numpy.array_equal(A,B):
    break
C = numpy.matmul(A, B)
```

## Programs

An SMPl program is a sequence of statements $p=(s_0 ~s_1 \dots)$.
Each statement ends by a semicolon (`;`).
Declarations and assignments are executed statement wise, i.e. $s_{i+1}$ is executed after statement $s_i$.

Example:

```
let x = 3;
let y = sin(x);
```

The example programs executes lines one and two in given order.
Each line is evaluated, before the next line is executed.
Indeed, we also could write all statements in one line, since the semicolon separates statements.

- The first line evaluates the right-hand side of the equal sign (`=`) and assigns the result, here `3`, to a new variable with identifier `x`. The type of variable `x` is `INT`.

- The second line first evaluates the expression `sin(x)`. Variable `x` is taken as argument to the sine function. The numeric result `0.14111..` is stored to variable `y` of data type `real`. It has double-precision (refer to IEEE 754). Take care, that real numbers $\mathbb{R}$ are stored approximately, unless symbolic computation is applied explicitly.

## Comments

Comments provide the opportunity co write notes in natural language that is not executed.
Comments are introduced by the percentage sign (`%`) and are valid until the next line break.

Example:

```
% this is a comment line
let a = 5;  % assign integer constant 5 to variable a
%let b = 7;
```

The same listing can be denoted as follows without comments:

```
let a = 5;
```

## Declarations

Declarations are initiated with keyword `let`, followed by an identifier and finally assigned expression by `=`.
The expression in the right-hand side is mandatory to derive the data type.
Data types are described in detail in the next section.

Example:

```
let x = 5, z = 9.1011;
let y = 7;
let u = rand(5);
let v = zeros<2,3>();
let a:b = randZ<3,3>(-2, 2);
let c/d/e = rand<3,3>(-2, 2);
```

- Variables `x` and `u` are integral. The value for `u` is randomly chosen from set {0,1,2,3,4,5}.
- Variable `z` is a real valued.
- Variables `x` and `z` are declared together (without any semantical relation). The notation is equivalent to `let y=7; let y=9.1011;`
- Variables `v`, `a`, `b`, `c` and `d` are matrices. `v` is a zero matrix with two rows and three columns.
- Matrices `a` and `b` consist of randomly chosen, integral elements in range [-2,2] without zero.
- The colon separator `:` evaluates the right-hand side as many times, as there are left-hand side variables. The example is equal to: `let a = randZ<3,3>(-2, 2); let b = randZ<3,3>(-2, 2);`.
- Separator `/` guarantees that no pair of matrices `c`, `d` and `e` is equal: Matrix, a $3 \times 3$ matrix is generated and assigned to variable `c`. Then a random $3 \times 3$ matrix is generated that is numerically unequal to matrix `a`. Finally, a random $3 \times 3$ matrix for `c` is generated with $c \neq a$ and $c \neq b$.

## Expressions

An assignment has the form `X = Y;`. First, the right-hand side `Y` is evaluated and then assigned to the variable `X` on the left-hand side.

Variables are named by identifiers, consisting of one ore more characters.
The first character must be a lowercase or uppercase letter or underscore, i.e. `a..z` or `A..Z` or `_`.
Starting from the second character, also numbers `0..9` are allowed additionally.
Keywords and function names of the standard function library (see appendix) are not allowed.
Examples: `x`, `y0`, `A`, `mat_0`.

The right-hand side of an assignment consists of a unary constant (e.g. `1337` or `3.14` or `-42`) or a function call (e.g. `sin(x)`) or a variable (e.g. `x`) or an expression (e.g. `a + 4`).

An expression is denoted in infix notation: The operator is denoted between two operands in case of a binary operation or the operator is denoted before the operand in case of a unary operation.

The following list of operators is implemented in SMPL.
The list is ordered by increasing precedence.
Explicit parentheses can break the default precedence (e.g. $a * (b+c)$).

| Operator                  | Description                                                       |
| ------------------------- | ----------------------------------------------------------------- |
| <code>&#124;&#124;</code> | Logical Or (binary)                                               |
| `&&`                      | Logical And (binary)                                              |
| `==`,`!=`                 | Equal, Unequal (binary)                                           |
| `<`, `<=`,`>`,`>=`        | Less than, Less or equal, Greater than, Greater or equal (binary) |
| `+`, `-`                  | Addition, Subtraction (binary)                                    |
| `*`, `/`                  | Multiplication, Division (binary)                                 |
| `^`                       | Potency (binary)                                                  |
| `++`, `--`                | Postfix Incrementation, Decrementation (unary)                    |
| `!`                       | logical not (unary)                                               |

Not all operators can be applied to each data type.
For example, `a && b` is only valid, if operands `a` and `b` are boolean.

Base data types are evaluated at compile-time.
The compiler reports an error, if types do not match for a operator.

Dimensions are evaluated at runtime.
For example, a `RuntimeError` is thrown if two matrices with a different number of rows are added.

Comparing non-integer numbers with `==` and `!=` applies the following numerical compare: `a == b` is implemented as $|a-b|\leq\epsilon$ and `a != b` is implemented as $|a-b|>\epsilon$. _(Note: $\epsilon$ is statically set to $10^{-9}$. It will be configurable in future SMPL revisions.)_

Some examples for expressions (the examples assumes, that variables `y`, `u`, `w`, `A`, `B`, `C` have been declared before usage):

```
let x = 1.23 * sin(y) + exp(u + 2*w);
let C = A * transpose(B);
let d = det(C);
```

The set of implemented functions is listed in the appendix.

## Data Types

SMPL supports the following data types:

- boolean (`BOOL`)

  A boolean variable is either `true` or `false`.

  Example:

  ```
  let x = true;
  let y = false;
  let w = true;
  let u = (x && y) || !w;
  let v = 3 < 5;
  ```

  $u := (x \land y) \lor \lnot w$

- integer (`INT`)

  An integer variable stores integral values in range $-2^{53}$ to $2^{53}-1$.

  > Note: `JavaScript` stores integer values as double precision floating point numbers.

  Example:

  ```
  let x = 5;
  let y = -23;
  let z = x * y;
  let w = round(x / y);
  ```

  Note that the division outputs `RATIONAL` data type, despite concrete values.
  Use `round` or `floor` or `ceil` to get an integer value.

- rational (`RATIONAL`)

  A rational number variable stores values of the form `x/y` with $x,y \in \mathbb{Z}$.

  Example:

  ```
  let x = 1 / 7;
  let y = real(1 / 7);
  ```

  Variable `x` is of type `RATIONAL` and stores `1/7`.
  Variable `y` is of type `REAL` and stores `0.142857...` in IEEE 754 double precision.

- real (`REAL`)

  Real number variables store approximations of real values with IEEE 754 double precision.

  Example:

  ```
  let x = PI;
  let y = sin(0.1);
  ```

- complex (`COMPLEX`).

  Complex variables store complex number in normal form `x+yi` with $x,y \in \mathbb{R}$.
  Complex numbers can be initialized by function `complex(x,y)` or writing `x+yi`.

  For `y=1`, one must write `1i` instead of just `i`.
  The identifier `i` is an ordinary variable name.

  Example:

  ```
  let x = 3 - 4i;
  let y = complex(3, -4);
  let phi = arg(x);
  let r = abs(x);
  let z = r * exp(phi);
  ```

- set (`SET`)

  A set variable stores a set of integer numbers. A set is initialized

  ```
  let x = set(3, 4, 5);      // x := {3,4,5}
  add(x, 4);                 // x := {3,4,5}
  add(x, 6);                 // x := {3,4,5,6}
  remove(x, 3);              // x := {4,5,6}
  let y = iselement(x, 4);   // true
  ```

  > Note: set of non-integers will be supported later.

- term (`TERM`)

  A term is an symbolic expression.

  Example

  ```
  let f(x) = x^2;
  let y = f(3);
  let g(x,y) = 2 * exp(-x) * sin(y);
  let h(x,y) = diff(g, x);
  let i = int(f, 0, 3);
  ```

  The example calculates $f(x)=x^2$, $y=9$, $g(x)=2\cdot\exp(x)\cdot\sin(y)$, $h(x,y)=-2 \cdot \exp(x) \cdot \sin(y)$, $i=21.3333...$.

- vector (`VECTOR`)

  ```
  let v = [1, 2, 3];
  let w = [4, 5, 6];
  let x = zeros<3>();
  let n = len(v);
  let d = dot(v, w);
  ```

- matrix (`MATRIX`)

  A matrix variable stores a real valued matrix.

  - Matrices can be initialized e.g. by the `zero<m,n>()` function, which creates a zero matrix with `m` rows and `n` columns.
  - A matrix with all its elements can be specified by the brackets operator: `[a00, a01, ..., a0n-1; a10, a11, ..., a1n-1; ...; am-10 am-11 ... am-1n-1]`. Rows are delimited by `;` and columns are delimited by `,`.
  - Matrix elements can be accessed by `[i,j]` with row `i` and column `j`. Indices start at zero, i.e. the first index is 0 and the last index is $m-1$ for a row and $n-1$ for a column.

  The appendix lists all functions with matrix operands.

  ```
  let A = zeros<2,3>();
  let B = [1, 2, 3; 4, 5, 6];
  let C = ones<3,3>();
  B[2,3] = 5;
  let x = B[0,0];
  let d = det(C);
  ```

  > Note: matrices with complex elements will be supported later.

<!-- TODO: bigint -->
<!-- TODO: special constants: PI, ... -->

## Conditions

Conditional code is executed only, if a conditional is true.
The `if`-statement has the form `if (C) { S0 } else if (C1) { S1 } ... else { Sn }`, with a sequences of statements `S0`, `S1` etc.
Sequence `S0` is executed, if the boolean condition `S0` is true.
Sequence `S1` is executed, if the boolean condition `S0` is false and the boolean condition `S1` is true.
In case that all conditions `Ci` are false, then sequence `Sn` is executed.

The `else if` parts and `else` part are optional.

> Example

```
let s = 0;
if (x > 0) {
  s=1;
}
else if (x < 0) {
  s = -1;
}
else {
  x=0;
}
```

## Loops

TODO:

Example:

```
while (x > 0) {
  // body
}
```

Example:

```
do {
  // body
} while (x > 0);
```

Example:

```
for (let i = 0; i < 5; i++) {
  // body
}
```

## Functions

A function consists of a **header** and a **body**:

- The **header** declared the name of the function, its parameter names and types and the return type.
- The **body** is represented by a list of statements and returns a result that is compatible to the return type.

Example:

```
function f(x: INT, y: INT): INT {
  return x + y;
}

let y = f(3, 4);
```

## Appendix: Built-in constants

The following list describes all built-in constants.
We use the notation `:T` after each variable to indicate its data type.

- **`PI : REAL` &nbsp; ($3.141592653589793$)**

## Appendix: Built-in functions

The following list describes all built-in functions.
We use the notation `:T1|T2|...` to list valid data types for each parameter and the return value.
For example `abs(x:INT|REAL|COMPLEX):REAL` denotes function `abs` with one parameter named `x` that can be an integer a real value or complex value.
The function returns a real value.

Some function also require dimensions. These are embedded into `<...>`.

- **`abs ( x : INT|REAL|COMPLEX ) : REAL`**

  Returns the absolute values of `x`.

  _Example: `abs(-4)` is evaluated to `4`._

  _Example: `abs(3+4i)` is evaluated to `5`._

- **`acos ( x : REAL ) : REAL`**

  Calculates $\cos^{-1}(x)$.

  _Example: `acos(0)` returns $1.57079...$._

- **`asin ( x : REAL ) : REAL`**

  Calculates $\sin^{-1}(x)$.

  _Example: `asin(0)` returns $0$._

- **`atan ( x : REAL ) : REAL`**

  Calculates $\tan^{-1}(x)$.

  _Example: `atan(0)` returns $0$._

- **`binomial ( n : INT , k : INT ) : INT`**

  Calculates the binomial coefficient $\binom{n}{k} = \frac{n!}{k!(n-k)!}$.

  _Example: `binomial(4,2)` returns `6`._

- **`ceil ( x : INT|REAL ) : INT`**

  Returns the ceiling of `x`.

  _Example: `ceil(3.14159)` returns `4`._

- **`ceil ( x : MATRIX ) : MATRIX`**

  Returns a matrix, where each element is the ceiling value of the input matrix.

  _Example: `ceil([[1.1,2.2],[4.4,5.5]])` returns `[2,3;5,6]`._

- **`complex ( x : INT|REAL , y : INT|REAL ) : COMPLEX`**

  Creates a complex number from real part `x` and imaginary part `y`, i.e. $z=x+yi$.

  _Example: `complex(2,3)` returns `2+3i`_.

- **`column ( x : MATRIX, c : INT ): VECTOR`**

  Returns the `c`-th column of matrix `x` as vector.
  The first vector has index 0.

  _Example: `column([[1,2],[3,4]], 1)` returns `[2,4]`._

- **`conj ( z : COMPLEX ) : COMPLEX`**

  Calculates $\bar z$, i.e. the complex conjugate of `z`.

  _Example: `conj(3+4i)` returns `3-4i`._

- **`cos ( x : REAL ) : REAL`**

  Calculates $\cos(x)$.

  _Example: `cos(PI/2)` returns $0$._

- **`cross ( x : VECTOR, y : VECTOR ) : VECTOR`**

  Calculated the cross product of two vectors $x$ and $y$, i.e. $x \times y$,
  or throws an exception, if one of the vectors has not exactly three elements.

  _Example: `cross([1,2,3],[4,5,6])` returns `[-3,6,-3]`._;

- **`det ( x : MATRIX ) : REAL`**

  Returns `\det(x)` or throws an error, if $x$ is not square.

  TODO: example(s).

- **`diff ( f : TERM , x : ID ) : TERM`**

  Calculates $\frac{\partial f}{\partial x}$.

  _Example: `f(x,y)=x^2+y; diff(f, x)` returns `2*x`._

- **`dot ( u : VECTOR , v : VECTOR ) : REAL`**

  Calculates the doc product of two vectors $u$ and $v$.

  _Example: `dot([1,2,3],[4,5,6])` returns `32`._

- **`eigenvalues_sym ( x : MATRIX ) : SET_REAL`**

  Calculate the set of eigenvalues of a symmetric matrix `x`.
  If `x` is not symmetric, an error is thrown.

  _Example: `eigenvalues_sym([[3,0],[0,4]])` returns `{3,4}`._

- **`exp ( x : REAL|COMPLEX ) : REAL|COMPLEX`**

  Calculates $\exp(x)$.

  _Examples: `exp(0)` returns $1$. `exp(1i)` returns `0.54... + 0.84...i`._

- **`eye ( n : INT ): MATRIX`**

  Returns an $n \times n$ identity matrix.

  _Example: `eye(3)` returns `[[1,0,0],[0,1,0],[0,0,1]]`_

- **`fac ( x : INTEGER) : INTEGER`**

  Calculates $x!$, i.e. the faculty of $x$.

  _Example: `fac(3)` returns 6._

- **`figure2d() : FIGURE_2D`**

  Creates a new 2D-figure instance.

- **`figure_x_range( fig : FIGURE_2D, min : REAL , max : REAL ) : VOID`**

  Defines the range of the $x$-axis for figure `fig`.

- **`figure_y_range( fig : FIGURE_2D, min : REAL , max : REAL ) : VOID`**

  Defines the range of the $y$-axis for figure `fig`.

- **`figure_x_label( fig : FIGURE_2D, label : STRING ) : VOID`**

  Sets the label of the $x$-axis for figure `fig`.

- **`figure_y_label( fig : FIGURE_2D, label : STRING ) : VOID`**

  Sets the label of the $y$-axis for figure `fig`.

- **`figure_color( fig : FIGURE_2D, key : INT ) : VOID`**

  Sets the color for figure `fig`.

- **`figure_plot( fig : FIGURE_2D, x : VECTOR|TERM ) : VOID`**

  Plots a 2D-point or a function term into figure `fig`.

- **`floor ( x : INT|REAL ) : INT`**

  Returns the floor of `x`.

  _Example: `floor(2.71)` returns `2`._

- **`floor ( x : MATRIX ) : MATRIX`**

  Returns a matrix, where each element is the ceiling value of the input matrix.

  _Example: `floor([[1.1,2.2],[4.4,5.5]])` returns `[[1,2],[4,5]]`._

- **`imag ( x : COMPLEX ) : REAL`**

  Returns the imaginary part of a complex number.

  _Example: `imag(3+4i)` returns 4._

- **`int ( x : REAL ) : INT`**

  Typecast from type real to type integer.
  Same behavior as function `floor`.

  _Example: `int(3.0)` returns `3`. &nbsp; &nbsp; `int(2.71)` returns `2`._

- **`is_invertible ( x : MATRIX ) : BOOL`**

  Returns true, if $x$ is invertible, otherwise false.
  Throws an exception, if $x$ is not a square matrix.

  TODO: epsilon + give example(s)

- **`is_symmetric ( x : MATRIX ) : BOOL`**

  Returns true, if $x$ is symmetric, otherwise false.
  Throws an exception, if $x$ is not a square matrix.

  TODO: epsilon + give example(s)

- **`is_zero ( x : VECTOR|MATRIX ) : BOOL`**

  Returns true, if all elements $|x| < \epsilon$.

  <!-- TODO: specify epsilon + give example(s) -->

- **`len ( x : VECTOR|SET ) : INT`**

  Returns the length of a vector or the cardinality (number of elements) of a set.

  _Examples: `len([1,0,0,1])` returns 4. `len(set(1,3,3,7))` returns 3._

- **`linsolve ( A : MATRIX , x : VECTOR ) : VECTOR`**

  TODO: no, one, inf solutions.

- **`max ( s : SET_INT ) : INT`**

  Returns the maximum value from an integer set.
  If the set is empty, then $-\infty$ is returned.

  _Example: `max(set(1,-2,3))` returns `3`._

- **`max ( s : SET_REAL ) : REAL`**

  Returns the maximum value from a set consisting of real valued elements.
  If the set is empty, then $-\infty$ is returned.

  _Example: `max(set(1.1,-2.1,3.1))` returns `3.1`._

- **`min ( s : SET_INT ) : INT`**

  Returns the minimum value from an integer set.
  If the set is empty, then $\infty$ is returned.

  _Example: `min(set(1,-2,3))` returns `-2`._

- **`min ( s : SET_REAL ) : REAL`**

  Returns the minimum value from a set consisting of real valued elements.
  If the set is empty, then $\infty$ is returned.

  _Example: `min(set(1.1,-2.1,3.1))` returns `-2.1`._

- **`norm2 ( u : VECTOR ) : REAL`**

  Calculates the euclidean norm of a vector $u$, i.e. $\sqrt{u_0^2 + u_1^2 + \dots}$.

  _Example: `norm2([3,4])` returns `5`._

- **`ode < lhs : TERM , rhs : TERM > : TERM`**

  Returns an ordinary differential equation (ODE).

  _Example: `let y(x) = ode( diff(y,x), - 2 * x^2/y );`_

- **`ones < m : INT , n : INT > () : MATRIX`**

  Returns a one-matrix with `m` rows and `n` columns.

  _Example: `ones<2,3>()` returns a $2\times 3$ matrix with all elements 1._

- **`rand ( a : INT , b : INT ) : INT`**

  Returns a random integer in range `[a,b]`.

- **`rand < n : INT > ( a : INT , b : INT ) : VECTOR`**

  Returns a vector of length $n$, where each element is a randomly chosen integer value in range `[a,b]`.

- **`rand < m : INT , n : INT > ( a : INT , b : INT ) : MATRIX`**

  Returns a $m \times n$ matrix, where each element is a randomly chosen integer value in range `[a,b]`.

- **`rand ( s : SET_INT ) : INT`**

  Randomly returns one of the elements of integer set `s`.

  _Example: `rand(set(11,12,13))` returns `11` or `12` or `13`._

- **`randZ ( a : INT , b : INT ) : INT`**

  Returns a random integer in range `[a,b]`, except value 0.

- **`randZ < n : INT > ( a : INT , b : INT ) : VECTOR`**

  Returns a vector of length $n$, where each element is a randomly chosen integer value in range `[a,b]`, except value 0.

- **`randZ < m : INT , n : INT > ( a : INT , b : INT ) : MATRIX`**

  Returns a $m \times n$ vector, where each element is a randomly chosen integer value in range `[a,b]`, except value 0.

- **`rank ( x : MATRIX ) : INT`**

  Calculates the rank of matrix $x$.

  <!-- TODO: give example(s) -->

- **`real ( x : INT ) : REAL`**

  Type casts an integer value to a real value.

  _Example: `real(3)` returns `3.0`._

- **`real ( x : COMPLEX ) : REAL`**

  Returns the real part of a complex number.

  _Example: `real(3+4i)` returns 3._

- **`row ( x : MATRIX, r : INT ): VECTOR`**

  Returns the `c`-th row of matrix `x` as vector.
  The first row has index 0.

  _Example: `row([[1,2],[3,4]], 1)` returns `[3,4]`._

- **`round ( x : INT|REAL ) : INT`**

  Returns the rounded value of `x`.

  _Example: `round(3.14159)` returns `3`._

- **`round ( x : MATRIX ) : MATRIX`**

  Returns a matrix, where each element of the input matrix is rounded.

  _Example: `round([[1.1,2.2],[4.4,5.5]])` returns `[[1,2],[4,6]]`._

- **`set ( x0 : INT , x1 : INT, ... ) : SET_INT`**

  Creates and returns a set of integer values.

  _Example: `set(4, 2, 5, 2)` returns a set $\{2,4,5\}$._

- **`set ( x0 : REAL , x1 : REAL, ... ) : SET_REAL`**

  Creates and returns a set of real values.

  _Example: `set(0.1, -3.4)` returns a set $\{-3.4,0.1\}$._

- **`set ( x0 : COMPLEX , x1 : COMPLEX, ... ) : SET_COMPLEX`**

  Creates and returns a set of complex values.

  _Example: `set(4+2i, 2, 5i, 2)` returns a set $\{4+2i,2,5i\}$._

- **`sin ( x : REAL ) : REAL`**

  Calculates $\sin(x)$.

  _Example: `sin(0)` returns $0$._

- **`shuffle ( x : VECTOR ) : VECTOR`**

  Randomly reorders the elements of `x`.

  _Example: `shuffle([3,1,4])` returns `[1,3,4]` or `[4,3,1]` or ..._

- **`sqrt ( x : INT|REAL ) : REAL`**

  Calculates $\sqrt{x}$ for $x \geq 0$.
  If $x<0$, a runtime error is thrown.

  For negative or complex `x`, use function `sqrtC`.

  _Example: `sqrt(4)` returns `2`._

- **`sqrtC ( x : INT|REAL|COMPLEX ) : COMPLEX`**

  Calculates $\sqrt{x}$ and returns the result as complex number. The result is technically a complex number, even if the imaginary part is zero.

  _Examples: `sqrt(-4)` returns `2i`. &nbsp;&nbsp;&nbsp; `sqrt(4)` returns `2+0i`._

- **`tan ( x : REAL ) : REAL`**

  Calculates $\tan(x)$.

  _Example: `tan(0)` returns $0$._

- **`triu ( x : MATRIX ) : MATRIX `**

  Returns the upper triangular part of $x$.

  TODO: example(s)

- **`zeros < n : INT > () : VECTOR`**

  Returns a zero-vector with `n` elements.

  _Example: `zero<3>()` returns a vector with all three elements 0._

- **`zeros < m : INT , n : INT > () : MATRIX`**

  Returns a zero-matrix with `m` rows and `n` columns.

  _Example: `zero<2,3>()` returns a $2\times 3$ matrix with all elements 0._

## Appendix: Grammar

The following formal grammar (denoted in EBNF) is currently implemented.

```EBNF
program = { statement };
statement = declaration | if | for | do | while | switch | function | return | break | continue | expression EOS;
declaration = "let" id_list "=" expr EOS | "let" ID "(" ID { "," ID } ")" "=" expr EOS;
id_list = ID { ":" ID } | ID { "/" ID };
expression = or { ("="|"+="|"-="|"/=") or };
or = and { "||" and };
and = equal { "&&" equal };
equal = relational [ ("=="|"!=") relational ];
relational = add [ ("<="|">="|"<"|">") add ];
add = mul { ("+"|"-") mul };
mul = pow { ("*"|"/"|"mod") pow };
pow = unary [ "^" unary ];
unary = unaryExpression [ unaryPostfix ];
unaryExpression = "PI" | "true" | "false" | INT ["i"] | REAL ["i"] | "(" expr ")" | "[" matrix_row { "," matrix_row } "]" | "[" expr { "," expr } "]" | | ID | "-" unary | "!" unary | STR;
matrix_row = "[" expr { "," expr } "]";
unaryPostfix = "++" | "--" | [ "<" [ unary { "," unary } ] ">" ] "(" [ expr { "," expr } ] ")" | "[" expr "]";
for = "for" "(" expression ";" expression ";" expression ")" block;
if = "if" "(" expression ")" block [ "else" block ];
block = statement | "{" { statement } "}";
do = "do" block "while" "(" expr ")" EOS;
while = "while" "(" expr ")" block;
switch = "switch" "(" expr ")" "{" { "case" INT ":" { statement } } "default" ":" { statement } "}";
function = "function" ID "(" [ ID { "," ID } ] ")" block;
return = "return" [ expr ] EOS;
break = "break" EOS;
continue = "continue" EOS;
```

_Author: Andreas Schwenk, TH Köln_

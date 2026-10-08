# checked design

This page explains which operations on dual numbers have checked forms, how
their errors arise from the derivative rules, and why the facade reuses the
`arithmetic` error model.

## Design goal

Let differentiated code report invalid operations as values, with the same
error type that scalar Luna Flow code uses, and never return a valid value
with an invalid derivative. The section on
[floating-point domains](#floating-point-domains) shows where the current
implementation falls short of the second goal.

## Constraints

- The checked traits and errors belong to `Luna-Flow/arithmetic`; this
  repository can implement them for `Dual[T]` but cannot add variants.
- A checked dual operation can only use the checked operations of `T`, so
  its errors are those of `T`'s instances.
- `Dual[T]` keeps the unchecked operators `/` and `sqrt` for ordinary
  formulas; the checked forms are separate methods.

## Mathematical background

### Where a derivative fails

A checked operation must fail when either component of
$f(a + b\varepsilon) = f(a) + f'(a)\,b\,\varepsilon$ is undefined. For the
two checked operations:

$$
\begin{aligned}
\frac{a + b\varepsilon}{c + d\varepsilon} &= \frac{a}{c} + \frac{bc - ad}{c^2}\,\varepsilon
  &&\text{needs } c \ne 0, \\
\sqrt{a + b\varepsilon} &= \sqrt a + \frac{b}{2\sqrt a}\,\varepsilon
  &&\text{needs } a > 0 .
\end{aligned}
$$

The quotient fails exactly where the value fails, because $c^2 \ne 0 \iff c
\ne 0$ in exact arithmetic. The square root is different: $\sqrt a$ exists
at $a = 0$, but $\sqrt{\cdot}$ is not differentiable there (its difference
quotient $\sqrt h / h = h^{-1/2}$ is unbounded), so the domain of the dual
operation is the open half-line $a > 0$, smaller than the domain $a \ge 0$
of the scalar square root.

### Floating-point domains

In `Double`, $c^2$ can be zero for non-zero $c$. With rounding to nearest
and gradual underflow, $c^2$ rounds to $0$ exactly when $c^2 \le 2^{-1075}$,
half the smallest subnormal number, that is for
$|c| < 2^{-537.5} \approx 1.57 \times 10^{-162}$, even though $a/c$ may be
finite. The checked quotient then fails in the tangent: with a division by
zero when $bc - ad \ne 0$, and with the domain error of $0/0$ when
$bc - ad = 0$, for example for a constant divided by a constant, whose true
tangent is $0$.

At the other end $c^2$ overflows to $\infty$ for
$|c| \ge 2^{512} \approx 1.34 \times 10^{154}$. `T`'s `div_checked` accepts a
finite numerator over $\infty$, so the checked quotient returns `Ok` with
tangent $0$ even when the true tangent $(bc - ad)/c^2$ is a normal number.
This breaks the design goal: a checked operation returns a wrong derivative
without an error. Rescale such divisors; the
[dual design](dual.md#rounding-error) derives the ranges and a formula that
avoids squaring $c$.

## Design decisions

### Check both components

**Problem.** A checked scalar operation can succeed while the derivative
does not exist.

**Choice.** Each checked dual operation calls the checked scalar operation
for the value and `div_checked` for the tangent division, and returns the
first error. This makes the dual domain the intersection of the domains of
$f$ and $f'$, as derived above; in particular `sqrt_checked` fails at $0$.

### No special case for a zero tangent

At $a = 0$ with $b = 0$ the tangent is the indeterminate $0/0$. One could
return $0$ (a constant input has no derivative to report), but that would
make the result depend on how a constant was produced. The implementation
lets `T` decide: for `Double` this is a domain error.

### Reuse `arithmetic`

`Dual[T]` implements `DivChecked` and `SqrtChecked` from `arithmetic`, and
this facade re-exports exactly those traits with `ArithmeticContext`,
`ArithmeticError`, `ArithmeticErrorKind` and `RoundingMode`. Generic checked
code therefore runs on `Double` and on `Dual[Double]` without adaptation,
and errors from both levels have one type.

### Only division and square root

`arithmetic` defines checked traits for division, square root, comparison,
parsing and integer powers. Of these, only division and square root are
operations on $T[\varepsilon]$ with a derivative rule in this repository, so
only they have checked dual forms. Logarithms and trigonometric functions
follow the unchecked semantics of `T`.

## Correctness and invariants

- `div_checked(x, y)` succeeds exactly when `T`'s `div_checked` succeeds for
  both $a/c$ and $(bc - ad)/c^2$; then it equals `x / y` computed with the
  same operations.
- `sqrt_checked(x)` succeeds exactly when `T`'s `sqrt_checked(a)` and
  `div_checked(b, 2√a)` succeed; for `Double` that is $a > 0$, or $a$ NaN.
- The context is passed to `T` unchanged and never modified.

## Alternatives rejected

- **A dedicated autodiff error type.** It would duplicate `ArithmeticError`
  and force conversions at every boundary.
- **`Option` results.** They lose the reason for the failure.
- **Checking only the value.** It would return infinite or NaN derivatives
  from a "checked" operation.

## Boundaries

- No checked logarithm, exponential or trigonometric operations.
- No contextual (`ArithmeticOutcome`) operations and no rounding
  diagnostics.
- No automatic rescaling of tiny divisors.

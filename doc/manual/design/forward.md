# forward design

This page explains what the scalar drivers `diff` and `value_and_diff`
compute, what they cost, and why they are plain functions over
`Dual[T] -> Dual[T]`.

## Design goal

Give the common case, the derivative of a function of one variable, a
one-line API that hides the seeding of the variable, while keeping all
semantics in `Dual[T]` so that the drivers cannot disagree with the type.

## Mathematical background

### Forward mode

A program computes $y = f(x)$ through intermediates $v_1, \dots, v_m$, each
an operation on earlier ones. Forward mode carries, next to every $v_k$, its
derivative $\dot v_k = dv_k/dx$, and updates it with the chain rule in the
same order as the program:

$$
v_k = \varphi_k(v_{i}, v_{j})
\quad\Longrightarrow\quad
\dot v_k = \frac{\partial \varphi_k}{\partial v_i}\,\dot v_i
         + \frac{\partial \varphi_k}{\partial v_j}\,\dot v_j ,
\qquad \dot x = 1 .
$$

Dual arithmetic performs exactly this update: $v_k + \dot v_k\varepsilon$ is
`Dual::new(v_k, dv_k)`, and the rules of the
[dual design](dual.md#smooth-functions-and-the-chain-rule) are the partial
derivatives of each $\varphi_k$. Seeding $\dot x = 1$ is
`Dual::variable(x)`.

### Higher derivatives by nesting

If `f` is generic in its scalar, it can be applied to `Dual[Dual[T]]`.
Differentiating $x \mapsto f'(x)$ with dual numbers over `Dual[T]` gives

$$
\frac{d}{dx}\,\mathrm{diff}(f, x) = f''(x),
$$

because `diff(f, ·)` is itself a program built from dual operations (on the
inner level). The outer and the inner tangent live in different types, so
the classic *perturbation confusion* of untyped nested forward mode, where
the inner derivative picks up the outer perturbation, is rejected by the
type checker.[^siskind] Each nesting level doubles the number of
components, so the $k$-th derivative costs $2^k$ times a plain evaluation.

[^siskind]: J. M. Siskind and B. A. Pearlmutter, "Perturbation confusion and
referential transparency", IFL 2005, describes the problem for untyped
implementations.

## Design decisions

### Functions, not a trait or a wrapper type

**Problem.** How should a user hand a function to the driver?

**Options.** A trait implemented by a user type; a function on `Double`
plus a separate derivative; a closure over `Dual[T]`.

**Choice.** A closure `(Dual[T]) -> Dual[T]`. MoonBit closures are cheap,
the type makes it explicit that the function must be written for dual
numbers, and generic functions instantiate at `Dual[T]` without wrappers.

### Minimal bound

`value_and_diff` needs only `T : One`, for the seed tangent. Everything
else is required by the operations inside `f`, where the compiler checks it
at the call site.

### Value from the same evaluation

The value is read from the same dual evaluation as the derivative. By the
[projection homomorphism](dual.md#the-value-projection-is-a-homomorphism) it
is bit-for-bit the value `f` would compute on `T`, so no second evaluation
is needed.

### Location in its own package

The drivers live in `forward` so that the `dual` package stays a pure
number type, and the root package re-exports them. `forward` depends only on
`dual` and `luna-generic`.

## Correctness and invariants

- `value_and_diff(f, x) == (f(variable(x)).value(), f(variable(x)).tangent())`
  and `diff(f, x)` is its second component.
- For a program of ring operations, divisions with non-zero divisors and the
  elementary functions in their domains, the result is $(f(x), f'(x))$
  computed with the rounding bounds of the
  [dual design](dual.md#rounding-error).
- The cost is one evaluation of `f` on `Dual[T]`, a small constant factor
  over one evaluation on `T`.

## Alternatives rejected

- **Numerical differentiation inside the driver.** Rejected for the
  accuracy reasons derived in the
  [dual design](dual.md#comparison-with-finite-differences).
- **A `diff_n` for the $n$-th derivative.** Nesting already gives it for
  generic functions, and a truncated Taylor type would be the efficient
  solution; neither is a reason for a second API today.

## Boundaries

- Scalar input only. Several inputs are handled by the
  [linalg](linalg.md) drivers or by seeding `Dual::new` by hand.
- No checked variant: `f` decides whether it uses checked operations, and a
  checked `f` returns its own `Result`.
- No higher-order driver and no reverse mode.

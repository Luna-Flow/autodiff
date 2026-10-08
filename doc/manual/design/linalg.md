# linalg design

This page explains how the `linalg` drivers obtain gradients and Jacobians
from scalar dual numbers, what each one costs, and why the package is shaped
as a thin bridge to `linear-algebra`.

## Design goal

Differentiate functions $f : T^n \to T$ and $f : T^n \to T^m$ written with
the immutable vectors of `linear-algebra`, reusing `Dual[T]` unchanged, with
a small API whose results follow the usual matrix conventions.

## Constraints

- `Dual[T]` carries one scalar tangent, so one evaluation yields one
  directional derivative.
- `linear-algebra` has no shape-error type shared with this repository.
- `Dual[T]` is only a ring, so `f` may use only the ring operations of the
  vectors and matrices.

## Mathematical background

### Directional derivatives from one pass

Let $f : \mathbb R^n \to \mathbb R^m$ be differentiable at $x$ and let $v \in
\mathbb R^n$. Seed every input as $x_j + v_j\varepsilon$. By the
[dual design](dual.md#derivatives-of-whole-programs) each output becomes

$$
f_i(x + v\varepsilon) = f_i(x) + \sum_{j} \frac{\partial f_i}{\partial x_j}(x)\,v_j\,\varepsilon
= f_i(x) + \big(J_f(x)\,v\big)_i\,\varepsilon ,
$$

so one evaluation on dual numbers yields the Jacobian-vector product $J_f(x)
v$. This is the multivariate chain rule: for $g(t) = f(x + tv)$, $g'(0) =
J_f(x) v$.

### Columns by unit seeds

Seeding the unit vector $e_j$ returns the $j$-th column of the Jacobian,
$J_f(x) e_j = \partial f / \partial x_j$. The drivers make $n$ such passes:

$$
J_f(x) = \big[\, J_f(x) e_0 \;\big|\; J_f(x) e_1 \;\big|\; \cdots \;\big|\; J_f(x) e_{n-1} \,\big] .
$$

For $m = 1$ the single row is $\nabla f(x)^{\mathsf T}$, and `gradient`
returns it as a vector.

### Cost compared with reverse mode

Let $C(f)$ be the cost of evaluating $f$ on $T$. One dual pass costs at most
a small constant $c$ times $C(f)$, with $c \le 6$ and typically $3$ to $4$
(see the [dual design](dual.md#cost)), so

$$
C(\texttt{gradient}) \approx n \cdot c \cdot C(f), \qquad
C(\texttt{jacobian}) \approx (n + 1) \cdot c \cdot C(f) .
$$

Reverse mode, which this repository does not implement, propagates
sensitivities the other way. Write the program as intermediates
$v_k = \varphi_k(v_i)_{i \prec k}$ ending in the outputs, and define the
adjoint $\bar v_i = \sum_{\ell} u_\ell\, \partial y_\ell / \partial v_i$ for a
chosen output weight $u \in T^m$, so that $\bar y = u$. Because $v_i$ influences the outputs
only through the $v_k$ that use it, the chain rule gives the backward
recurrence

$$
\bar v_i = \sum_{k \,:\, i \prec k} \bar v_k\,\frac{\partial \varphi_k}{\partial v_i},
\qquad \bar x_j = \bigl(u^{\mathsf T} J_f(x)\bigr)_j ,
$$

evaluated from the outputs back to the inputs. One backward sweep therefore
yields a whole row combination $u^{\mathsf T} J_f(x)$, and for $m = 1$,
$u = 1$, the whole gradient. Each elementary step has a bounded number of
partial derivatives, so the sweep costs a constant multiple of $C(f)$,
independent of $n$, at the price of storing the intermediates (or
recomputing them).[^cheap] The two modes are transposes of each other:
forward mode computes $J_f(x)\,v$, reverse mode $u^{\mathsf T} J_f(x)$.
Forward mode is therefore the right tool when $n$ is small or
$n \lesssim m$, and the slower one for gradients of functions of many
variables.

[^cheap]: This is the "cheap gradient principle"; see A. Griewank and
A. Walther, *Evaluating Derivatives*, 2nd ed., SIAM, 2008, section 4.6.

## Design decisions

### Scalar tangents and $n$ passes

**Problem.** A gradient needs $n$ directional derivatives.

**Options.** A dual type with a vector of $n$ tangents (one pass,
$O(n)$ work per operation); $n$ passes with the scalar `Dual[T]`.

**Choice.** $n$ passes. The total arithmetic is the same order, $O(n \cdot
C(f))$, and the scalar type needs no allocation per operation and no new
number type. A vector-tangent type remains future work.

### Output-by-input convention

The matrix is $m \times n$ with entry $(i, j) = \partial f_i / \partial x_j$,
the convention of the chain rule $J_{f \circ g} = J_f\,J_g$, so results
compose with ordinary matrix multiplication. Column $j$ is pass $j$; the
implementation collects the $n$ output vectors and then builds the matrix
with `Matrix::make(m, n, (i, j) => columns[j][i].tangent())`.

### A separate pass for values and for $m$

`value_and_gradient` and `value_and_jacobian` evaluate `f` once more with
all tangents zero instead of reading the value from one of the seeded
passes. By the [projection homomorphism](dual.md#the-value-projection-is-a-homomorphism)
every pass has the same value, so this costs one evaluation but keeps the
drivers independent of each other and correct for $n = 0$. `jacobian` uses
the same zero-tangent call to learn $m$ before allocating the matrix.

### No shape validation yet

**Problem.** A function may read past its input or change its output
length.

**Options.** Return `Result` with a shape error; abort; document a
precondition.

**Choice.** A documented precondition. `linear-algebra` does not yet share a
shape-error type with this repository, and a private error type would be
replaced later. The source carries a `TODO` for checked variants.

### Only ring operations on `Dual[T]`

The drivers need nothing but `One + Zero` for seeding. Vector and matrix
operations inside `f` use the `Add`, `Mul` and `Neg` instances of
`Dual[T]`, so any `linear-algebra` operation that only needs ring structure
works on dual vectors. Algorithms that need `Field`, `Inverse` or an order
on the scalar (pivoting, for example) cannot be instantiated at `Dual[T]`;
this is intentional, see the [dual design](dual.md#ring-level-instances-only).

## Correctness and invariants

- `gradient(f, x)[j]` $= \partial f / \partial x_j (x)$ and
  `jacobian(f, x)[i][j]` $= \partial f_i / \partial x_j (x)$ for programs
  satisfying the [preconditions](../api/linalg.md#function-shapes-and-preconditions),
  with the rounding bounds of the dual design for each entry.
- `value_and_gradient(f, x)` $= (f(x), \nabla f(x))$ and
  `value_and_jacobian(f, x)` $= (f(x), J_f(x))$; the values are exactly what
  `f` computes on `T`.
- Evaluations: `gradient` $n$, `value_and_gradient` $n + 1$, `jacobian`
  $n + 1$, `value_and_jacobian` $n + 2$.
- Memory: `jacobian` holds the $n$ output vectors of length $m$ before
  building the $m \times n$ matrix.

## Alternatives rejected

- **Reverse mode for gradients.** Asymptotically cheaper for large $n$, but
  it needs a recorded computation and is not implemented.
- **A public Jacobian-vector product.** One pass with
  `Dual::new(x[j], v[j])` already gives $J_f(x) v$ (see the
  [linalg tutorial](../tutorial/linalg.md#compute-a-jacobian-vector-product));
  a dedicated function would add little.
- **Mutable matrices.** The drivers return `immut` values, which match the
  value semantics of the rest of the repository.

## Boundaries

- Forward mode only: no reverse mode, and no Hessian or higher-order
  driver.
- No shape checking and no checked variants.
- Dense `immut` vectors and matrices only; no sparse or mutable containers.
- No algorithms that need a field or an order on `Dual[T]`.

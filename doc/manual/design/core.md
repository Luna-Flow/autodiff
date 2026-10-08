# core design

This page explains why the `core` facade exists and why it contains exactly
the ring-level vocabulary of `Dual[T]`.

## Design goal

Offer the smallest import for code that only needs the algebra of dual
numbers: ring operations, identities and integer constants, without the
analytic traits and error types of `arithmetic`.

## Constraints

- A facade can only re-export names; it cannot add instances or methods,
  which live with `Dual[T]` in `dual`.
- The name `core` is taken inside this module, so examples import the
  package under the alias `@ad_core`.

## Mathematical background

Many differentiable programs are polynomial: they use only $+$, $-$,
$\times$ and integer constants. For those, the identity of the
[dual design](dual.md#polynomials-where-derivatives-come-from)

$$
p(a + b\varepsilon) = p(a) + p'(a)\,b\,\varepsilon
$$

holds in every commutative ring, so the traits `Zero`, `One`, `AddMonoid`,
`AddGroup`, `MulMonoid`, `Semiring`, `Ring` and the canonical map
$\mathbb Z \to T$ (`IntegralHomomorphism`) are all such code needs. The
facade re-exports exactly these. In `luna-generic` each trait extends the
ones before it,

$$
\begin{aligned}
\texttt{AddGroup} &: \texttt{AddMonoid} + \texttt{Neg} + \texttt{Sub}, &
\texttt{Semiring} &: \texttt{AddMonoid} + \texttt{MulMonoid}, \\
\texttt{Ring} &: \texttt{Semiring} + \texttt{Neg} + \texttt{Sub}, &
\texttt{IntegralHomomorphism} &: \texttt{NatHomomorphism},
\end{aligned}
$$

so the classes of structures shrink as the traits grow: every ring is a
semiring and an additive group, and every semiring and every additive group
is an additive monoid,

$$
\mathbf{Ring} \subset \mathbf{Semiring} \subset \mathbf{AddMonoid},
\qquad
\mathbf{Ring} \subset \mathbf{AddGroup} \subset \mathbf{AddMonoid} .
$$

The instances on $T[\varepsilon]$ are derived in the
[dual design](dual.md#ring-level-instances-only).

## Design decisions

### A separate facade for the algebra

**Problem.** The root package also re-exports the analytic traits and the
checked error types, which belong to another layer of the ecosystem.

**Choice.** `core` re-exports only `Dual` and the `luna-generic` structure
traits. Its `moon.pkg` imports `dual` and `luna-generic` only, so a reader
of an import list can see that the code is purely algebraic.

### Re-export, do not redefine

As in the [autodiff design](autodiff.md#re-export-with-pub-using), the
names are `pub using` aliases of the original traits, so instances are
shared with the rest of Luna Flow.

## Correctness and invariants

- `core` defines no items; its interface file contains only `pub using`
  lines.
- It depends on `autodiff/dual` and `luna-generic` and on nothing else.
- Every re-exported trait has an instance on `Dual[T]` under the matching
  bound on `T`.

## Alternatives rejected

- **Merging `core` into the root package.** The root package also carries
  `arithmetic`; keeping the algebra apart keeps that layering visible.
- **Re-exporting `Field` or `Inverse`.** `Dual[T]` does not implement them,
  so they would only invite unsatisfiable bounds.

## Boundaries

- No analytic traits, no checked operations, no drivers.
- No `Field`, `MulGroup`, `Inverse` or `NatHomomorphism`.

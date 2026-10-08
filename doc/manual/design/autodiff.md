# autodiff design

This page explains why the root package `Luna-Flow/autodiff` is a pure
re-export facade and how its surface was chosen.

## Design goal

One import should be enough to differentiate scalar code: the number type,
the drivers, and every trait that appears in the bounds of `Dual[T]`. At the
same time no behaviour may live in two places, so that the root package can
never disagree with `dual` and `forward`.

## Constraints

- `pub using` re-exports a name without creating a new item, so the root
  package can only offer names that exist elsewhere.
- The root package must not depend on `linear-algebra` or `luna-poly`, so
  that the scalar use case stays light.

## Mathematical background

The root package adds no mathematics. Its content is the vocabulary of the
[dual design](dual.md): the commutative ring $T[\varepsilon]/(\varepsilon^2)$
needs the structure traits `Zero`, `One`, `AddMonoid`, `AddGroup`,
`MulMonoid`, `Semiring` and `Ring`; the elementary rules
$f(a + b\varepsilon) = f(a) + f'(a)\,b\,\varepsilon$ need `Sqrt`,
`Exponential`, `Logarithmic` and `Trigonometric` on `T` and the canonical
map $\mathbb Z \to T$ (`FromInteger`); the checked rules need
`DivChecked`, `SqrtChecked` and the context and error values; and
`Constants` provides $\pi$, $\tau$ and $e$ as dual constants.

## Design decisions

### Re-export with `pub using`

**Problem.** Users of `Dual[T]` write bounds such as `T : Ring +
Trigonometric`, which name traits from two other modules.

**Options.** Ask users to import `luna-generic` and `arithmetic` themselves;
define local traits; re-export.

**Choice.** `pub using` re-exports in
[`src/alias.mbt`](../../../src/alias.mbt). A re-exported name is the
original trait or type, so instances written against `@lg.Ring` or
`@arithmetic.Sqrt` work with `@autodiff.Ring` and `@autodiff.Sqrt`, and no
second trait hierarchy exists. Defining local traits would split the
ecosystem and break instance sharing.

### Exactly the bounds of `Dual[T]`

The root package re-exports the traits that occur in the bounds of the
public `Dual` methods and instances, plus the error and context types of the
checked methods. It does not re-export `Field`, `MulGroup` or `Inverse`
(which `Dual[T]` deliberately lacks), nor the contextual or enclosure traits
of `arithmetic`, which `Dual[T]` does not implement. `FromNat` occurs in no
method bound, but it is re-exported because `FromInteger` extends it. The
deprecated `NatHomomorphism` and `IntegralHomomorphism` are left out: their
instances on `Dual[T]` are compatibility shims for `luna-poly` 0.2.0, and
new code should not name them.

### Drivers but no bridges

`diff` and `value_and_diff` are re-exported because they only need `dual`.
The `linalg` and `poly` drivers are not, because re-exporting them would make
every user of the root package depend on `linear-algebra` and `luna-poly`.

## Correctness and invariants

- The root package defines no functions, types or instances. Its
  `pkg.generated.mbti` lists `diff` and `value_and_diff` as `pub fn` lines,
  because `pub using @forward {value_and_diff, diff}` re-exports values, and
  every other item as a `pub using` line.
- `@autodiff.Dual`, `@dual.Dual`, `@forward.Dual` and the facade types are
  the same type.
- The root package depends on `dual`, `forward`, `luna-generic` and
  `arithmetic` only.

## Alternatives rejected

- **A prelude with every Luna Flow trait.** It would advertise traits that
  `Dual[T]` does not implement and invite wrong bounds.
- **Moving the implementation to the root package.** It would force the
  heavy bridges and the light core into one package, or create a dependency
  cycle with them.

## Boundaries

- No behaviour of its own; everything is documented on the
  [dual](dual.md) and [forward](forward.md) pages.
- No re-export of `linalg`, `poly` or their container types.
- No re-export of `Field`, `MulGroup`, `Inverse`, the deprecated
  `NatHomomorphism` / `IntegralHomomorphism` or the contextual arithmetic
  traits.

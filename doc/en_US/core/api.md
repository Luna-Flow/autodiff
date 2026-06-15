# Core API

This document describes the core public API for dual-number forward-mode
automatic differentiation. Ecosystem bridge APIs are documented in
[`../integration/api.md`](../integration/api.md).

## Dual Numbers

```moonbit
pub struct Dual[T] {
  value : T
  tangent : T
}
```

`value` is the primal scalar. `tangent` is the first-order derivative component.

## Constructors

- `Dual::new(value, tangent)` constructs a dual number directly.
- `Dual::constant(x)` constructs `Dual(x, zero)`.
- `Dual::variable(x)` constructs `Dual(x, one)`.

`constant` uses `Zero` from `Luna-Flow/luna-generic`. `variable` uses `One`.

## Accessors

- `Dual::value(self)` returns the primal value.
- `Dual::tangent(self)` returns the tangent value.

## Algebra

The implemented operations are:

- Addition: `(x, dx) + (y, dy) = (x + y, dx + dy)`
- Subtraction: `(x, dx) - (y, dy) = (x - y, dx - dy)`
- Negation: `-(x, dx) = (-x, -dx)`
- Multiplication: `(x, dx) * (y, dy) = (x * y, x * dy + y * dx)`

`Dual[T]` implements Luna Flow ring-level traits when the base type supports the
required operations. It intentionally does not implement `Field`, `MulGroup`,
`Inverse`, or total ordering.

## Checked Arithmetic

Checked division uses `DivChecked`:

```text
Dual(x, dx) / Dual(y, dy)
= Dual(x / y, (dx * y - x * dy) / (y * y))
```

Failures are returned as `Result[Dual[T], ArithmeticError]` using
`ArithmeticContext` from `Luna-Flow/arithmetic`.

Checked square root uses `SqrtChecked` and `DivChecked`:

```text
sqrt(x, dx) = (sqrt(x), dx / (2 * sqrt(x)))
```

## Elementary Functions

The current elementary lifts include:

- `sqrt`
- `exp`
- `ln`, `log2`, `log10`
- `sin`, `cos`, `tan`

Domain and branch behavior follows the base scalar implementation unless a
checked trait is used.

## Forward Helpers

- `value_and_diff(f, x)` evaluates `f(Dual::variable(x))` and returns
  `(value, derivative)`.
- `diff(f, x)` returns only the derivative.

## Package Boundaries

The core dual-number packages stay lightweight. They depend on
`Luna-Flow/luna-generic` and, for checked or elementary operations,
`Luna-Flow/arithmetic`. They do not import `linear-algebra`, `luna-poly`,
`floating`, or `type_theory`.

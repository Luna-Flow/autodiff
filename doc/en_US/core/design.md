# Design Notes

Luna Autodiff v0.1 is deliberately small. It provides forward-mode automatic
differentiation with dual numbers and avoids symbolic algebra, reverse mode, and
optimizer APIs.

## Package Ownership

`Dual[T]` is owned by the `dual` package so MoonBit methods and trait
implementations can live with the type. The `core`, `checked`, `elementary`,
`forward`, and root packages are lightweight facades over that implementation.

## Algebraic Constraints

Dual numbers are ring-like but not field-like. The value `0 + 1ε` is nonzero and
nilpotent, so it cannot have a multiplicative inverse. For this reason,
`Dual[T]` must not implement `Field`, `MulGroup`, or `Inverse`.

Dual numbers also do not have a natural total order. The package does not
implement `Compare` for `Dual[T]`.

## Checked Semantics

Checked operations reuse `Luna-Flow/arithmetic`:

- `ArithmeticContext`
- `ArithmeticError`
- `DivChecked`
- `SqrtChecked`

This keeps error handling compatible with the wider Luna Flow ecosystem.

## Out Of Scope

The following are future work, not v0.1 features:

- vector-valued forward mode
- gradients and Jacobians over linear algebra types
- higher-order `Jet[T]` derivatives
- polynomial integration
- validated automatic differentiation over interval or ball scalars
- reverse-mode automatic differentiation

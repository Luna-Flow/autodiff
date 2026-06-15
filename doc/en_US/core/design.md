# Design Notes

autodiff v0.2 keeps the core deliberately small while adding ecosystem
integration packages. The core still provides forward-mode automatic
differentiation with dual numbers and avoids symbolic algebra, reverse mode, and
optimizer APIs.

## Package Ownership

`Dual[T]` is owned by the `dual` package so MoonBit methods and trait
implementations can live with the type. The `core`, `checked`, `elementary`,
`forward`, and root packages are lightweight facades over that implementation.

The `linalg` and `poly` packages are integration layers. They depend on the
external Luna Flow libraries they bridge to, but lower-level autodiff packages
do not depend on them.

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

The following remain future work, not v0.2 integration features:

- vector-valued tangent storage for `Forward[T]`
- higher-order `Jet[T]` derivatives
- validated automatic differentiation over interval or ball scalars
- reverse-mode automatic differentiation
- symbolic differentiation through a CAS layer

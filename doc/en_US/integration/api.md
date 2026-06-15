# Ecosystem Integration API

This document describes the v0.2 bridge packages for Luna Flow ecosystem
libraries.

## `autodiff/linalg`

The `linalg` package uses immutable vectors and matrices from
`Luna-Flow/linear-algebra/immut`.

- `gradient(f, x) -> Vector[T]`
- `jacobian(f, x) -> Matrix[T]`
- `value_and_gradient(f, x) -> (T, Vector[T])`
- `value_and_jacobian(f, x) -> (Vector[T], Matrix[T])`

`gradient` expects:

```text
f : Vector[Dual[T]] -> Dual[T]
x : Vector[T]
```

`jacobian` expects:

```text
f : Vector[Dual[T]] -> Vector[Dual[T]]
x : Vector[T]
```

The Jacobian uses the output-by-input convention:

```text
J[row = output_index, col = input_index]
```

The package uses n-pass forward-mode seeding. It does not require or define
field-level behavior for `Dual[T]`.

## `autodiff/poly`

The `poly` package bridges to `Luna-Flow/luna-poly`.

Dense univariate helpers:

- `eval_dual(p, x_dual) -> Dual[T]`
- `value_and_derivative_at(p, x) -> (T, T)`
- `derivative_at(p, x) -> T`

Sparse univariate-as-one-variable helpers:

- `eval_sparse_dual(p, x_dual) -> Dual[T]`
- `sparse_value_and_derivative_at(p, x) -> (T, T)`
- `sparse_derivative_at(p, x) -> T`

These functions evaluate existing Luna Poly representations over dual numbers.
They do not perform symbolic differentiation and do not introduce a new
polynomial representation.

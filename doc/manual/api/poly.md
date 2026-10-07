# poly API

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

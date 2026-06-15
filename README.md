# autodiff

Luna Autodiff provides forward-mode automatic differentiation over Luna Flow
algebraic and arithmetic structures, with ecosystem integrations for linear
algebra and polynomial evaluation.

The core scalar representation is a dual number:

```text
Dual[T] = value + tangent ε, ε² = 0
```

Evaluating a scalar function on `Dual::variable(x)` computes the ordinary value
and the first derivative in one pass.

```moonbit
let d = @autodiff.diff(fn(x) { x * x + x.sin() }, 2.0)
```

## Overview

The current v0.2 API includes:

- `Dual[T]` with primal `value` and first-order `tangent`.
- `Dual::constant(x)` for zero-tangent constants.
- `Dual::variable(x)` for unit-tangent differentiation variables.
- Ring-level algebraic operations lifted from the base scalar type.
- Checked division through `ArithmeticContext`, `ArithmeticError`, and
  `DivChecked` from `Luna-Flow/arithmetic`.
- Lifted elementary operations such as `sqrt`, `exp`, `ln`, `sin`, `cos`, and
  `tan` when the base type supports the required Luna Flow traits.
- `diff` and `value_and_diff` for scalar forward-mode differentiation.
- `autodiff/linalg` for gradients and Jacobians over Luna Flow immutable
  vectors and matrices.
- `autodiff/poly` for differentiating Luna Poly polynomials by evaluating them
  over `Dual[T]`.

## Dual Number Semantics

`Dual[T]` participates in Luna Flow algebra through `Luna-Flow/luna-generic`.
It implements valid structures such as `Zero`, `One`, `AddMonoid`,
`MulMonoid`, `AddGroup`, `Semiring`, and `Ring` when the base type provides the
required operations.

`Dual[T]` is intentionally not a field. Dual numbers contain nonzero nilpotent
values such as `0 + 1ε`, so not every nonzero dual number has a multiplicative
inverse.

`Dual[T]` also has no natural total order, so the package does not define one.

Division remains checked or explicitly partial. Checked operations reuse
`Luna-Flow/arithmetic` instead of introducing a duplicate error hierarchy.

## Ecosystem Integration

### Linear Algebra

`autodiff/linalg` provides `gradient`, `jacobian`, `value_and_gradient`, and
`value_and_jacobian` for Luna Flow `linear-algebra` immutable vectors and
matrices.

The helpers use n-pass forward-mode seeding. Each input coordinate is seeded
with tangent `1` in a separate pass, the function is evaluated, and output
tangents are collected.

Jacobians use the output-by-input convention:

```text
J[row = output_index, col = input_index]
```

For example:

```text
f(x, y) = [x + y, x*y, x²]
J = [
  [1, 1],
  [y, x],
  [2x, 0]
]
```

`Dual[T]` is treated as a ring-level scalar. The integration does not make
`Dual[T]` a field and does not enable matrix algorithms that require total
division, inverses, or a total order.

### Polynomial

`autodiff/poly` evaluates Luna Poly polynomials over `Dual[T]`. This gives
`p(x)` and `p'(x)` in one evaluation:

```text
p(Dual::variable(x)) = Dual(p(x), p'(x))
```

This is evaluation-based automatic differentiation, not symbolic
differentiation or CAS-style simplification. The bridge reuses `luna-poly`
representations, construction, normalization, and evaluation.

Currently supported representations:

- Dense univariate polynomials from `Luna-Flow/luna-poly/immut/dense`.
- Sparse polynomials from `Luna-Flow/luna-poly/immut/sparse` through a
  single-variable/univariate helper.

Sparse support currently evaluates with the single assignment `[x]`. It should
be read as a univariate AD helper over sparse terms, not as arbitrary
multivariate partial differentiation.

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 0.0, 1.0])
let result = @poly.eval_dual(p, @poly.Dual::variable(3.0))
// result = Dual(34, 29)
```

Compatibility names such as `value_and_derivative_at` and
`sparse_derivative_at` remain available. Clearer aliases include
`dense_value_and_derivative_at` and
`sparse_univariate_value_and_derivative_at`.

## Roadmap

Implemented in v0.2:

- Forward-mode scalar AD through `Dual[T]`.
- Lifted algebraic, checked arithmetic, and elementary scalar operations.
- Gradient and Jacobian helpers over `linear-algebra` vectors and matrices.
- Dense and sparse-univariate polynomial AD bridges over `luna-poly`.

Future work:

- `Forward[T]` with vector-valued tangent storage.
- `Jet[T]` for higher-order derivatives and Taylor expansion.
- Validated AD over `floating` / `ball_float`.
- Reverse-mode AD.
- Symbolic differentiation through a future symbolic layer.
- Context-aware multivariate polynomial partial derivatives.

These remain deliberately out of scope for the v0.2 integration layer.

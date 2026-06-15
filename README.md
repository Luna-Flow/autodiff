# autodiff

autodiff provides forward-mode automatic differentiation over Luna Flow
algebraic and arithmetic structures.

The first version introduces dual numbers as first-class scalar values:

```text
Dual[T] = value + tangent ε, ε² = 0
```

Evaluating a scalar function on `Dual::variable(x)` computes the ordinary value
and the first derivative in one pass.

```moonbit
let d = @autodiff.diff(fn(x) { x * x + x.sin() }, 2.0)
```

## v0.2 Scope

This package starts small:

- `Dual[T]` stores a primal `value` and first-order `tangent`.
- `Dual::constant(x)` embeds constants with zero tangent.
- `Dual::variable(x)` embeds the differentiation variable with unit tangent.
- Ring-level algebraic operations are lifted from the base scalar type.
- Checked division reuses `ArithmeticContext`, `ArithmeticError`, and
  `DivChecked` from `Luna-Flow/arithmetic`.
- Elementary scalar operations such as `sqrt`, `exp`, `ln`, `sin`, `cos`, and
  `tan` are lifted where the base type supports the required Luna Flow traits.
- `diff` and `value_and_diff` provide a direct forward-mode API.
- `autodiff/linalg` provides gradient and Jacobian helpers over Luna Flow
  immutable vectors and matrices.
- `autodiff/poly` differentiates Luna Poly polynomials by evaluating them over
  `Dual[T]`.

## Luna Flow Integration

`Dual[T]` participates in Luna Flow algebra through `Luna-Flow/luna-generic`.
It implements valid structures such as `Zero`, `One`, `AddMonoid`,
`MulMonoid`, `AddGroup`, `Semiring`, and `Ring` when the base type provides the
required operations.

`Dual[T]` is intentionally not a field. Dual numbers contain nonzero nilpotent
values such as `0 + 1ε`, so not every nonzero dual number has a multiplicative
inverse. The package also does not define a total order for dual numbers.

Elementary and checked operations build on `Luna-Flow/arithmetic` instead of
introducing a separate error hierarchy or duplicate numeric traits.

## Ecosystem Integration

### `autodiff/linalg`

`autodiff/linalg` integrates `Dual[T]` with `Luna-Flow/linear-algebra`.
It provides `gradient`, `jacobian`, `value_and_gradient`, and
`value_and_jacobian` for immutable vectors and matrices.

The helpers use simple n-pass forward-mode seeding: one input coordinate is
given tangent `1` per pass, the function is evaluated, and output tangents are
collected. Jacobians use the output-by-input convention:

```text
J[row = output_index, col = input_index]
```

`Dual[T]` is treated as a ring-level scalar. The integration does not make
`Dual[T]` a field and does not enable matrix algorithms that require total
division or inverses.

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let g = @linalg.gradient(
  fn(v) { v[0] * v[0] + v[0] * v[1] },
  x,
)
// g = [7, 2]

let j = @linalg.jacobian(
  fn(v) { @la.Vector::from_array([v[0] + v[1], v[0] * v[1]]) },
  x,
)
// j = [[1, 1], [3, 2]]
```

### `autodiff/poly`

`autodiff/poly` integrates with `Luna-Flow/luna-poly`. It evaluates existing
polynomial representations over `Dual[T]` so the primal result is `p(x)` and
the tangent is `p'(x)`.

This is not symbolic differentiation and does not introduce a separate
polynomial representation. The bridge reuses Luna Poly construction,
normalization, and evaluation.

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
let (value, derivative) = @poly.value_and_derivative_at(p, 3.0)
// value = 16, derivative = 8
```

## Roadmap

Implemented or partially implemented:

- gradient and Jacobian helpers over linear-algebra vectors and matrices
- polynomial bridge with `luna-poly`

Future versions may add:

- `Forward[T]` with vector-valued tangent storage
- `Jet[T]` for higher-order derivatives and truncated Taylor expansion
- validated automatic differentiation over `floating` / `ball_float`
- reverse-mode automatic differentiation
- symbolic differentiation through a CAS layer

These remain deliberately out of scope for the v0.2 integration layer.

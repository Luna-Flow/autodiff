# Luna Autodiff

Luna Autodiff provides forward-mode automatic differentiation over Luna Flow
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

## v0.1 Scope

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

## Roadmap

Future versions may add:

- `Forward[T]` with vector-valued partial derivatives
- gradient and Jacobian helpers over linear-algebra vectors and matrices
- `Jet[T]` for higher-order derivatives and truncated Taylor expansion
- a polynomial bridge with `luna-poly`
- validated automatic differentiation over `floating` / `ball_float`
- reverse-mode automatic differentiation

These are deliberately out of scope for v0.1.

# Tutorial

## Differentiate A Scalar Function

Use `diff` to compute the derivative of a scalar function.

```moonbit
let d = @autodiff.diff(fn(x) { x * x }, 3.0)
```

The result is `6.0`.

## Keep Value And Derivative

Use `value_and_diff` when both outputs are needed.

```moonbit
let (value, derivative) = @autodiff.value_and_diff(
  fn(x) { x * x * x },
  2.0,
)
```

The value is `8.0` and the derivative is `12.0`.

## Constants And Variables

`Dual::constant(x)` has zero tangent. `Dual::variable(x)` has unit tangent.

```moonbit
let c = @autodiff.Dual::constant(5.0)
let x = @autodiff.Dual::variable(2.0)
```

Constants differentiate to zero. The identity variable differentiates to one.

## Elementary Functions

Elementary methods can be used when the base scalar supports the corresponding
Luna Flow arithmetic trait.

```moonbit
let d = @autodiff.diff(fn(x) { x.sin() }, 0.5)
```

The derivative is `cos(0.5)`.

## Checked Division

Use `DivChecked::div_checked` when division failure must be returned as data.
The operation reuses `ArithmeticError` and `ArithmeticContext` from
`Luna-Flow/arithmetic`.

## Next Steps

Use the integration tutorial for gradients, Jacobians, and polynomial
derivative-at-a-point helpers:

- [../integration/tutorial.md](../integration/tutorial.md)

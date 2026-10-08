# core tutorial

This tutorial writes ring-level generic code with the `core` facade and
differentiates it. You will define functions once for any ring, run them on
integers, floating-point numbers and dual numbers, and build integer
constants inside generic code. The background is in the
[core design](../design/core.md).

## Quick start

```bash
moon add Luna-Flow/autodiff@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff/core" @ad_core,
}
```

```moonbit
fn[T : @ad_core.Ring] square_minus(x : T, y : T) -> T {
  x * x - y
}

fn main {
  println(square_minus(3, 1))
  println(square_minus(3.0, 1.0))
  let d = square_minus(@ad_core.Dual::variable(3.0), @ad_core.Dual::constant(1.0))
  println("value \{d.value()}, derivative \{d.tangent()}")
}
```

```text
8
8
value 8, derivative 6
```

## Everyday tasks

### Integer constants in generic code

Literals have a fixed type; inside a generic function, make constants with
`IntegralHomomorphism::from_integral`:

```moonbit
fn[T : @ad_core.Ring + @ad_core.IntegralHomomorphism] cubic(x : T) -> T {
  let two : T = @ad_core.IntegralHomomorphism::from_integral(2)
  let seven : T = @ad_core.IntegralHomomorphism::from_integral(7)
  two * x * x * x - seven
}

fn main {
  let y = cubic(@ad_core.Dual::variable(1.5))
  println("value \{y.value()}, derivative \{y.tangent()}")
}
```

```text
value -0.25, derivative 13.5
```

On `Dual[T]`, `from_integral` produces constants with tangent zero.

### Identities

`Zero::zero()` and `One::one()` are constants of any ring, including
`Dual[T]`:

```moonbit
fn[T : @ad_core.Ring] power(x : T, n : Int) -> T {
  let mut acc : T = @ad_core.One::one()
  for _ in 0..<n {
    acc = acc * x
  }
  acc
}

fn main {
  let y = power(@ad_core.Dual::variable(2.0), 10)
  println("2^10 = \{y.value()}, d/dx x^10 at 2 = \{y.tangent()}")
}
```

```text
2^10 = 1024, d/dx x^10 at 2 = 5120
```

### Generic code over a semiring

Code that needs no subtraction can ask for `Semiring` only, so it also
accepts unsigned integers:

```moonbit
fn[T : @ad_core.Semiring] sum_of_squares(xs : Array[T]) -> T {
  let mut acc : T = @ad_core.Zero::zero()
  for x in xs {
    acc = acc + x * x
  }
  acc
}

fn main {
  println(sum_of_squares([1U, 2U, 3U]))
  let d = sum_of_squares([@ad_core.Dual::variable(3.0), @ad_core.Dual::constant(4.0)])
  println("value \{d.value()}, derivative \{d.tangent()}")
}
```

```text
14
value 25, derivative 6
```

## Going further

- The same generic functions can be passed to `@autodiff.diff`, see the
  [forward tutorial](forward.md).
- For `sqrt`, `exp`, `sin` and friends you need the analytic traits; import
  [`elementary`](elementary.md) or the root package.
- Your own number type joins by implementing the `luna-generic` traits; it
  then works both directly and as the `T` of `Dual[T]`.

## Common pitfalls

- **No division.** `core` has no `Field`; use the `Div` operator on
  concrete types or the [checked](checked.md) facade.
- **`one()` is not the variable.** `One::one()` on `Dual[T]` has tangent
  zero; seed the variable with `Dual::variable`.
- **Unsigned types stop at `Semiring`.** `UInt` has no `Ring` instance, so
  functions bounded by `Ring` do not accept it.

## Next steps

- The [core API](../api/core.md) lists the re-exported traits and their
  `Dual[T]` instances.
- The [dual design](../design/dual.md) proves the ring laws of
  $T[\varepsilon]$.
- [luna-generic](https://lunaflow.cn/en/luna-generic/) documents the trait
  hierarchy.

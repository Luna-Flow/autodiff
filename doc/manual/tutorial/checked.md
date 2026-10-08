# checked tutorial

This tutorial differentiates code that can fail. You will call the checked
division and square root on dual numbers, propagate their errors through a
computation, and write generic checked code that runs on plain and dual
numbers. The reasoning is in the [checked design](../design/checked.md).

## Quick start

```bash
moon add Luna-Flow/autodiff@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff/checked",
}
```

```moonbit
fn main {
  let ctx = @checked.ArithmeticContext::new(53)
  let x : @checked.Dual[Double] = @checked.Dual::variable(2.0)
  let y : @checked.Dual[Double] = @checked.Dual::constant(8.0)
  match y.div_checked(x, ctx) {
    Ok(q) => println("8/x at 2: value \{q.value()}, derivative \{q.tangent()}")
    Err(e) => println("failed: \{e.message}")
  }
}
```

```text
8/x at 2: value 4, derivative -2
```

## Everyday tasks

### Inspect the failure

```moonbit
fn main {
  let ctx = @checked.ArithmeticContext::new(53)
  let one : @checked.Dual[Double] = @checked.Dual::constant(1.0)
  for c in [1.0, 0.0] {
    match one.div_checked(@checked.Dual::variable(c), ctx) {
      Ok(q) => println("1/x at \{c}: derivative \{q.tangent()}")
      Err(e) => println("1/x at \{c}: \{e.message}")
    }
  }
}
```

```text
1/x at 1: derivative -1
1/x at 0: division by zero
```

### Chain checked steps

Each step returns a `Result`; stop at the first error:

```moonbit
fn norm_ratio(
  x : @checked.Dual[Double],
  y : @checked.Dual[Double],
  ctx : @checked.ArithmeticContext,
) -> Result[@checked.Dual[Double], @checked.ArithmeticError] {
  // sqrt(x^2 + y^2) / y
  let r = (x * x + y * y).sqrt_checked(ctx)
  match r {
    Err(e) => Err(e)
    Ok(r) => r.div_checked(y, ctx)
  }
}

fn main {
  let ctx = @checked.ArithmeticContext::new(53)
  let y : @checked.Dual[Double] = @checked.Dual::constant(4.0)
  match norm_ratio(@checked.Dual::variable(3.0), y, ctx) {
    Ok(v) => println("value \{v.value()}, d/dx \{v.tangent()}")
    Err(e) => println(e.message)
  }
  let zero : @checked.Dual[Double] = @checked.Dual::constant(0.0)
  match norm_ratio(@checked.Dual::variable(0.0), zero, ctx) {
    Ok(_) => println("unexpected")
    Err(e) => println("at the origin: \{e.message}")
  }
}
```

```text
value 1.25, d/dx 0.15
at the origin: zero divided by zero is undefined
```

At the origin the square root is evaluated at $0$, where it has no
derivative, so the chain stops there.

### Generic checked code

Bound the function by the checked traits; it then runs on `Double` and on
`Dual[Double]`:

```moonbit
fn[T : @checked.DivChecked + @checked.SqrtChecked] sqrt_ratio(
  a : T,
  b : T,
  ctx : @checked.ArithmeticContext,
) -> Result[T, @checked.ArithmeticError] {
  match @checked.DivChecked::div_checked(a, b, ctx) {
    Err(e) => Err(e)
    Ok(q) => @checked.SqrtChecked::sqrt_checked(q, ctx)
  }
}

fn main {
  let ctx = @checked.ArithmeticContext::new(53)
  match sqrt_ratio(8.0, 2.0, ctx) {
    Ok(v) => println("plain: \{v}")
    Err(e) => println(e.message)
  }
  let a : @checked.Dual[Double] = @checked.Dual::variable(8.0)
  let b : @checked.Dual[Double] = @checked.Dual::constant(2.0)
  match sqrt_ratio(a, b, ctx) {
    Ok(v) => println("dual: \{v.value()}, d/da \{v.tangent()}")
    Err(e) => println(e.message)
  }
}
```

```text
plain: 2
dual: 2, d/da 0.125
```

## Going further

- `ArithmeticContext::new(precision, rounding=…)` builds the context for
  scalar types that use it; `Double` and `Float` ignore it.
- Functions passed to `@autodiff.diff` can use the checked operations; the
  [forward tutorial](forward.md#differentiate-through-a-checked-operation)
  shows how to carry the error out of the closure.
- A custom scalar type takes part by implementing `DivChecked` and
  `SqrtChecked`; its errors then appear unchanged in dual results.

## Common pitfalls

- **`sqrt_checked` fails at zero.** The derivative does not exist there,
  even when the input is a constant.
- **Tiny divisors.** $c^2$ underflows for $|c| < 1.5 \times 10^{-162}$, and
  the tangent division reports a division by zero.
- **Unchecked operators stay unchecked.** `x / y` and `x.sqrt()` on dual
  numbers never return errors; use the `_checked` forms.

## Next steps

- The [checked API](../api/checked.md) lists the re-exported names.
- The [dual API](../api/dual.md#checked-operations) gives the exact error
  table.
- [arithmetic](https://lunaflow.cn/en/arithmetic/) documents the error
  model.

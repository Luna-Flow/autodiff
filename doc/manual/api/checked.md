# checked API

## Purpose

The `checked` package is the facade for differentiation with checked
domains. It re-exports `Dual`, the two checked traits that `Dual[T]`
implements, `DivChecked` and `SqrtChecked`, and the context and error types
they use, all from [arithmetic](https://lunaflow.cn/en/arithmetic/). The
checked rules themselves are documented on the
[dual API](dual.md#checked-operations).

Source: [`src/checked/alias.mbt`](../../../src/checked/alias.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/checked",
}
```

## Re-exported type

### `Dual`

The dual number type; its checked methods are `Dual::div_checked` and
`Dual::sqrt_checked`.

```mbti
pub using @dual {type Dual}
```

## Checked traits

### `DivChecked`

Division that returns `Result[Self, ArithmeticError]`.

```mbti
pub using @arithmetic {trait DivChecked}
```

On `Dual[T]` (for `T : DivChecked + Sub + Mul`) it computes $a/c$ and $(bc -
ad)/c^2$ with `T`'s `div_checked` and returns the first error. For `Double`
(with `arithmetic` 0.5) it fails with `is_division_by_zero()` when $c = 0 \ne a$ and with
`is_domain_error()` for $0/0$ and $\infty/\infty$.

### `SqrtChecked`

Square root that returns `Result[Self, ArithmeticError]`.

```mbti
pub using @arithmetic {trait SqrtChecked}
```

On `Dual[T]` it computes $\sqrt a$ with `T`'s `sqrt_checked` and the tangent
$b/(2\sqrt a)$ with `div_checked`. For `Double` (with `arithmetic` 0.5) it
fails for $a < 0$
(domain error) and for $a = 0$ (division by zero, or $0/0$ when $b = 0$).

```moonbit
test "checked traits on dual numbers" {
  let ctx = @checked.ArithmeticContext::new(53)
  let x : @checked.Dual[Double] = @checked.Dual::variable(4.0)
  match @checked.SqrtChecked::sqrt_checked(x, ctx) {
    Ok(r) => assert_eq(r.tangent(), 0.25)
    Err(_) => fail("unexpected error")
  }
  let z : @checked.Dual[Double] = @checked.Dual::constant(0.0)
  assert_true(@checked.DivChecked::div_checked(x, z, ctx) is Err(_))
}
```

## Context and errors

### `ArithmeticContext`

The explicit numeric context passed to every checked call.

```mbti
pub using @arithmetic {type ArithmeticContext}
```

Build it with `ArithmeticContext::new(precision, rounding?, e_min?, e_max?,
clamp?)`. `Dual[T]` passes it to `T` unchanged; the `Double` and `Float`
instances ignore it.

### `RoundingMode`

The rounding direction stored in a context.

```mbti
pub using @arithmetic {type RoundingMode}
```

### `ArithmeticError`

The structured error returned by checked operations: a `kind` and a
human-readable `message`.

```mbti
pub using @arithmetic {type ArithmeticError}
```

The predicates `is_division_by_zero()` and `is_domain_error()` cover every
error that the checked `Dual` operations produce for `Double`.

### `ArithmeticErrorKind`

The kind of an `ArithmeticError`.

```mbti
pub using @arithmetic {type ArithmeticErrorKind}
```

```moonbit
test "matching on the error kind" {
  let ctx = @checked.ArithmeticContext::new(53)
  let x : @checked.Dual[Double] = @checked.Dual::new(-1.0, 1.0)
  match x.sqrt_checked(ctx) {
    Ok(_) => fail("expected an error")
    Err(e) =>
      match e.kind {
        @checked.ArithmeticErrorKind::DomainError => ()
        _ => fail("expected a domain error")
      }
  }
}
```

## Versions of `arithmetic`

The checked rules of `Dual[T]` only call `T`'s `div_checked` and
`sqrt_checked`, so the errors depend on the `arithmetic` release that
provides the `Double` instances. This manual and its examples follow
`arithmetic` 0.5, which the repository is developed against in a
workspace. `moon.mod` still pins `arithmetic@0.2.1`, where `Double` behaves
differently:

| Operation on `Double` | `arithmetic` 0.5 | `arithmetic` 0.2.1 |
| --- | --- | --- |
| `div_checked(x, 0.0)`, $x \ne 0$ | `DivisionByZero` | `DivisionByZero` |
| `div_checked(0.0, 0.0)` | `DomainError` | `DivisionByZero` |
| `div_checked(inf, inf)` | `DomainError` | `Ok(NaN)` |
| `sqrt_checked(x)`, $x < 0$ | `DomainError` | `Ok(NaN)` |
| `ArithmeticErrorKind::CertificationFailure` | exists | does not exist |
| `ArithmeticContext::new` | `precision`, `rounding?`, `e_min?`, `e_max?`, `clamp?` | `precision`, `rounding?` |

> [!WARNING]
> With `arithmetic@0.2.1`, `Dual::sqrt_checked` of a negative `Double`
> returns `Ok` with value and tangent NaN instead of an error. Check
> `value().is_nan()` until the pin is raised.

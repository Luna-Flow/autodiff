# elementary API

The `elementary` package is the facade for the analytic traits of
[arithmetic](https://lunaflow.cn/en/arithmetic/) that `Dual[T]` implements.
It re-exports `Dual`, `Sqrt`, `SqrtChecked`, `Exponential`, `Logarithmic`,
`Trigonometric` and `Constants`. Import it when you write generic code
against these traits and want to differentiate it. The derivative rules are
listed on the [dual API](dual.md#elementary-functions).

Source: [`src/elementary/alias.mbt`](../../../src/elementary/alias.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/elementary",
}
```

## Re-exported type

### `Dual`

The dual number type.

```mbti
pub using @dual {type Dual}
```

## Analytic traits

| Trait | Methods | Tangent on `Dual[T]` |
| --- | --- | --- |
| `Sqrt` | `sqrt` | $b/(2\sqrt a)$ |
| `SqrtChecked` | `sqrt_checked` | $b/(2\sqrt a)$, checked |
| `Exponential` | `exp`, `exp2` | $b\,e^a$, $b\,2^a\ln 2$ |
| `Logarithmic` | `ln`, `log2`, `log10` | $b/a$, $b/(a\ln 2)$, $b/(a\ln 10)$ |
| `Trigonometric` | `sin`, `cos`, `tan` | $b\cos a$, $-b\sin a$, $b/\cos^2 a$ |
| `Constants` | `pi`, `tau`, `e` | $0$ |

### `Sqrt`

Unchecked square root.

```mbti
pub using @arithmetic {trait Sqrt}
```

### `SqrtChecked`

Square root returning `Result[Self, ArithmeticError]`; see the
[checked API](checked.md#sqrtchecked).

```mbti
pub using @arithmetic {trait SqrtChecked}
```

### `Exponential`

`exp` and `exp2`. The `Dual[T]` instance needs `T : Exponential +
Logarithmic + IntegralHomomorphism + Mul`, because `exp2` uses $\ln 2$.

```mbti
pub using @arithmetic {trait Exponential}
```

### `Logarithmic`

`ln`, `log2` and `log10`. The `Dual[T]` instance needs `T : Logarithmic +
IntegralHomomorphism + Mul + Div`.

```mbti
pub using @arithmetic {trait Logarithmic}
```

### `Trigonometric`

`sin`, `cos` and `tan`. The `Dual[T]` instance needs `T : Trigonometric +
Mul + Neg + Div`.

```mbti
pub using @arithmetic {trait Trigonometric}
```

### `Constants`

$\pi$, $\tau = 2\pi$ and $e$; on `Dual[T]` they are constants with tangent
zero.

```mbti
pub using @arithmetic {trait Constants}
```

```moonbit
fn[T : @elementary.Trigonometric + @elementary.Exponential + Mul] damped(x : T) -> T {
  @elementary.Exponential::exp(x) * @elementary.Trigonometric::sin(x)
}

test "analytic traits on dual numbers" {
  let y = damped(@elementary.Dual::variable(0.0))
  assert_eq(y.value(), 0.0)
  assert_eq(y.tangent(), 1.0) // e^0 (sin 0 + cos 0)
  let tau : @elementary.Dual[Double] = @elementary.Constants::tau()
  assert_eq(tau.tangent(), 0.0)
}
```

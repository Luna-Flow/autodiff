# core API

The `core` package is the algebraic facade of the repository: it re-exports
`Dual` together with the `luna-generic` structure traits that `Dual[T]`
implements, and nothing from `arithmetic`. Import it when you write generic,
ring-level code and want a dependency set without the arithmetic traits.

Source: [`src/core/alias.mbt`](../../../src/core/alias.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/core" @ad_core,
}
```

The alias `@ad_core` avoids confusion with other packages named `core`;
the examples use it.

## Re-exported type

### `Dual`

The dual number type; see the [dual API](dual.md).

```mbti
pub using @dual {type Dual}
```

## Re-exported structure traits

Each trait is the original from
[luna-generic](https://lunaflow.cn/en/luna-generic/); `Dual[T]` implements
it under the bound shown.

| Trait | Required structure | `Dual[T]` instance when |
| --- | --- | --- |
| `Zero` | `zero()` | `T : Zero` |
| `One` | `one()` | `T : One + Zero` |
| `AddMonoid` | `Add + Zero` | `T : AddMonoid` |
| `AddGroup` | `AddMonoid + Neg + Sub` | `T : AddGroup` |
| `MulMonoid` | `Mul + One` | `T : Semiring` |
| `Semiring` | `AddMonoid + MulMonoid` | `T : Semiring` |
| `Ring` | `Semiring + Neg + Sub` | `T : Ring` |
| `IntegralHomomorphism` | `from_integral` from integral types | `T : IntegralHomomorphism + Zero` |

```mbti
pub using @luna-generic {trait Zero}
pub using @luna-generic {trait One}
pub using @luna-generic {trait AddMonoid}
pub using @luna-generic {trait AddGroup}
pub using @luna-generic {trait MulMonoid}
pub using @luna-generic {trait Semiring}
pub using @luna-generic {trait Ring}
pub using @luna-generic {trait IntegralHomomorphism}
```

### `Zero`

Additive identity.

### `One`

Multiplicative identity.

### `AddMonoid`

Addition with an identity.

### `AddGroup`

Addition with negation and subtraction.

### `MulMonoid`

Multiplication with an identity.

### `Semiring`

Both monoids with distributivity.

### `Ring`

A semiring with additive inverses.

### `IntegralHomomorphism`

The canonical map from the integers, used for integer constants in generic
code.

```moonbit
fn[T : @ad_core.Ring + @ad_core.IntegralHomomorphism] f(x : T) -> T {
  let five : T = @ad_core.IntegralHomomorphism::from_integral(5)
  x * x - five * x
}

test "ring-level generic code" {
  let y = f(@ad_core.Dual::variable(4.0))
  assert_eq(y.value(), -4.0)
  assert_eq(y.tangent(), 3.0) // 2x - 5
}
```

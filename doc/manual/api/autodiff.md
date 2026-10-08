# autodiff API

## Purpose

The root package `Luna-Flow/autodiff` is the one import most programs need.
It re-exports `Dual`, the scalar drivers `diff` and `value_and_diff`, the
algebraic traits from `luna-generic` and the arithmetic traits and error
types from `arithmetic` that appear in the bounds of `Dual[T]`. It defines no
items of its own. The vector and polynomial drivers live in
[`linalg`](linalg.md) and [`poly`](poly.md).

Source: [`src/alias.mbt`](../../../src/alias.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
}
```

All names below are then available as `@autodiff.<name>`, and trait methods
as `@autodiff.<Trait>::<method>`.

## Dual numbers

### `Dual`

The dual number $a + b\varepsilon$; see the [dual API](dual.md) for its
methods and instances.

```mbti
pub using @dual {type Dual}
```

## Scalar drivers

### `value_and_diff`

Returns $(f(x), f'(x))$ from one evaluation of `f` on
`Dual::variable(x)`. Defined in [`forward`](forward.md#value_and_diff).

```mbti
pub fn[T : @luna-generic.One] value_and_diff((@dual.Dual[T]) -> @dual.Dual[T], T) -> (T, T)
```

### `diff`

Returns $f'(x)$. Defined in [`forward`](forward.md#diff).

```mbti
pub fn[T : @luna-generic.One] diff((@dual.Dual[T]) -> @dual.Dual[T], T) -> T
```

```moonbit
test "root drivers" {
  assert_eq(@autodiff.diff(x => x * x, 3.0), 6.0)
  assert_eq(@autodiff.value_and_diff(x => x * x * x, 2.0), (8.0, 12.0))
}
```

## Algebraic traits

These traits come from [luna-generic](https://lunaflow.cn/en/luna-generic/).
They are re-exported so that generic code can name its bounds through one
import. `Dual[T]` implements each of them when `T` does.

| Trait | Meaning | Use in this repository |
| --- | --- | --- |
| `Zero` | additive identity `zero()` | `Dual::constant`, seeding |
| `One` | multiplicative identity `one()` | `Dual::variable`, seeding |
| `AddMonoid` | `Add + Zero` | instance on `Dual[T]` |
| `AddGroup` | `AddMonoid + Neg + Sub` | instance on `Dual[T]` |
| `MulMonoid` | `Mul + One` | instance on `Dual[T]` for `T : Semiring` |
| `Semiring` | `AddMonoid + MulMonoid` | bound of every `poly` function |
| `Ring` | `Semiring + Neg + Sub` | typical bound of generic differentiable code |
| `FromNat` | `from_natural(n)`, the map from the natural numbers | supertrait of `FromInteger` |
| `FromInteger` | `from_integer(n)`, the map from the integers | constants $2$ and $10$ in the elementary rules; integer literals in generic code |

```mbti
pub using @luna-generic {trait Zero}
pub using @luna-generic {trait One}
pub using @luna-generic {trait AddMonoid}
pub using @luna-generic {trait AddGroup}
pub using @luna-generic {trait MulMonoid}
pub using @luna-generic {trait Semiring}
pub using @luna-generic {trait Ring}
pub using @luna-generic {trait FromInteger}
pub using @luna-generic {trait FromNat}
```

### `Zero`

The additive identity; `Dual` implements it as $0 + 0\varepsilon$.

### `One`

The multiplicative identity; `Dual` implements it as $1 + 0\varepsilon$.

### `AddMonoid`

Addition with a zero. `Dual[T]` is an additive monoid when `T` is.

### `AddGroup`

An additive monoid with negation and subtraction.

### `MulMonoid`

Multiplication with a one.

### `Semiring`

Additive and multiplicative monoids with distributivity.

### `Ring`

A semiring with negation and subtraction.

### `FromNat`

The canonical map from the natural numbers, taking a `BigInt`;
`from_natural(n)` on `Dual[T]` is `Dual::constant(from_natural(n))`.

### `FromInteger`

The canonical map from the integers, taking a `BigInt`; `from_integer(n)` on
`Dual[T]` is `Dual::constant(from_integer(n))`. It extends `FromNat`. To
convert an `Int` or another integral value, use `@lg.lift_to` from
`Luna-Flow/luna-generic`, which is not re-exported.

```moonbit
fn[T : @autodiff.Ring + @autodiff.FromInteger] poly3(x : T) -> T {
  let two : T = @autodiff.FromInteger::from_integer(2N)
  x * x * x - two * x
}

test "generic bounds through the root package" {
  assert_eq(poly3(2.0), 4.0)
  assert_eq(@autodiff.diff(poly3, 2.0), 10.0)
}
```

## Arithmetic traits

These traits come from [arithmetic](https://lunaflow.cn/en/arithmetic/).
`Dual[T]` implements each of them under the bounds listed in the
[dual API](dual.md#trait-instances).

| Trait | Methods | Dual rule |
| --- | --- | --- |
| `Sqrt` | `sqrt` | $\sqrt a + \frac{b}{2\sqrt a}\varepsilon$ |
| `Exponential` | `exp`, `exp2` | $b\,e^a$, $b\,2^a\ln 2$ |
| `Logarithmic` | `ln`, `log2`, `log10` | $b/a$, $b/(a\ln 2)$, $b/(a\ln 10)$ |
| `Trigonometric` | `sin`, `cos`, `tan` | $b\cos a$, $-b\sin a$, $b/\cos^2 a$ |
| `Constants` | `pi`, `tau`, `e` | constants, tangent zero |
| `DivChecked` | `div_checked` | quotient rule, both parts checked |
| `SqrtChecked` | `sqrt_checked` | square-root rule, both parts checked |

```mbti
pub using @arithmetic {trait Sqrt}
pub using @arithmetic {trait SqrtChecked}
pub using @arithmetic {trait Exponential}
pub using @arithmetic {trait Logarithmic}
pub using @arithmetic {trait Trigonometric}
pub using @arithmetic {trait Constants}
pub using @arithmetic {trait DivChecked}
```

### `Sqrt`

Unchecked square root.

### `SqrtChecked`

Square root returning `Result[Self, ArithmeticError]`.

### `Exponential`

`exp` and `exp2`.

### `Logarithmic`

`ln`, `log2` and `log10`.

### `Trigonometric`

`sin`, `cos` and `tan`.

### `Constants`

$\pi$, $\tau = 2\pi$ and $e$.

### `DivChecked`

Division returning `Result[Self, ArithmeticError]`.

```moonbit
test "arithmetic traits on dual numbers" {
  let x = @autodiff.Dual::variable(0.0)
  assert_eq(@autodiff.Trigonometric::sin(x).tangent(), 1.0)
  let pi : @autodiff.Dual[Double] = @autodiff.Constants::pi()
  assert_eq(pi.tangent(), 0.0)
}
```

## Arithmetic error types

The checked operations take an `ArithmeticContext` and return an
`ArithmeticError`. Both are defined in `arithmetic`; the
[checked API](checked.md) describes how `Dual[T]` uses them.

```mbti
pub using @arithmetic {type ArithmeticContext}
pub using @arithmetic {type ArithmeticError}
pub using @arithmetic {type ArithmeticErrorKind}
pub using @arithmetic {type RoundingMode}
```

### `ArithmeticContext`

The explicit numeric context: precision, `RoundingMode` and optional
exponent range, built with `ArithmeticContext::new(precision)`. The `Double`
and `Float` instances of the checked traits ignore it.

### `ArithmeticError`

A structured error with a `kind` and a `message`; test it with
`is_division_by_zero()`, `is_domain_error()` and the other predicates.

### `ArithmeticErrorKind`

The enumeration behind `ArithmeticError::kind`: `DivisionByZero`,
`DomainError`, `ParseError`, `FormatError`, `UnsupportedOperation`,
`UnorderedComparison` and `CertificationFailure`.

### `RoundingMode`

The rounding direction of a context: `ToNearestEven`, `TowardZero`,
`TowardPositive`, `TowardNegative` and `AwayFromZero`.

```moonbit
test "checked division through the root package" {
  let ctx = @autodiff.ArithmeticContext::new(53, rounding=@autodiff.RoundingMode::ToNearestEven)
  let r = @autodiff.DivChecked::div_checked(
    @autodiff.Dual::variable(1.0),
    @autodiff.Dual::constant(0.0),
    ctx,
  )
  assert_true(r is Err(e) && e.is_division_by_zero())
}
```

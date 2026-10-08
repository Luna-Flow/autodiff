# dual API

The `dual` package owns `Dual[T]`, the dual number $a + b\varepsilon$ with
$\varepsilon^2 = 0$, together with its arithmetic, its Luna Flow trait
instances and the derivative rules of the elementary functions. Every other
package of this repository re-exports or consumes this type. The
mathematics behind the rules is in the [dual design](../design/dual.md).

Source: [`src/dual/dual.mbt`](../../../src/dual/dual.mbt) and
[`src/dual/extends.mbt`](../../../src/dual/extends.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/dual",
}
```

Most programs import the root package `Luna-Flow/autodiff` instead, which
re-exports `Dual` as `@autodiff.Dual` (see the [autodiff API](autodiff.md)).
The examples on this page use the root alias.

## The type

### `Dual`

`Dual[T]` stores a primal value and a first-order tangent.

```mbti
pub struct Dual[T] {
  value : T
  tangent : T
} derive(Eq, @debug.Debug)
```

The pair `(value, tangent)` represents $a + b\varepsilon$ with $a$ =
`value` and $b$ = `tangent`. When a computation starts from
`Dual::variable(x)`, the tangent of every intermediate result is the
derivative of that intermediate with respect to `x`. The fields are
read-only outside the package; build values with the constructors below.

`derive(Eq)` compares both components, so two dual numbers with the same
value and different tangents are not equal. `derive(Debug)` prints the
record form `{ value: …, tangent: … }`, which `debug_inspect` and
`assert_eq` use.

`Dual[T]` deliberately has no `Compare`, `Field`, `MulGroup`, `Inverse` or
`Show` instance; see [Design decisions](../design/dual.md#design-decisions).

## Construction and access

### `Dual::new`

Builds $a + b\varepsilon$ from an explicit value and tangent.

```mbti
pub fn[T] Dual::new(T, T) -> Dual[T]
```

Use it to seed a direction other than $1$, for example a directional
derivative $\nabla f(x) \cdot v$ where each input coordinate gets the tangent
$v_i$.

### `Dual::constant`

Embeds a value with tangent zero: $c \mapsto c + 0\varepsilon$.

```mbti
pub fn[T : @luna-generic.Zero] Dual::constant(T) -> Dual[T]
```

Constants do not depend on the differentiation variable, so their derivative
is $0$. Use it for every literal or captured value that enters a
differentiated computation.

### `Dual::variable`

Embeds the differentiation variable with tangent one:
$x \mapsto x + 1\varepsilon$.

```mbti
pub fn[T : @luna-generic.One] Dual::variable(T) -> Dual[T]
```

### `Dual::value`

Returns the primal component $a$.

```mbti
pub fn[T] Dual::value(Dual[T]) -> T
```

### `Dual::tangent`

Returns the tangent component $b$.

```mbti
pub fn[T] Dual::tangent(Dual[T]) -> T
```

```moonbit
test "construct and read dual numbers" {
  let x = @autodiff.Dual::new(2.0, 3.0)
  assert_eq(x.value(), 2.0)
  assert_eq(x.tangent(), 3.0)
  let c : @autodiff.Dual[Double] = @autodiff.Dual::constant(5.0)
  assert_eq(c.tangent(), 0.0)
  let v : @autodiff.Dual[Double] = @autodiff.Dual::variable(5.0)
  assert_eq(v.tangent(), 1.0)
}
```

### `Dual::zero`

Returns the additive identity $0 + 0\varepsilon$.

```mbti
pub fn[T : @luna-generic.Zero] Dual::zero() -> Dual[T]
```

This is the promoted method of the `Zero` instance.

### `Dual::one`

Returns the multiplicative identity $1 + 0\varepsilon$.

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] Dual::one() -> Dual[T]
```

`one` is a constant, so its tangent is zero; it is not
`Dual::variable(1)`. This is the promoted method of the `One` instance.

## Arithmetic

The four operators implement the sum, difference, product and quotient
rules. They are available both as operators and as promoted methods.

| Item | Operator | Rule | Bound on `T` |
| --- | --- | --- | --- |
| `Dual::add` | `x + y` | $(a+b\varepsilon)+(c+d\varepsilon) = (a+c) + (b+d)\varepsilon$ | `Add` |
| `Dual::sub` | `x - y` | $(a-c) + (b-d)\varepsilon$ | `Sub` |
| `Dual::neg` | `-x` | $-a - b\varepsilon$ | `Neg` |
| `Dual::mul` | `x * y` | $ac + (ad + cb)\varepsilon$ | `Add + Mul` |
| `Dual::div` | `x / y` | $\dfrac{a}{c} + \dfrac{bc - ad}{c^2}\varepsilon$ | `Div + Sub + Mul` |

### `Dual::add`

Adds componentwise.

```mbti
pub fn[T : Add] Dual::add(Dual[T], Dual[T]) -> Dual[T]
pub impl[T : Add] Add for Dual[T]
```

### `Dual::sub`

Subtracts componentwise.

```mbti
pub fn[T : Sub] Dual::sub(Dual[T], Dual[T]) -> Dual[T]
pub impl[T : Sub] Sub for Dual[T]
```

### `Dual::neg`

Negates both components.

```mbti
pub fn[T : Neg] Dual::neg(Dual[T]) -> Dual[T]
pub impl[T : Neg] Neg for Dual[T]
```

### `Dual::mul`

Multiplies with the product rule.

```mbti
pub fn[T : Add + Mul] Dual::mul(Dual[T], Dual[T]) -> Dual[T]
pub impl[T : Add + Mul] Mul for Dual[T]
```

The tangent is computed as `self.value * other.tangent + other.value *
self.tangent`, that is $ad + cb$. This equals the product rule $ad + bc$
because the multiplication of every numeric `T` is commutative.

### `Dual::div`

Divides with the quotient rule, without any domain check.

```mbti
pub fn[T : Div + Sub + Mul] Dual::div(Dual[T], Dual[T]) -> Dual[T]
pub impl[T : Div + Sub + Mul] Div for Dual[T]
```

The tangent is `(self.tangent * other.value - self.value * other.tangent) /
(other.value * other.value)`. A zero divisor value gives whatever `T`'s
division gives (for `Double`, an infinity or NaN). Use `Dual::div_checked`
to get an error instead.

```moonbit
test "dual arithmetic" {
  let x = @autodiff.Dual::new(2.0, 3.0)
  let y = @autodiff.Dual::new(5.0, 7.0)
  assert_eq(x + y, @autodiff.Dual::new(7.0, 10.0))
  assert_eq(y - x, @autodiff.Dual::new(3.0, 4.0))
  assert_eq(-x, @autodiff.Dual::new(-2.0, -3.0))
  assert_eq(x * y, @autodiff.Dual::new(10.0, 29.0)) // 2*7 + 5*3
  assert_eq(y / x, @autodiff.Dual::new(2.5, -0.25)) // (7*2 - 5*3) / 4
}
```

### `Dual::equal`

Tests both components for equality.

```mbti
pub fn[T : Eq] Dual::equal(Dual[T], Dual[T]) -> Bool
```

This is the promoted method of the derived `Eq` instance; prefer `==`.

## Checked operations

The checked forms return `Result[Dual[T], ArithmeticError]` from
[`Luna-Flow/arithmetic`](https://lunaflow.cn/en/arithmetic/) instead of
producing infinities or NaN. The [checked API](checked.md) re-exports the
types they use.

### `Dual::div_checked`

Divides with the quotient rule and reports invalid divisions as errors.

```mbti
pub fn[T : @arithmetic.DivChecked + Sub + Mul] Dual::div_checked(Dual[T], Dual[T], @arithmetic.ArithmeticContext) -> Result[Dual[T], @arithmetic.ArithmeticError]
pub impl[T : @arithmetic.DivChecked + Sub + Mul] @arithmetic.DivChecked for Dual[T]
```

The value $a / c$ is computed first with `T`'s `div_checked`; the tangent
$(bc - ad) / c^2$ is then computed with a second `div_checked` call. The
first error is returned unchanged. For `Double` the errors are:

| Condition | Error |
| --- | --- |
| $c = 0$ and $a \ne 0$ | `is_division_by_zero()` |
| $a = 0$ and $c = 0$ | `is_domain_error()` (zero divided by zero) |
| both $a$ and $c$ infinite | `is_domain_error()` |
| $c \ne 0$ but $c \cdot c$ underflows to $0$ | the tangent division fails; see the pitfall below |

The context argument is passed through to `T`; the `Double` and `Float`
instances of `arithmetic` ignore it.

```moonbit
test "checked dual division" {
  let ctx = @autodiff.ArithmeticContext::new(53)
  let x = @autodiff.Dual::new(6.0, 2.0)
  let y = @autodiff.Dual::new(3.0, 1.0)
  match x.div_checked(y, ctx) {
    Ok(q) => assert_eq(q, @autodiff.Dual::new(2.0, 0.0))
    Err(_) => fail("unexpected error")
  }
  match x.div_checked(@autodiff.Dual::new(0.0, 1.0), ctx) {
    Ok(_) => fail("expected an error")
    Err(e) => assert_true(e.is_division_by_zero())
  }
}
```

> [!WARNING]
> The tangent divides by $c^2$, which leaves the range of `Double` sooner
> than $c$ itself: for $|c| < 2^{-537} \approx 1.5\times10^{-162}$ the square
> underflows to zero and `div_checked` reports a division by zero even when
> $a / c$ is finite. Rescale such inputs before dividing.

### `Dual::sqrt_checked`

Takes the square root with the rule $\sqrt{a + b\varepsilon} = \sqrt a +
\dfrac{b}{2\sqrt a}\varepsilon$ and reports domain errors.

```mbti
pub fn[T : @arithmetic.SqrtChecked + @arithmetic.DivChecked + @luna-generic.IntegralHomomorphism + Mul] Dual::sqrt_checked(Dual[T], @arithmetic.ArithmeticContext) -> Result[Dual[T], @arithmetic.ArithmeticError]
pub impl[T : @arithmetic.SqrtChecked + @arithmetic.DivChecked + @luna-generic.IntegralHomomorphism + Mul] @arithmetic.SqrtChecked for Dual[T]
```

The value is `T`'s `sqrt_checked(a)`; the tangent is `div_checked(b, 2 *
root)`, where `2` comes from `IntegralHomomorphism::from_integral(2)`. For
`Double`:

| Condition | Error |
| --- | --- |
| $a < 0$ | `is_domain_error()` from the square root |
| $a = 0$, $b \ne 0$ | `is_division_by_zero()` from the tangent |
| $a = 0$, $b = 0$ | `is_domain_error()` (zero divided by zero) from the tangent |

So `sqrt_checked` fails at $a = 0$ even for a constant input: $\sqrt{\cdot}$
has no derivative at $0$, and the checked form does not special-case a zero
tangent.

```moonbit
test "checked dual square root" {
  let ctx = @autodiff.ArithmeticContext::new(53)
  match @autodiff.Dual::new(9.0, 6.0).sqrt_checked(ctx) {
    Ok(r) => assert_eq(r, @autodiff.Dual::new(3.0, 1.0))
    Err(_) => fail("unexpected error")
  }
  match @autodiff.Dual::new(-1.0, 1.0).sqrt_checked(ctx) {
    Ok(_) => fail("expected an error")
    Err(e) => assert_true(e.is_domain_error())
  }
}
```

## Elementary functions

Each elementary function is an inherent method and also the method of the
matching `arithmetic` trait instance, so generic code written against
`Sqrt`, `Exponential`, `Logarithmic` or `Trigonometric` differentiates
through `Dual[T]` unchanged. All of them apply the rule
$f(a + b\varepsilon) = f(a) + f'(a)\,b\,\varepsilon$ with the derivative
below. None of them checks its domain: outside it the result is whatever
`T` returns (for `Double`, NaN or an infinity).

| Item | Value | Tangent as computed | Derivative |
| --- | --- | --- | --- |
| `Dual::sqrt` | $\sqrt a$ | `b / (2 * sqrt(a))` | $\frac{1}{2\sqrt a}$ |
| `Dual::exp` | $e^a$ | `b * exp(a)` | $e^a$ |
| `Dual::exp2` | $2^a$ | `b * exp2(a) * ln(2)` | $2^a \ln 2$ |
| `Dual::ln` | $\ln a$ | `b / a` | $\frac{1}{a}$ |
| `Dual::log2` | $\log_2 a$ | `b / (a * ln(2))` | $\frac{1}{a\ln 2}$ |
| `Dual::log10` | $\log_{10} a$ | `b / (a * ln(10))` | $\frac{1}{a\ln 10}$ |
| `Dual::sin` | $\sin a$ | `b * cos(a)` | $\cos a$ |
| `Dual::cos` | $\cos a$ | `-(b * sin(a))` | $-\sin a$ |
| `Dual::tan` | $\tan a$ | `b / (cos(a) * cos(a))` | $\sec^2 a$ |

The constants $2$ and $10$ come from `IntegralHomomorphism::from_integral`.

### `Dual::sqrt`

Square root with the tangent $b / (2\sqrt a)$.

```mbti
pub fn[T : @arithmetic.Sqrt + @luna-generic.IntegralHomomorphism + Mul + Div] Dual::sqrt(Dual[T]) -> Dual[T]
pub impl[T : @arithmetic.Sqrt + @luna-generic.IntegralHomomorphism + Mul + Div] @arithmetic.Sqrt for Dual[T]
```

### `Dual::exp`

Exponential with the tangent $b\,e^a$; the value is computed once and reused.

```mbti
pub fn[T : @arithmetic.Exponential + Mul] Dual::exp(Dual[T]) -> Dual[T]
```

### `Dual::exp2`

Base-2 exponential with the tangent $b \cdot 2^a \ln 2$.

```mbti
pub fn[T : @arithmetic.Exponential + @arithmetic.Logarithmic + @luna-generic.IntegralHomomorphism + Mul] Dual::exp2(Dual[T]) -> Dual[T]
pub impl[T : @arithmetic.Exponential + @arithmetic.Logarithmic + @luna-generic.IntegralHomomorphism + Mul] @arithmetic.Exponential for Dual[T]
```

The `Exponential` instance provides both `exp` and `exp2`, so it needs the
bounds of `exp2`.

### `Dual::ln`

Natural logarithm with the tangent $b / a$.

```mbti
pub fn[T : @arithmetic.Logarithmic + Div] Dual::ln(Dual[T]) -> Dual[T]
```

### `Dual::log2`

Base-2 logarithm with the tangent $b / (a \ln 2)$.

```mbti
pub fn[T : @arithmetic.Logarithmic + @luna-generic.IntegralHomomorphism + Mul + Div] Dual::log2(Dual[T]) -> Dual[T]
```

### `Dual::log10`

Base-10 logarithm with the tangent $b / (a \ln 10)$.

```mbti
pub fn[T : @arithmetic.Logarithmic + @luna-generic.IntegralHomomorphism + Mul + Div] Dual::log10(Dual[T]) -> Dual[T]
pub impl[T : @arithmetic.Logarithmic + @luna-generic.IntegralHomomorphism + Mul + Div] @arithmetic.Logarithmic for Dual[T]
```

The `Logarithmic` instance provides `ln`, `log2` and `log10`.

### `Dual::sin`

Sine with the tangent $b \cos a$.

```mbti
pub fn[T : @arithmetic.Trigonometric + Mul] Dual::sin(Dual[T]) -> Dual[T]
```

### `Dual::cos`

Cosine with the tangent $-b \sin a$.

```mbti
pub fn[T : @arithmetic.Trigonometric + Mul + Neg] Dual::cos(Dual[T]) -> Dual[T]
```

### `Dual::tan`

Tangent with the derivative $\sec^2 a$, computed as $b / (\cos a \cdot \cos a)$.

```mbti
pub fn[T : @arithmetic.Trigonometric + Mul + Div] Dual::tan(Dual[T]) -> Dual[T]
pub impl[T : @arithmetic.Trigonometric + Mul + Neg + Div] @arithmetic.Trigonometric for Dual[T]
```

The `Trigonometric` instance provides `sin`, `cos` and `tan`.

```moonbit
test "elementary derivative rules" {
  let x = @autodiff.Dual::variable(0.5)
  assert_eq(x.sin().tangent(), @math.cos(0.5))
  assert_eq(x.exp().tangent(), @math.exp(0.5))
  assert_eq(x.ln().tangent(), 2.0)
  assert_eq(@autodiff.Dual::variable(4.0).sqrt().tangent(), 0.25)
}
```

## Trait instances

`Dual[T]` implements the Luna Flow structure traits that the algebra
$T[\varepsilon]/(\varepsilon^2)$ satisfies, each under the matching bound on
`T`. The laws are derived in the [dual design](../design/dual.md).

| Instance | Bound on `T` | Meaning |
| --- | --- | --- |
| `Zero` | `Zero` | `zero()` is $0 + 0\varepsilon$ |
| `One` | `One + Zero` | `one()` is $1 + 0\varepsilon$ |
| `AddMonoid` | `AddMonoid` | componentwise addition |
| `AddGroup` | `AddGroup` | componentwise negation |
| `MulMonoid` | `Semiring` | product rule multiplication |
| `Semiring` | `Semiring` | $T[\varepsilon]$ is a semiring when `T` is |
| `Ring` | `Ring` | $T[\varepsilon]$ is a ring when `T` is |
| `NatHomomorphism` | `NatHomomorphism + Zero` | `from_nat(n)` is `Dual::constant(from_nat(n))` |
| `IntegralHomomorphism` | `IntegralHomomorphism + Zero` | `from_integral(n)` is `Dual::constant(from_integral(n))` |
| `@arithmetic.Constants` | `Constants + Zero` | `pi()`, `tau()`, `e()` are constants |
| `@arithmetic.DivChecked` | `DivChecked + Sub + Mul` | see `Dual::div_checked` |
| `@arithmetic.SqrtChecked` | see `Dual::sqrt_checked` | see `Dual::sqrt_checked` |
| `@arithmetic.Sqrt`, `Exponential`, `Logarithmic`, `Trigonometric` | see each method | see [Elementary functions](#elementary-functions) |

The integer and natural-number embeddings and the constants produce tangent
zero, because they do not depend on the differentiation variable.

```moonbit
fn[T : @autodiff.Ring + @autodiff.IntegralHomomorphism] three_x_squared(x : T) -> T {
  let three : T = @autodiff.IntegralHomomorphism::from_integral(3)
  three * x * x
}

test "generic code differentiates through the trait instances" {
  let y = three_x_squared(@autodiff.Dual::variable(2.0))
  assert_eq(y, @autodiff.Dual::new(12.0, 12.0))
}
```

## Deprecated

`Dual` keeps a few method forms that MoonBit used to create implicitly from
trait instances. They are hidden from the interface file and warn when used
outside this package.

| Deprecated method | Replacement |
| --- | --- |
| `x.not_equal(y)` | `x != y` |
| `x.to_repr()` | `Repr(x)` or `@debug.Debug::to_repr(x)` |
| `Dual::from_nat(n)` | `NatHomomorphism::from_nat(n)` from `Luna-Flow/luna-generic` |
| `Dual::from_integral(n)` | `@autodiff.IntegralHomomorphism::from_integral(n)` |
| `Dual::pi()`, `Dual::e()`, `Dual::tau()` | `@autodiff.Constants::pi()`, `e()`, `tau()` |

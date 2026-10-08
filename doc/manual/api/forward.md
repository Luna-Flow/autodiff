# forward API

The `forward` package turns a function on dual numbers into its derivative
at a point. It contains the two scalar forward-mode drivers, `diff` and
`value_and_diff`, and re-exports `Dual`. The root package re-exports both
functions, so most programs call them as `@autodiff.diff` and
`@autodiff.value_and_diff`.

Source: [`src/forward/forward.mbt`](../../../src/forward/forward.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/forward",
}
```

## Drivers

### `value_and_diff`

Evaluates `f` at `x` and returns the value together with the first
derivative.

```mbti
pub fn[T : @luna-generic.One] value_and_diff((@dual.Dual[T]) -> @dual.Dual[T], T) -> (T, T)
```

It calls `f(Dual::variable(x))` once and returns `(y.value(), y.tangent())`.
By the [dual design](../design/dual.md#derivatives-of-whole-programs), the
pair is $(f(x), f'(x))$ when `f` is built from the operations of `Dual[T]`
and treats every other input as a constant. The cost is one evaluation of
`f` on dual numbers. `f` must not inspect the tangent of its argument;
whatever `f` does is differentiated, including branches on `value()`.

### `diff`

Returns only the derivative $f'(x)$.

```mbti
pub fn[T : @luna-generic.One] diff((@dual.Dual[T]) -> @dual.Dual[T], T) -> T
```

`diff(f, x)` is the second component of `value_and_diff(f, x)`.

```moonbit
test "scalar drivers" {
  let (value, derivative) = @forward.value_and_diff(x => x * x * x, 2.0)
  assert_eq(value, 8.0)
  assert_eq(derivative, 12.0)
  assert_eq(@forward.diff(x => x.sin(), 0.0), 1.0)
}
```

## Re-exported type

### `Dual`

`pub using @dual {type Dual}` makes `@forward.Dual` the same type as
`@dual.Dual`; see the [dual API](dual.md).

```mbti
pub using @dual {type Dual}
```

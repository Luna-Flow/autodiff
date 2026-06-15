///|
using @test {assert_eq}

///|
using @arithmetic {
  trait DivChecked,
  trait Exponential,
  trait SqrtChecked,
  trait Trigonometric,
  type ArithmeticContext,
}

///|
let eps : Double = 0.00000000001

///|
let ctx : ArithmeticContext = ArithmeticContext::new(32)

///|
fn approx_eq(a : Double, b : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d <= eps
  } else {
    d <= eps
  }
}

///|
test "constructors expose value and tangent" {
  let x = @autodiff.Dual::new(2, 3)
  assert_eq(x.value(), 2)
  assert_eq(x.tangent(), 3)
  let c : @autodiff.Dual[Int] = @autodiff.Dual::constant(4)
  assert_eq(c.value(), 4)
  assert_eq(c.tangent(), 0)
  let v : @autodiff.Dual[Int] = @autodiff.Dual::variable(5)
  assert_eq(v.value(), 5)
  assert_eq(v.tangent(), 1)
}

///|
test "dual arithmetic follows product rule algebra" {
  let x = @autodiff.Dual::new(2, 3)
  let y = @autodiff.Dual::new(5, 7)
  assert_eq((x + y).value(), 7)
  assert_eq((x + y).tangent(), 10)
  assert_eq((y - x).value(), 3)
  assert_eq((y - x).tangent(), 4)
  assert_eq((-x).value(), -2)
  assert_eq((-x).tangent(), -3)
  assert_eq((x * y).value(), 10)
  assert_eq((x * y).tangent(), 29)
}

///|
test "zero and one create constant dual values" {
  let z : @autodiff.Dual[Int] = @autodiff.Dual::zero()
  let o : @autodiff.Dual[Int] = @autodiff.Dual::one()
  assert_eq(z.value(), 0)
  assert_eq(z.tangent(), 0)
  assert_eq(o.value(), 1)
  assert_eq(o.tangent(), 0)
}

///|
test "forward diff handles constants and identity" {
  let identity = @autodiff.diff(fn(x : @autodiff.Dual[Double]) { x }, 2.0)
  let constant = @autodiff.diff(
    fn(_ : @autodiff.Dual[Double]) { @autodiff.Dual::constant(7.0) },
    2.0,
  )
  assert_eq(approx_eq(identity, 1.0), true)
  assert_eq(approx_eq(constant, 0.0), true)
}

///|
test "forward diff handles square and cube" {
  let square = @autodiff.diff(fn(x : @autodiff.Dual[Double]) { x * x }, 3.0)
  let cube = @autodiff.diff(fn(x : @autodiff.Dual[Double]) { x * x * x }, 2.0)
  assert_eq(approx_eq(square, 6.0), true)
  assert_eq(approx_eq(cube, 12.0), true)
}

///|
test "forward diff handles sin and exp" {
  let x = 0.5
  let sin_derivative = @autodiff.diff(
    fn(v : @autodiff.Dual[Double]) { v.sin() },
    x,
  )
  let exp_derivative = @autodiff.diff(
    fn(v : @autodiff.Dual[Double]) { v.exp() },
    x,
  )
  assert_eq(approx_eq(sin_derivative, Trigonometric::cos(x)), true)
  assert_eq(approx_eq(exp_derivative, Exponential::exp(x)), true)
}

///|
test "checked division lifts quotient rule and zero division errors" {
  let numerator = @autodiff.Dual::new(6.0, 2.0)
  let denominator = @autodiff.Dual::new(3.0, 1.0)
  match DivChecked::div_checked(numerator, denominator, ctx) {
    Ok(value) => {
      assert_eq(approx_eq(value.value(), 2.0), true)
      assert_eq(approx_eq(value.tangent(), 0.0), true)
    }
    Err(_) => fail("expected checked dual division to succeed")
  }
  match DivChecked::div_checked(numerator, @autodiff.Dual::new(0.0, 1.0), ctx) {
    Ok(_) => fail("expected checked dual division by zero to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
}

///|
test "checked sqrt lifts the square-root derivative" {
  let x = @autodiff.Dual::new(9.0, 6.0)
  match SqrtChecked::sqrt_checked(x, ctx) {
    Ok(value) => {
      assert_eq(approx_eq(value.value(), 3.0), true)
      assert_eq(approx_eq(value.tangent(), 1.0), true)
    }
    Err(_) => fail("expected checked dual sqrt to succeed")
  }
}

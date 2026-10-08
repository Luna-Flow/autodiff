///|
using @lg {
  trait AddGroup,
  trait AddMonoid,
  trait FromInteger,
  trait FromNat,
  trait MulMonoid,
  trait One,
  trait Ring,
  trait Semiring,
  trait Zero,
  lift_to,
}

///|
using @arithmetic {
  trait Constants,
  trait DivChecked,
  trait Exponential,
  trait Logarithmic,
  trait Sqrt,
  trait SqrtChecked,
  trait Trigonometric,
  type ArithmeticContext,
  type ArithmeticError,
}

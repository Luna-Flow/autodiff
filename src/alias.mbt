///|
pub using @dual {type Dual}

///|
pub using @forward {value_and_diff, diff}

///|
pub using @lg {
  trait AddGroup,
  trait AddMonoid,
  trait IntegralHomomorphism,
  trait MulMonoid,
  trait One,
  trait Ring,
  trait Semiring,
  trait Zero,
}

///|
pub using @arithmetic {
  trait Constants,
  trait DivChecked,
  trait Exponential,
  trait Logarithmic,
  trait Sqrt,
  trait SqrtChecked,
  trait Trigonometric,
  type ArithmeticContext,
  type ArithmeticError,
  type ArithmeticErrorKind,
  type RoundingMode,
}

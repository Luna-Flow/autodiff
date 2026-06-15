///|
pub struct Dual[T] {
  value : T
  tangent : T
} derive(Eq, Debug)

///|
pub fn[T] Dual::new(value : T, tangent : T) -> Dual[T] {
  { value, tangent }
}

///|
pub fn[T : Zero] Dual::constant(value : T) -> Dual[T] {
  { value, tangent: T::zero() }
}

///|
pub fn[T : One] Dual::variable(value : T) -> Dual[T] {
  { value, tangent: T::one() }
}

///|
pub fn[T] Dual::value(self : Dual[T]) -> T {
  self.value
}

///|
pub fn[T] Dual::tangent(self : Dual[T]) -> T {
  self.tangent
}

///|
pub impl[T : Zero] Zero for Dual[T] with fn zero() -> Dual[T] {
  Dual::constant(T::zero())
}

///|
pub impl[T : One + Zero] One for Dual[T] with fn one() -> Dual[T] {
  Dual::constant(T::one())
}

///|
pub impl[T : Add] Add for Dual[T] with fn add(self, other) {
  Dual::new(self.value + other.value, self.tangent + other.tangent)
}

///|
pub impl[T : Sub] Sub for Dual[T] with fn sub(self, other) {
  Dual::new(self.value - other.value, self.tangent - other.tangent)
}

///|
pub impl[T : Neg] Neg for Dual[T] with fn neg(self) {
  Dual::new(-self.value, -self.tangent)
}

///|
pub impl[T : Add + Mul] Mul for Dual[T] with fn mul(self, other) {
  Dual::new(
    self.value * other.value,
    self.value * other.tangent + other.value * self.tangent,
  )
}

///|
pub impl[T : Div + Sub + Mul] Div for Dual[T] with fn div(self, other) {
  let denominator = other.value * other.value
  Dual::new(
    self.value / other.value,
    (self.tangent * other.value - self.value * other.tangent) / denominator,
  )
}

///|
pub impl[T : AddMonoid] AddMonoid for Dual[T]

///|
pub impl[T : Semiring] MulMonoid for Dual[T]

///|
pub impl[T : AddGroup] AddGroup for Dual[T]

///|
pub impl[T : Semiring] Semiring for Dual[T]

///|
pub impl[T : Ring] Ring for Dual[T]

///|
pub impl[T : NatHomomorphism + Zero] NatHomomorphism for Dual[T] with fn[
  S : Nat,
] from_nat(value : S) -> Dual[T] {
  Dual::constant(T::from_nat(value))
}

///|
pub impl[T : IntegralHomomorphism + Zero] IntegralHomomorphism for Dual[T] with fn[
  S : Integral,
] from_integral(value : S) -> Dual[T] {
  Dual::constant(T::from_integral(value))
}

///|
pub impl[T : DivChecked + Sub + Mul] DivChecked for Dual[T] with fn div_checked(
  self,
  other,
  ctx,
) -> Result[Dual[T], ArithmeticError] {
  match DivChecked::div_checked(self.value, other.value, ctx) {
    Err(err) => Err(err)
    Ok(value) =>
      match
        DivChecked::div_checked(
          self.tangent * other.value - self.value * other.tangent,
          other.value * other.value,
          ctx,
        ) {
        Err(err) => Err(err)
        Ok(tangent) => Ok(Dual::new(value, tangent))
      }
  }
}

///|
pub fn[T : SqrtChecked + DivChecked + IntegralHomomorphism + Mul] Dual::sqrt_checked(
  self : Dual[T],
  ctx : ArithmeticContext,
) -> Result[Dual[T], ArithmeticError] {
  match SqrtChecked::sqrt_checked(self.value, ctx) {
    Err(err) => Err(err)
    Ok(root) => {
      let two : T = T::from_integral(2)
      match DivChecked::div_checked(self.tangent, two * root, ctx) {
        Err(err) => Err(err)
        Ok(tangent) => Ok(Dual::new(root, tangent))
      }
    }
  }
}

///|
pub fn[T : Sqrt + IntegralHomomorphism + Mul + Div] Dual::sqrt(
  self : Dual[T],
) -> Dual[T] {
  let root = Sqrt::sqrt(self.value)
  let two : T = T::from_integral(2)
  Dual::new(root, self.tangent / (two * root))
}

///|
pub fn[T : Exponential + Mul] Dual::exp(self : Dual[T]) -> Dual[T] {
  let value = Exponential::exp(self.value)
  Dual::new(value, self.tangent * value)
}

///|
pub fn[T : Exponential + Logarithmic + IntegralHomomorphism + Mul] Dual::exp2(
  self : Dual[T],
) -> Dual[T] {
  let value = Exponential::exp2(self.value)
  let two : T = T::from_integral(2)
  Dual::new(value, self.tangent * value * Logarithmic::ln(two))
}

///|
pub fn[T : Logarithmic + Div] Dual::ln(self : Dual[T]) -> Dual[T] {
  Dual::new(Logarithmic::ln(self.value), self.tangent / self.value)
}

///|
pub fn[T : Logarithmic + IntegralHomomorphism + Mul + Div] Dual::log2(
  self : Dual[T],
) -> Dual[T] {
  let two : T = T::from_integral(2)
  Dual::new(
    Logarithmic::log2(self.value),
    self.tangent / (self.value * Logarithmic::ln(two)),
  )
}

///|
pub fn[T : Logarithmic + IntegralHomomorphism + Mul + Div] Dual::log10(
  self : Dual[T],
) -> Dual[T] {
  let ten : T = T::from_integral(10)
  Dual::new(
    Logarithmic::log10(self.value),
    self.tangent / (self.value * Logarithmic::ln(ten)),
  )
}

///|
pub fn[T : Trigonometric + Mul] Dual::sin(self : Dual[T]) -> Dual[T] {
  Dual::new(
    Trigonometric::sin(self.value),
    self.tangent * Trigonometric::cos(self.value),
  )
}

///|
pub fn[T : Trigonometric + Mul + Neg] Dual::cos(self : Dual[T]) -> Dual[T] {
  Dual::new(
    Trigonometric::cos(self.value),
    -(self.tangent * Trigonometric::sin(self.value)),
  )
}

///|
pub fn[T : Trigonometric + Mul + Div] Dual::tan(self : Dual[T]) -> Dual[T] {
  let c = Trigonometric::cos(self.value)
  Dual::new(Trigonometric::tan(self.value), self.tangent / (c * c))
}

///|
pub impl[T : Sqrt + IntegralHomomorphism + Mul + Div] Sqrt for Dual[T] with fn sqrt(
  self,
) {
  self.sqrt()
}

///|
pub impl[T : SqrtChecked + DivChecked + IntegralHomomorphism + Mul] SqrtChecked for Dual[
  T,
] with fn sqrt_checked(self, ctx) {
  self.sqrt_checked(ctx)
}

///|
pub impl[T : Exponential + Logarithmic + IntegralHomomorphism + Mul] Exponential for Dual[
  T,
] with fn exp(self) {
  self.exp()
}

///|
pub impl[T : Exponential + Logarithmic + IntegralHomomorphism + Mul] Exponential for Dual[
  T,
] with fn exp2(self) {
  self.exp2()
}

///|
pub impl[T : Logarithmic + IntegralHomomorphism + Mul + Div] Logarithmic for Dual[
  T,
] with fn ln(self) {
  self.ln()
}

///|
pub impl[T : Logarithmic + IntegralHomomorphism + Mul + Div] Logarithmic for Dual[
  T,
] with fn log2(self) {
  self.log2()
}

///|
pub impl[T : Logarithmic + IntegralHomomorphism + Mul + Div] Logarithmic for Dual[
  T,
] with fn log10(self) {
  self.log10()
}

///|
pub impl[T : Trigonometric + Mul + Neg + Div] Trigonometric for Dual[T] with fn sin(
  self,
) {
  self.sin()
}

///|
pub impl[T : Trigonometric + Mul + Neg + Div] Trigonometric for Dual[T] with fn cos(
  self,
) {
  self.cos()
}

///|
pub impl[T : Trigonometric + Mul + Neg + Div] Trigonometric for Dual[T] with fn tan(
  self,
) {
  self.tan()
}

///|
pub impl[T : Constants + Zero] Constants for Dual[T] with fn pi() {
  Dual::constant(Constants::pi())
}

///|
pub impl[T : Constants + Zero] Constants for Dual[T] with fn tau() {
  Dual::constant(Constants::tau())
}

///|
pub impl[T : Constants + Zero] Constants for Dual[T] with fn e() {
  Dual::constant(Constants::e())
}

// Compatibility shims for the `NatHomomorphism` / `IntegralHomomorphism`
// traits, deprecated in luna-generic 0.4.0. luna-poly 0.2.0 still bounds
// `DensePolynomial::derivative` by `NatHomomorphism`, so `Dual[T]` keeps these
// instances until luna-poly moves to `FromNat` and is published. New code
// should use `FromNat`, `FromInteger` and `@lg.lift_to`.

///|
#warnings("-deprecated")
pub impl[T : @lg.NatHomomorphism + Zero] @lg.NatHomomorphism for Dual[T] with fn[
  S : @lg.Nat,
] from_nat(value : S) -> Dual[T] {
  Dual::constant(@lg.NatHomomorphism::from_nat(value))
}

///|
#warnings("-deprecated")
pub impl[T : @lg.IntegralHomomorphism + Zero] @lg.IntegralHomomorphism for Dual[
  T,
] with fn[S : @lg.Integral] from_integral(value : S) -> Dual[T] {
  Dual::constant(@lg.IntegralHomomorphism::from_integral(value))
}

///|
#warnings("-deprecated")
#deprecated("Use `@lg.FromNat::from_natural` or `@lg.lift_to` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with @lg.NatHomomorphism::{from_nat}

///|
#warnings("-deprecated")
#deprecated("Use `@lg.FromInteger::from_integer` or `@lg.lift_to` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with @lg.IntegralHomomorphism::{from_integral}

///|
pub extend Dual with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with Eq::{not_equal}

///|
#deprecated("Use `Repr(x)` or `@debug.Debug::to_repr` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with @debug.Debug::{to_repr}

///|
pub extend Dual with Add::{add}

///|
pub extend Dual with Sub::{sub}

///|
pub extend Dual with Neg::{neg}

///|
pub extend Dual with Mul::{mul}

///|
pub extend Dual with Div::{div}

///|
pub extend Dual with Zero::{zero}

///|
pub extend Dual with One::{one}

///|
/// Checked quotient-rule division, mirroring the inherent `Dual::sqrt_checked`.
pub extend Dual with DivChecked::{div_checked}

///|
#deprecated("Use `@lg.NatHomomorphism::from_nat` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with NatHomomorphism::{from_nat}

///|
#deprecated("Use `@lg.IntegralHomomorphism::from_integral` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with IntegralHomomorphism::{from_integral}

///|
#deprecated("Use `@arithmetic.Constants::pi`/`e`/`tau` instead", skip_current_package=true)
#doc(hidden)
pub extend Dual with Constants::{pi, e, tau}

# Changelog

All notable changes to `Luna-Flow/autodiff` are recorded here. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project uses semantic versioning.

## Unreleased

### Changed

- Migrated to MoonBit 0.10: `moon.mod` declares `source = "src"` directly
  instead of through `options(...)`, and the `moonbitlang/core/test` test
  imports that are no longer needed were dropped from `dual`, `linalg` and
  `poly`; the unused `luna-generic` import was dropped from `examples`.
- Trait methods of `Dual[T]` are now promoted explicitly in
  `src/dual/extends.mbt`. `Dual::add`, `sub`, `neg`, `mul`, `div`, `equal`,
  `zero`, `one` and `div_checked` are listed in the interface file as
  methods.
- Generic code calls trait methods in trait-qualified form
  (`Zero::zero()`, `One::one()`) instead of the deprecated `T::method` form.
- Dependencies bumped to the latest published releases:
  `Luna-Flow/luna-generic` 0.3.3 → 0.4.0, `Luna-Flow/arithmetic` 0.2.1 →
  0.5.0 and `Luna-Flow/linear-algebra` 0.3.0 → 0.4.7. `Luna-Flow/luna-poly`
  stays at 0.2.0.
- **Breaking:** migrated from the `NatHomomorphism` / `IntegralHomomorphism`
  traits, deprecated in luna-generic 0.4.0, to `FromNat` / `FromInteger`.
  `Dual[T]` implements `FromNat` and `FromInteger` (a constant with zero
  tangent), and `Dual::from_natural` / `Dual::from_integer` are promoted like
  `Dual::zero` / `Dual::one`.
  `Dual::sqrt`, `sqrt_checked`, `exp2`, `log2`, `log10` and the `Sqrt`,
  `SqrtChecked`, `Exponential` and `Logarithmic` instances of `Dual[T]` now
  require `T : FromInteger` instead of `T : IntegralHomomorphism`; the
  constants 2 and 10 are built with `lift_to`. The root package and `core`
  re-export `FromInteger` and `FromNat` instead of `IntegralHomomorphism`.
- With arithmetic 0.5, the checked operations of `Dual[Double]` and
  `Dual[Float]` follow the new error kinds: `sqrt_checked` of a negative value
  reports `DomainError` instead of returning `Ok(NaN)`, and `div_checked`
  reports `DomainError` for `0 / 0` and `∞ / ∞` (also in the tangent quotient)
  instead of a division by zero.

### Deprecated

- The implicitly promoted method forms `Dual::not_equal`, `Dual::to_repr`,
  `Dual::pi`, `Dual::e` and `Dual::tau`. Use `!=`,
  `Repr(x)` / `@debug.Debug::to_repr` and `Constants::pi` / `e` / `tau`
  instead.
- The `NatHomomorphism` and `IntegralHomomorphism` instances of `Dual[T]`, with
  the hidden method forms `Dual::from_nat` and `Dual::from_integral`, are kept
  as compatibility shims in `src/dual/compat.mbt`. luna-poly 0.2.0 still
  bounds `DensePolynomial::derivative` by `NatHomomorphism`, and the shims keep
  it working for dual coefficients (covered by a test). They will be removed
  once luna-poly moves to `FromNat` and is published. Use
  `FromNat::from_natural`, `FromInteger::from_integer` or `@lg.lift_to` in
  new code.

### Removed

- The `IntegralHomomorphism` re-export from the root package and `core`; they
  re-export `FromInteger` and `FromNat` instead.

### Added

- Tests for dual evaluation with a non-unit input tangent, agreement with
  the formal derivative of `luna-poly`, polynomial substitution, the sparse
  compatibility aliases, and the sparse bridge after contextual partial
  evaluation.

### Documentation

- Documentation rewritten (API, tutorial and design pages for every package,
  an architecture guide, derivations of the derivative rules and rounding
  error bounds) with zh_CN and ja_JP translations.
- `.gitignore` ignores local AI agent state.
- Manual brought to the luna-generic layout: an overview with install,
  page table, exported items and reading paths; `Purpose` sections on every
  API page, headings for every trait instance of `Dual[T]`, task tables on
  every tutorial, and `Constraints` sections on every design page.
- Corrected the underflow bound of the quotient tangent ($c^2 = 0$ for
  $|c| < 2^{-537.5} \approx 1.57 \times 10^{-162}$, not $2^{-537}$) and
  documented the other failure modes of squaring the divisor: the domain
  error for a constant over a tiny constant, the subnormal range, and the
  silent zero tangent when $c^2$ overflows ($|c| \ge 2^{512}$).
- Documented which `arithmetic` release the checked examples assume (0.5)
  and how `Double` behaves under the pinned `arithmetic@0.2.1`
  (`sqrt_checked` of a negative input returns NaN instead of an error).
- Documented that `ln` of a negative input has a NaN value but a finite
  tangent, and that `sqrt` and `ln` of a constant zero give a NaN tangent.
- Derivations added or fixed: nested second derivatives and the cost of
  nesting ($3^k$ multiplications per product, not $2^k$), the reverse-mode
  adjoint recurrence, the direction of the trait/class inclusions, and the
  cost ratios of dual arithmetic.

## 0.2.0

- `Dual[T]` with ring-level Luna Flow instances, checked division and square
  root, and elementary rules for `sqrt`, `exp`, `exp2`, `ln`, `log2`,
  `log10`, `sin`, `cos` and `tan`.
- Scalar drivers `diff` and `value_and_diff`.
- `autodiff/linalg`: `gradient`, `jacobian`, `value_and_gradient` and
  `value_and_jacobian` over `linear-algebra` immutable vectors and matrices.
- `autodiff/poly`: dense and univariate sparse polynomial derivatives over
  `luna-poly`.

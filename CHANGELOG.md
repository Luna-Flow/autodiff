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
  (`Zero::zero()`, `One::one()`, `IntegralHomomorphism::from_integral(..)`)
  instead of the deprecated `T::method` form.

### Deprecated

- The implicitly promoted method forms `Dual::not_equal`, `Dual::to_repr`,
  `Dual::from_nat`, `Dual::from_integral`, `Dual::pi`, `Dual::e` and
  `Dual::tau`. Use `!=`, `Repr(x)` / `@debug.Debug::to_repr`,
  `NatHomomorphism::from_nat`, `IntegralHomomorphism::from_integral` and
  `Constants::pi` / `e` / `tau` instead.

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

## 0.2.0

- `Dual[T]` with ring-level Luna Flow instances, checked division and square
  root, and elementary rules for `sqrt`, `exp`, `exp2`, `ln`, `log2`,
  `log10`, `sin`, `cos` and `tan`.
- Scalar drivers `diff` and `value_and_diff`.
- `autodiff/linalg`: `gradient`, `jacobian`, `value_and_gradient` and
  `value_and_jacobian` over `linear-algebra` immutable vectors and matrices.
- `autodiff/poly`: dense and univariate sparse polynomial derivatives over
  `luna-poly`.

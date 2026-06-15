# Correctness Checklist

Last audited: 2026-06-16

Legend:

- `Correct`: inspected and backed by tests or clear invariants
- `Bug`: confirmed incorrect behavior
- `Risk`: plausible behavior that deserves follow-up or can drift
- `Unverified`: traversed, but not deeply proven in this pass

Problem types:

- `algebraic contract`
- `checked arithmetic`
- `domain semantics`
- `test gap`
- `generated artifact`
- `facade metadata`
- `integration semantics`

## Core and Scalar Packages

| Package / File | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `src/dual/dual.mbt` `Dual[T]` storage and accessors | `Correct` | - | Constructor/accessor tests in `src/tests/dual_test.mbt`; generated API inspected | Stores only `value` and `tangent`; no hidden symbolic state. |
| `src/dual/dual.mbt` additive operations | `Correct` | `algebraic contract` | Direct arithmetic tests | Addition, subtraction, and negation lift component-wise. |
| `src/dual/dual.mbt` multiplication | `Correct` | `algebraic contract` | Product-rule regression test | Tangent is `x * dy + y * dx`. |
| `src/dual/dual.mbt` Luna generic instances | `Correct` | `algebraic contract` | `pkg.generated.mbti` inspected; `moon check` passed | Includes ring-level structures only where valid. |
| `src/dual/dual.mbt` field/order exclusions | `Correct` | `algebraic contract` | Generated API inspected with no `Field`, `MulGroup`, `Inverse`, or `Compare` impls | Dual numbers are not falsely advertised as a field or ordered scalar. |
| `src/dual/dual.mbt` checked division | `Correct` | `checked arithmetic` | Checked division success and zero-division tests | Reuses `DivChecked`, `ArithmeticContext`, and `ArithmeticError`. |
| `src/dual/dual.mbt` checked square root | `Correct` | `checked arithmetic` | Checked sqrt derivative test | Reuses `SqrtChecked` and `DivChecked`; domain errors stay delegated to the base scalar. |
| `src/dual/dual.mbt` elementary methods | `Correct` | `domain semantics` | `sin` and `exp` derivative tests; trait bounds checked by generated API | Unchecked elementary behavior follows base scalar semantics. |
| `src/forward/forward.mbt` | `Correct` | - | Identity, constant, square, cube, `sin`, and `exp` derivative tests | Seeds `Dual::variable(x)` and returns tangent. |
| `src/core/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Facade re-exports `Dual` and Luna generic traits; no linalg/poly dependency. |
| `src/checked/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Re-exports checked arithmetic surface. |
| `src/elementary/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Re-exports elementary arithmetic surface. |
| `src/alias.mbt` | `Correct` | `facade metadata` | Generated root API inspected | Root package exposes scalar forward-mode API and arithmetic/generic aliases. |
| `src/tests/dual_test.mbt` | `Correct` | - | `moon test` passed | Covers core constructors, algebra, forward AD, checked division, and checked sqrt. |

## `src/linalg`

| Item | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `gradient` | `Correct` | `integration semantics` | Tests for `x² + x*y`, dot product, and quadratic form | Computes scalar gradients by n-pass forward-mode seeding, one input coordinate per pass. |
| `value_and_gradient` | `Correct` | `integration semantics` | Test checks value `10` and gradient `[7, 2]` | Value is evaluated with zero tangents; gradient uses `gradient`. |
| `jacobian` | `Correct` | `integration semantics` | Test checks `[[1, 1], [3, 2], [4, 0]]` | Uses n-pass forward-mode seeding. Convention is `J[row = output_index, col = input_index]`. |
| `value_and_jacobian` | `Correct` | `integration semantics` | Test checks primal `[5, 6, 4]` and expected Jacobian | Value is evaluated with zero tangents; Jacobian uses `jacobian`. |
| Shape validation | `Risk` | `test gap` | Implementation inspected | Current APIs assume valid input length and stable output length. TODO: add checked variants if upstream shape errors become available. |
| Dependency boundary | `Correct` | `integration semantics` | `src/linalg/moon.pkg` inspected | Depends on `autodiff/dual`, `luna-generic`, and `linear-algebra/immut`; lower packages do not import linalg. |

Risk level: low for valid dimensions; medium for invalid dimensions because behavior is inherited from vector indexing/function assumptions.

Future work: checked shape/dimension variants, if Luna Flow linear algebra standardizes a shared checked shape-error API.

## `src/poly`

| Item | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| Dense dual evaluation | `Correct` | `integration semantics` | Dense quadratic, cubic, constant, and linear tests | Polynomial differentiation is evaluation-based AD over `Dual[T]`, not symbolic differentiation. |
| Dense value/derivative helpers | `Correct` | `integration semantics` | Tests cover `dense_value_and_derivative_at`, `value_and_derivative_at`, and derivative aliases | Returns `(p(x), p'(x))` by evaluating at `Dual::variable(x)`. |
| Sparse single-variable evaluation | `Correct` | `integration semantics` | Sparse missing-degree, constant, and linear tests | Sparse bridge evaluates with one assignment `[x]`; this is a univariate helper over sparse terms. |
| Sparse naming clarity | `Correct` | `facade metadata` | Generated API inspected | Clear `sparse_univariate_*` aliases added; older `sparse_*` names remain for compatibility. |
| Multivariate partial derivatives | `Unverified` | `domain semantics` | Implementation intentionally does not expose context-aware variable selection | Not implemented. The current sparse bridge must not be documented as arbitrary multivariate AD. |
| Dependency boundary | `Correct` | `integration semantics` | `src/poly/moon.pkg` inspected | Depends on `autodiff/dual`, `luna-generic`, and `luna-poly`; lower packages do not import poly. |

Risk level: low for dense and univariate sparse evaluation; medium if users expect multivariate sparse partial derivatives from the compatibility names.

Future work: context-aware multivariate polynomial partial derivatives with explicit variable selection.

## Generated Artifacts

| File / Group | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `src/**/pkg.generated.mbti` | `Correct` | `generated artifact` | Regenerated with `moon info` | Do not edit by hand. Review diffs after public API changes. |

## Root Workflow and Documentation

| File | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `moon.mod` | `Correct` | - | Inspected directly | Canonical module metadata and dependency manifest. |
| `README.md` | `Correct` | - | Checked against current generated API | Describes v0.2 scalar AD, linalg integration, poly integration, limitations, and roadmap. |
| `doc/en_US/*` | `Correct` | - | Existing v0.2 integration docs inspected | English package, API, tutorial, and design docs are aligned with current package layout. |
| `doc/zh_CN/*` | `Correct` | - | Existing v0.2 integration docs inspected | Chinese docs mirror current v0.2 semantics. |
| `doc/ja_JP/*` | `Correct` | - | Existing v0.2 integration docs inspected | Japanese docs mirror current v0.2 semantics. |
| `CONTRIBUTING.md` | `Correct` | - | Adapted from Luna Flow engineering workflow | Documents local contribution and correctness expectations. |
| `run_test.sh` | `Correct` | - | Package matrix matches current repository | Runs root and package-level tests. |
| `ready_to_pr.sh` | `Correct` | - | Mirrors Luna Flow PR workflow | Formats, checks, regenerates API, cleans, and runs coverage. |
| `update_deps.sh` | `Correct` | - | Dependency list matches `moon.mod` | Explicit maintenance script for refreshing dependencies. |
| `justfile` | `Correct` | - | Recipes match current repository | Provides local workflow shortcuts. |

## Follow-Up Queue

1. Add direct regression tests for `ln`, `sqrt`, `cos`, and `tan` derivatives once the desired checked/unchecked domain policy is stable.
2. Consider checked logarithm traits if `Luna-Flow/arithmetic` grows that surface.
3. Add checked linalg shape validation if upstream linear-algebra exposes standard checked dimension errors.
4. Add context-aware multivariate sparse polynomial partial derivatives only as an explicit future feature.
5. Add CI workflow parity with other Luna Flow repositories when this repository is ready for remote publishing.

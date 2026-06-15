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

## Source Packages

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
| `src/core/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Facade only; no behavior. |
| `src/checked/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Re-exports checked arithmetic surface. |
| `src/elementary/alias.mbt` | `Correct` | `facade metadata` | Generated API inspected | Re-exports elementary arithmetic surface. |
| `src/alias.mbt` | `Correct` | `facade metadata` | Generated root API inspected | Root package exposes v0.1 API. |
| `src/tests/dual_test.mbt` | `Correct` | - | `moon test` passed | Covers core constructors, algebra, forward AD, checked division, and checked sqrt. |

## Generated Artifacts

| File / Group | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `src/**/pkg.generated.mbti` | `Correct` | `generated artifact` | Regenerated with `moon info` | Do not edit by hand. |

## Root Workflow

| File | Status | Problem Type | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `moon.mod` | `Correct` | - | Inspected directly | Canonical module metadata and dependency manifest. |
| `README.md` | `Correct` | - | Checked against current generated API | States v0.1 scope and future work boundaries. |
| `doc/en_US/*` | `Correct` | - | Added against current generated API and package layout | English package, API, tutorial, and design docs are aligned with v0.1. |
| `doc/zh_CN/*` | `Correct` | - | Added against current generated API and package layout | Chinese docs mirror current v0.1 semantics. |
| `doc/ja_JP/*` | `Correct` | - | Added against current generated API and package layout | Japanese docs mirror current v0.1 semantics. |
| `CONTRIBUTING.md` | `Correct` | - | Adapted from Luna Flow engineering workflow | Documents local contribution and correctness expectations. |
| `run_test.sh` | `Correct` | - | Package matrix matches current repository | Runs root and package-level tests. |
| `ready_to_pr.sh` | `Correct` | - | Mirrors Luna Flow PR workflow | Formats, checks, regenerates API, cleans, and runs coverage. |
| `update_deps.sh` | `Correct` | - | Dependency list matches `moon.mod` | Explicit maintenance script for refreshing dependencies. |
| `justfile` | `Correct` | - | Recipes match current repository | Provides local workflow shortcuts. |

## Follow-Up Queue

1. Add direct regression tests for `ln`, `sqrt`, `cos`, and `tan` derivatives once the desired checked/unchecked domain policy is stable.
2. Consider checked logarithm traits if `Luna-Flow/arithmetic` grows that surface.
3. Add CI workflow parity with other Luna Flow repositories when this repository is ready for remote publishing.

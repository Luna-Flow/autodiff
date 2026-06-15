# Contribution Guidelines

This guide tracks the repository workflow for Luna Autodiff and follows the
same engineering-quality baseline used across Luna Flow packages.

## Code Style

- Run `moon fmt` before committing.
- Prefer `using`-imported names over repeated fully-qualified package calls
  when the same imported names are used several times in a file.
- Keep package dependencies narrow. In particular, do not make the lightweight
  core/facade packages depend on `linear-algebra`, `luna-poly`, `floating`, or
  `type_theory`.
- Keep public APIs small and algebraically honest. Do not add `Field`,
  `MulGroup`, `Inverse`, or total-order instances for `Dual[T]`.

## Naming

- Use `lowercase_with_underscores` for functions, bindings, files, and folders.
- Use `PascalCase` for structs, traits, and enum constructors.
- Prefer descriptive names over short aliases except for local mathematical
  formulas where the meaning is obvious.
- Reuse Luna Flow trait and error names instead of introducing duplicate
  protocols.

## Comments And Documentation

- Comments should explain non-obvious mathematical or API constraints.
- Keep comments accurate when formulas or trait bounds change.
- Public README examples should compile or be explicitly marked as illustrative.
- Document semantic exclusions clearly: no fake field instance, no natural total
  order, no reverse mode, no symbolic differentiation, and no CAS behavior.

## File Organization

- Keep `src/dual` as the owner of `Dual[T]` so methods and trait instances stay
  with the type.
- Keep `src/core`, `src/checked`, `src/elementary`, `src/forward`, and root
  package files as small facades unless there is a strong MoonBit ownership
  reason to move behavior.
- Keep tests in `src/tests` unless white-box package access is required.
- Do not add generic `utils.mbt` files; use names tied to a concrete capability.

## Correctness Bar

- Every new operation on `Dual[T]` must state the derivative rule it implements
  and have at least one direct regression test.
- Checked operations must reuse `Luna-Flow/arithmetic` result and error types.
- Domain-sensitive operations should prefer checked semantics when existing
  Luna Flow traits provide them.
- Any addition to algebraic trait instances must be justified by the actual
  algebraic structure, not convenience.

## Commit Guidelines

- Run `./ready_to_pr.sh` before opening a PR when practical.
- Commit messages must be in English and use a Conventional Commits prefix such
  as `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `build:`, or
  `ci:`.
- Keep commits focused on a single logical change.
- Do not change dependency versions in `moon.mod` without maintainer intent.

## Release Checklist

- Bump `moon.mod` to the intended unreleased version before publishing.
- Update `README.md` if the public API or package positioning changes.
- Run `moon check`, `./run_test.sh`, and `moon info`.
- Confirm generated `pkg.generated.mbti` files match the intended public API.
- If mooncakes reports a duplicate version, bump the version before retrying.

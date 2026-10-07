# linalg API

The `linalg` package uses immutable vectors and matrices from
`Luna-Flow/linear-algebra/immut`.

- `gradient(f, x) -> Vector[T]`
- `jacobian(f, x) -> Matrix[T]`
- `value_and_gradient(f, x) -> (T, Vector[T])`
- `value_and_jacobian(f, x) -> (Vector[T], Matrix[T])`

`gradient` expects:

```text
f : Vector[Dual[T]] -> Dual[T]
x : Vector[T]
```

`jacobian` expects:

```text
f : Vector[Dual[T]] -> Vector[Dual[T]]
x : Vector[T]
```

The Jacobian uses the output-by-input convention:

```text
J[row = output_index, col = input_index]
```

The package uses n-pass forward-mode seeding. It does not require or define
field-level behavior for `Dual[T]`.

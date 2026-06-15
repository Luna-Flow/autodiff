# エコシステム連携 API

この文書は v0.2 の Luna Flow エコシステム向けブリッジパッケージを説明します。

## `autodiff/linalg`

`linalg` パッケージは `Luna-Flow/linear-algebra/immut` の immutable ベクトルと行列を使います。

- `gradient(f, x) -> Vector[T]`
- `jacobian(f, x) -> Matrix[T]`
- `value_and_gradient(f, x) -> (T, Vector[T])`
- `value_and_jacobian(f, x) -> (Vector[T], Matrix[T])`

`gradient` の概念的なシグネチャ:

```text
f : Vector[Dual[T]] -> Dual[T]
x : Vector[T]
```

`jacobian` の概念的なシグネチャ:

```text
f : Vector[Dual[T]] -> Vector[Dual[T]]
x : Vector[T]
```

Jacobian は output-by-input の向きを使います。

```text
J[row = output_index, col = input_index]
```

このパッケージは n-pass 前進モード seeding を使います。`Dual[T]` の体としての振る舞いは要求せず、定義もしません。

## `autodiff/poly`

`poly` パッケージは `Luna-Flow/luna-poly` へのブリッジです。

dense 単変数ヘルパー:

- `eval_dual(p, x_dual) -> Dual[T]`
- `value_and_derivative_at(p, x) -> (T, T)`
- `derivative_at(p, x) -> T`

sparse を一変数として使うヘルパー:

- `eval_sparse_dual(p, x_dual) -> Dual[T]`
- `sparse_value_and_derivative_at(p, x) -> (T, T)`
- `sparse_derivative_at(p, x) -> T`

これらの関数は既存の Luna Poly 表現を双対数上で評価します。記号微分は行わず、新しい多項式表現も導入しません。

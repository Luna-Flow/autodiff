# 設計ノート

autodiff v0.2 は core 層を小さく保ちながら、エコシステム連携パッケージを追加します。core は引き続き双対数による前進モード自動微分を提供し、記号代数、逆モード、最適化 API は提供しません。

## パッケージ所有権

`Dual[T]` は `dual` パッケージが所有します。これにより MoonBit のメソッドと trait 実装を型と同じパッケージに置けます。`core`、`checked`、`elementary`、`forward`、root は軽量 facade です。

`linalg` と `poly` は連携層です。橋渡し先の Luna Flow ライブラリには依存しますが、低レベルの autodiff パッケージはこれらの連携層に依存しません。

## 代数的制約

双対数は環的なスカラーですが、体ではありません。`0 + 1ε` は非ゼロの冪零元なので乗法逆元を持ちません。そのため `Dual[T]` は `Field`、`MulGroup`、`Inverse` を実装しません。

双対数には自然な全順序もないため、`Compare` も実装しません。

## Checked セマンティクス

checked 操作は `Luna-Flow/arithmetic` の `ArithmeticContext`、`ArithmeticError`、`DivChecked`、`SqrtChecked` を再利用します。

## v0.2 の範囲外

- `Forward[T]` のベクトル値 tangent ストレージ
- 高階 `Jet[T]`
- interval または ball スカラー上の validated AD
- 逆モード自動微分
- CAS 層による記号微分

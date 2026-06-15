# 設計ノート

Luna Autodiff v0.1 は意図的に小さく保たれています。双対数による前進モード自動微分だけを提供し、記号代数、逆モード、最適化 API は提供しません。

## パッケージ所有権

`Dual[T]` は `dual` パッケージが所有します。これにより MoonBit のメソッドと trait 実装を型と同じパッケージに置けます。`core`、`checked`、`elementary`、`forward`、root は軽量 facade です。

## 代数的制約

双対数は環的なスカラーですが、体ではありません。`0 + 1ε` は非ゼロの冪零元なので乗法逆元を持ちません。そのため `Dual[T]` は `Field`、`MulGroup`、`Inverse` を実装しません。

双対数には自然な全順序もないため、`Compare` も実装しません。

## Checked セマンティクス

checked 操作は `Luna-Flow/arithmetic` の `ArithmeticContext`、`ArithmeticError`、`DivChecked`、`SqrtChecked` を再利用します。

## v0.1 の範囲外

- ベクトル値 tangent の前進モード
- 線形代数型に対する gradient と Jacobian
- 高階 `Jet[T]`
- 多項式ブリッジ
- interval または ball スカラー上の validated AD
- 逆モード自動微分

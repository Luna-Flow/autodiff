# Luna Autodiff ドキュメント

これは `Luna-Flow/autodiff` `0.1.0` の日本語ドキュメントです。

## 概要

Luna Autodiff は Luna Flow の代数・算術構造の上で前進モード自動微分を提供します。

現在のバージョンは双対数を導入します。

```text
Dual[T] = value + tangent ε, ε² = 0
```

`Dual::variable(x)` で通常のスカラー関数を評価すると、値と一階微分を同時に得られます。

## 現在の API

- `value` と `tangent` を持つ `Dual[T]`。
- コンストラクタ: `Dual::new`、`Dual::constant`、`Dual::variable`。
- アクセサ: `Dual::value`、`Dual::tangent`。
- 基底型が条件を満たす場合の環レベル代数インスタンス。
- `Luna-Flow/arithmetic` による checked division と checked sqrt。
- `sqrt`、`exp`、`ln`、`sin`、`cos`、`tan` のリフト。
- 前進モードヘルパー: `diff` と `value_and_diff`。

## ドキュメント

- Core API: [core/api.md](core/api.md)
- Tutorial: [core/tutorial.md](core/tutorial.md)
- Design notes: [core/design.md](core/design.md)
- Documentation standard: [doc_standard.md](doc_standard.md)

## 検証

推奨チェック:

```bash
moon check
./run_test.sh
moon info
```

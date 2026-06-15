# エコシステム連携設計

## 依存方向

連携パッケージは core autodiff 層の上に位置します。

```text
autodiff/core       -> luna-generic only
autodiff/dual       -> luna-generic, arithmetic
autodiff/elementary -> arithmetic
autodiff/checked    -> arithmetic
autodiff/forward    -> core/dual/elementary
autodiff/linalg     -> autodiff + linear-algebra
autodiff/poly       -> autodiff + luna-poly
```

低レベルパッケージは `linear-algebra`、`luna-poly`、`floating`、`type_theory` を import しません。

## 線形代数

`T` が必要な Luna Flow 代数 trait を満たすとき、`Dual[T]` は環レベルのベクトル・行列演算の正当なスカラーです。連携層は `Field`、全除算、逆元、全順序を必要とするアルゴリズムを意図的に避けます。

gradient と Jacobian は n-pass 前進モード seeding を使います。これは単純で正しく、API を小さく保ちます。ベクトル値 tangent ストレージは将来作業です。

## 多項式評価

多項式ブリッジは `luna-poly` のデータ構造を再利用します。係数を `Dual[T]` の定数へリフトし、既存の Luna Poly 評価アルゴリズムで評価し、tangent をその点での導関数として読みます。

これは評価アルゴリズムへの自動微分であり、記号微分ではありません。

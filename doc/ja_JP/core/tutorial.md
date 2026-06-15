# チュートリアル

## スカラー関数を微分する

`diff` を使ってスカラー関数の導関数値を計算します。

```moonbit
let d = @autodiff.diff(fn(x) { x * x }, 3.0)
```

結果は `6.0` です。

## 値と導関数を同時に得る

```moonbit
let (value, derivative) = @autodiff.value_and_diff(
  fn(x) { x * x * x },
  2.0,
)
```

値は `8.0`、導関数値は `12.0` です。

## 定数と変数

`Dual::constant(x)` の tangent はゼロです。`Dual::variable(x)` の tangent は一です。

```moonbit
let c = @autodiff.Dual::constant(5.0)
let x = @autodiff.Dual::variable(2.0)
```

定数の微分はゼロ、恒等変数の微分は一です。

## 初等関数

基底スカラーが対応する Luna Flow arithmetic trait をサポートする場合、初等関数メソッドを使えます。

```moonbit
let d = @autodiff.diff(fn(x) { x.sin() }, 0.5)
```

導関数値は `cos(0.5)` です。

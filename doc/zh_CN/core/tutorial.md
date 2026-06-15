# 教程

## 对标量函数求导

使用 `diff` 计算标量函数的导数。

```moonbit
let d = @autodiff.diff(fn(x) { x * x }, 3.0)
```

结果是 `6.0`。

## 同时保留函数值和导数

```moonbit
let (value, derivative) = @autodiff.value_and_diff(
  fn(x) { x * x * x },
  2.0,
)
```

函数值是 `8.0`，导数是 `12.0`。

## 常量和变量

`Dual::constant(x)` 的 tangent 为零。`Dual::variable(x)` 的 tangent 为一。

```moonbit
let c = @autodiff.Dual::constant(5.0)
let x = @autodiff.Dual::variable(2.0)
```

常量的导数为零，恒等变量的导数为一。

## 初等函数

当基标量支持对应 Luna Flow arithmetic trait 时，可以使用初等函数方法。

```moonbit
let d = @autodiff.diff(fn(x) { x.sin() }, 0.5)
```

导数是 `cos(0.5)`。

## 后续阅读

gradient、Jacobian 和多项式定点导数示例见生态集成教程：

- [../integration/tutorial.md](../integration/tutorial.md)

# 核心 API

本文档描述核心对偶数前向模式自动微分 API。生态集成桥接 API 见
[`../integration/api.md`](../integration/api.md)。

## 对偶数

```moonbit
pub struct Dual[T] {
  value : T
  tangent : T
}
```

`value` 是原始标量值，`tangent` 是一阶导数分量。

## 构造器

- `Dual::new(value, tangent)` 直接构造对偶数。
- `Dual::constant(x)` 构造 `Dual(x, zero)`。
- `Dual::variable(x)` 构造 `Dual(x, one)`。

`constant` 使用 `Luna-Flow/luna-generic` 的 `Zero`。`variable` 使用 `One`。

## 访问器

- `Dual::value(self)` 返回原始值。
- `Dual::tangent(self)` 返回 tangent。

## 代数

已实现的运算包括：

- 加法：`(x, dx) + (y, dy) = (x + y, dx + dy)`
- 减法：`(x, dx) - (y, dy) = (x - y, dx - dy)`
- 取负：`-(x, dx) = (-x, -dx)`
- 乘法：`(x, dx) * (y, dy) = (x * y, x * dy + y * dx)`

当基类型满足约束时，`Dual[T]` 实现 Luna Flow 的环层级结构。它不会实现 `Field`、`MulGroup`、`Inverse` 或总序。

## Checked Arithmetic

checked division 使用 `DivChecked`，失败通过 `ArithmeticError` 返回。

checked square root 使用 `SqrtChecked` 和 `DivChecked`。

## 初等函数

当前提升的初等函数包括：

- `sqrt`
- `exp`
- `ln`、`log2`、`log10`
- `sin`、`cos`、`tan`

除 checked trait 外，定义域和分支行为沿用基标量实现。

## 前向模式辅助函数

- `value_and_diff(f, x)` 返回 `(value, derivative)`。
- `diff(f, x)` 只返回导数。

## 包边界

核心对偶数包保持轻量。它们依赖 `Luna-Flow/luna-generic`，并在 checked
或初等函数操作中依赖 `Luna-Flow/arithmetic`。核心层不导入
`linear-algebra`、`luna-poly`、`floating` 或 `type_theory`。

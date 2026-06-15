# Luna Autodiff 文档

这是 `Luna-Flow/autodiff` `0.1.0` 的中文文档。

## 概览

Luna Autodiff 在 Luna Flow 的代数和算术结构上提供前向模式自动微分。

当前版本引入对偶数：

```text
Dual[T] = value + tangent ε, ε² = 0
```

普通标量函数在 `Dual::variable(x)` 上求值时，可以同时得到函数值和一阶导数。

## 当前 API

- `Dual[T]`，包含 `value` 和 `tangent`。
- 构造器：`Dual::new`、`Dual::constant`、`Dual::variable`。
- 访问器：`Dual::value`、`Dual::tangent`。
- 在基类型满足条件时实现环层级代数结构。
- 通过 `Luna-Flow/arithmetic` 支持 checked division 和 checked sqrt。
- 支持 `sqrt`、`exp`、`ln`、`sin`、`cos`、`tan` 等初等函数提升。
- 前向模式辅助函数：`diff` 和 `value_and_diff`。

## 文档

- 核心 API：[core/api.md](core/api.md)
- 教程：[core/tutorial.md](core/tutorial.md)
- 设计说明：[core/design.md](core/design.md)
- 文档规范：[doc_standard.md](doc_standard.md)

## 验证

推荐检查：

```bash
moon check
./run_test.sh
moon info
```

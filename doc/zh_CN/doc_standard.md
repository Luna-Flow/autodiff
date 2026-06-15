# 文档规范

`Luna-Flow/autodiff` 的文档必须描述当前分支中真实存在的实现，并与导出的 MoonBit API、代数约束和发布范围保持一致。

## 规则

- 每个支持的语言目录都应包含 `README.md`、`doc_standard.md` 和子系统文档。
- 只记录当前分支已经实现的 API 和行为。
- 术语应与 `luna-generic` 和 `arithmetic` 中的 Luna Flow 命名保持一致。
- 不得把 `Dual[T]` 描述为域或有序标量。
- 未来工作必须明确标注为未来工作。
- 每个子系统目录应包含 `api.md`、`tutorial.md` 和 `design.md`。

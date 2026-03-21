# Omnigram Server 路线图审计提示词

请你作为一位资深的**开源自托管产品架构师**和**技术产品经理**，对 Omnigram Server 的路线图文档进行全面审计。

---

## 背景

Omnigram 是一个**AI-Native 自托管书库管理 + 阅读服务**，定位对标：
- **Jellyfin**（视频）→ **Immich**（照片）→ **Omnigram**（书籍）
- 核心叙事：Calibre-Web + AI + TTS = Omnigram

技术栈：
- **Server**：Go 1.23 + Gin + GORM + BadgerDB + gRPC
- **App**：Flutter（Fork 自 Anx Reader v1.14.0，7,900+ ⭐，MIT 许可）
- **TTS**：Fish Audio（gRPC 协议）
- **部署**：Docker / Docker Compose

当前状态：
- App 端已完成 Fork + 品牌化（Phase 1 ✅）
- Server 端有 39 个 API 端点，但存在 7 个 P0 安全漏洞，功能完整度约 Calibre-Web 的 30%

---

## 审计对象

请阅读以下文件（按此顺序）：

1. `docs/discussions/011-server-gap-analysis.md` — **主审计目标**（Server 产品差距分析 + 补全路线图）
2. `docs/discussions/001-competitive-analysis.md` — 竞品调研与战略定位
3. `docs/discussions/006-business-model.md` — 商业模式（Open Core）
4. `docs/discussions/005-ai-era-ebook-demand.md` — AI 时代电子书需求
5. `docs/discussions/007-target-customers.md` — 目标客户群体
6. `docs/discussions/008-code-quality-audit.md` — 代码质量审计报告
7. `docs/discussions/009-fork-anx-reader-plan.md` — Fork 决策与原始 Phase 计划
8. `README.md` — 项目对外定位
9. `server/` — Server 源代码（可选扫描，验证文档中的技术判断）

---

## 审计维度

请从以下 **7 个维度** 逐一评估，每个维度给出 **评分（1-5）+ 具体问题 + 改进建议**：

### 1. 战略一致性
- 路线图是否与「AI-Native Calibre-Web」的产品定位一致？
- Phase 分层是否合理？「先打地基再盖楼」的策略是否正确？
- 有没有遗漏的关键战略假设？

### 2. 优先级判断
- Phase 1.5 的安全修复排序是否合理？
- Phase 2.0 中 6 个模块（元数据/标签/OPDS/搜索/统计/笔记）的优先级是否正确？
- 有没有应该提前做或可以延后做的功能？
- MVP 的边界在哪里？什么是第一个可发布版本的最小功能集？

### 3. 技术可行性
- 提出的 API 设计是否合理？有没有过度设计或遗漏？
- 新增数据模型（Shelf、ReadingSession、Note）是否合理？
- OPDS 实现方案是否完整？（对比 OPDS 1.2 规范）
- SQLite FTS5 vs PostgreSQL tsvector 的搜索方案是否合适？
- 有没有技术风险被低估了？

### 4. 竞品对标准确性
- 与 Calibre-Web 的差距分析是否准确？（是否遗漏了 Calibre-Web 的关键功能）
- 与 Kavita、Audiobookshelf、Komga 等竞品的对比是否充分？
- 「30% 功能完整度」的判断是否准确？

### 5. 用户价值排序
- 从目标用户（NAS 数字囤积者、自托管极客）的角度，功能优先级是否正确？
- 用户安装后的「Aha moment」是什么？路线图是否确保了这一点？
- 有没有用户根本不需要但被过度设计的功能？

### 6. 风险与遗漏
- 有没有被忽略的重大技术风险？
- 有没有被忽略的产品风险（如市场时机、竞品动向）？
- 有没有遗漏的关键功能（对比同类开源项目的标配功能）？
- WebDAV Server 端实现是否应该比 OPDS 更优先？（Anx Reader 原生支持 WebDAV）

### 7. 时间线合理性
- 各 Phase 的工作量是否被低估？
- 「一个人开发」的情况下，这个路线图是否现实？
- 有没有可以并行推进或合并的步骤？

---

## 输出格式

请输出审计报告，格式如下：

```markdown
# 011-server-gap-analysis 审计意见

> 审计日期：YYYY-MM-DD
> 审计角色：开源自托管产品架构师 + 技术产品经理

## 总评

综合评分：X/5
一句话评价：...

## 逐项审计

### 1. 战略一致性（X/5）
**优点：**
- ...
**问题：**
- ...
**建议：**
- ...

### 2. 优先级判断（X/5）
...

（以此类推 7 个维度）

## MVP 定义建议

我认为 Omnigram Server v0.1 的最小可发布功能集应该是：
- ...

## 被遗漏的关键问题

1. ...
2. ...

## 路线图修改建议

如果只能改 3 个地方，我建议：
1. ...
2. ...
3. ...
```

---

## 注意事项

- **不要客气**，直接指出问题。这是内部审计，不是 PR。
- **不要重复文档内容**，只输出你的判断和建议。
- 如果你认为整个方向有问题，请直说。
- 优先考虑「一个独立开发者 + AI 辅助」的现实约束。
- 审计完成后将意见输出到 `docs/discussions/011-review.md`。

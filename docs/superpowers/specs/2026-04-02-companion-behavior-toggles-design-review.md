# Companion Behavior Toggles Design — 评审意见

> **评审日期：** 2026-04-02
> **评审对象：** `2026-04-02-companion-behavior-toggles-design.md`
> **结论：** 需修正 P0 后方可实施，P1 建议同步处理

---

## P0 — 数据丢失风险

### R-1: 新旧客户端混用导致 toggle 被重置为 false

§6 降级表声称 "Old client with new server: Server returns extra fields, old client ignores them" —— 这只是读取方向的真相。**写入方向有数据丢失。**

**问题链：**
1. 新 server 加了 5 个 bool 字段，GORM `default:true` 作用于 `CREATE`
2. 老客户端 `_syncToServer` 手动构造 body，只发 6 个字段（name、proactivity、style、depth、warmth、voice）
3. Server `updateCompanionHandle` 用 `ShouldBindJSON` 反序列化到 `CompanionProfile{}`，缺失的 bool 字段会得到 Go 零值 `false`
4. `SaveCompanionProfile` 做全量 `db.Save(profile)` —— 5 个 toggle 全部被覆写为 `false`
5. 用户的 `annotateHardWords`、`crossBookAlerts`、`autoKnowledgeGraph` 默认应为 `true`，被静默改为 `false`

**同样影响：** `getCompanionHandle` 在 profile 不存在时返回的兜底 JSON 也没有 5 个新字段，旧客户端 `_syncFromServer` 同样不读取它们。

**建议方案：**
- A) Server `updateCompanionHandle` 改为 PATCH 语义：先 `GetCompanionProfile`，再 merge 请求 body 中**存在**的字段，未发送的字段保留原值
- B) 或者客户端和 server 强制同步升级，`_syncToServer` / `_syncFromServer` 使用 `p.toJson()` 全量传输，不再手动映射字段

### R-2: GORM AutoMigrate 对已有行不设置 default

Server 用 `tx.AutoMigrate(&CompanionProfile{})` 建表。AutoMigrate 加列时 GORM 对 **已有行** 不会执行 `DEFAULT` 填充——已有行的 5 个新 bool 列值为 `false`（Go/SQL 零值）。

`annotateHardWords`、`crossBookAlerts`、`autoKnowledgeGraph` 应该默认为 `true`，但已有用户升级后这三个 toggle 会静默变为 `false`。

**建议：** 添加一次性数据迁移：`UPDATE companion_profiles SET annotate_hard_words=true, cross_book_alerts=true, auto_knowledge_graph=true WHERE annotate_hard_words=false`（在 AutoMigrate 之后执行）。或使用 GORM 的 migration framework。

---

## P1 — 设计缺陷

### R-3: `_syncToServer` / `_syncFromServer` 需同步更新但文档未提及

`companion_provider.dart` 的 `_syncToServer` 手动映射 6 个字段：

```dart
await api.putVoid('/user/companion', data: {
  'name': p.name,
  'proactivity': p.proactivity,
  // ... 缺少 5 个新 bool 字段
});
```

`_syncFromServer` 同样手动映射。文档 §5 只提到 freezed codegen，没有提到 provider 的同步代码必须更新。

**建议：** 在实施清单中明确列出 `_syncToServer` 和 `_syncFromServer` 需要新增 5 个字段映射，或改用 `p.toJson()` 消除未来的同步遗漏。

### R-4: `getCompanionHandle` 兜底响应缺少新字段

Server 在 profile 不存在时返回硬编码的 `CompanionProfile{}`（只设了 name、proactivity、style、depth、warmth），5 个新 toggle 字段未设置，返回 `false`。

```go
c.JSON(200, &schema.CompanionProfile{
    UserID:      userID,
    Name:        "TARS",
    Proactivity: 50,
    // ... 缺少 5 个 toggle 字段
})
```

**建议：** 补充 `AnnotateHardWords: true, CrossBookAlerts: true, AutoKnowledgeGraph: true` 到兜底响应，或直接 `db.Create` 后返回完整对象。

### R-5: `annotateHardWords` 的 Guard Point 不准确

§4.1 写 guard 在 `glossary_tooltip.dart`，但 `GlossaryTooltip` 是**用户选中文字后触发**的手动组件，不是自动检测。§2.1 自己也写了 "auto-detect pending"。§4.3 说 "只 gate 自动检测，手动选择不受影响"——但目前没有自动检测代码可以 gate。

**建议：** 要么把 `annotateHardWords` 改为 "Planned"（跟 autoChapterRecap 一样标记 Coming Soon），要么明确说明 guard point 将在自动检测功能实现时添加。当前写一个不存在的 guard 会误导实施。

### R-6: `concept_extractor.dart` 的 guard 应在调用方

`ConceptExtractor.extractFromNotes()` 是静态工具方法，被 `AmbientTasks.extractConcepts()` 调用。在 `ConceptExtractor` 内部加 guard 需要它依赖 `companionProvider`，而这个类目前只接收 `WidgetRef` 用于 AI 可用性检查。

更符合现有模式的做法是在 `AmbientTasks.extractConcepts()` 入口加 guard——与 §4.2 示例的代码片段一致，但 §4.1 表中写的文件路径是 `concept_extractor.dart`。

**建议：** 将 guard location 改为 `service/ai/ambient_tasks.dart` 的 `extractConcepts` 方法。

---

## P2 — 细节补充

### R-7: Preset 的 `autoChapterRecap` 和 `postChapterQuestions` 全部为 false 是否最终态

Scholar preset 定位为"健谈学者"，proactivity=80，但 autoChapterRecap=false、postChapterQuestions=false。当这两个功能实现后，Scholar 是否应该默认开启？如果是，需要再做一次 preset 迁移。

**建议：** 在文档中注明 "Presets will be revisited when these features are implemented" 或在 Scholar 中预设为 `true`（反正 UI 上是 Coming Soon 灰色状态，不影响行为）。

### R-8: 缺少 `companionProvider.notifier` 的 update 方法扩展

现有 `companion_provider.dart` 有 `updateWarmth(int v)` 等快捷方法。5 个新 bool 字段是否需要对应的 `updateAnnotateHardWords(bool v)` 方法？还是统一走 `update(state.copyWith(annotateHardWords: v))`？

**建议：** 为每个 toggle 添加 `updateXxx(bool v)` 便利方法，保持与 slider 一致的 API 风格。

### R-9: 设置页硬编码中文

现有 `companion_settings_page.dart` 全部使用硬编码中文（"阅读伴侣"、"伴侣名称"、"主动性" 等，见 KI-2）。本次新增的 7 个 L10n key 是好的实践，但与现有硬编码混在一起会显得不一致。

**建议：** 在实施清单中决定是否顺带将现有 companion settings 的硬编码文案也迁移到 L10n。

### R-10: Server swagger 文档需重新生成

`CompanionProfile` 结构体变更后，`@Param request body schema.CompanionProfile` 的 swagger 文档会自动包含新字段。需在实施后执行 `cd server && make swagger`。

---

## 建议（非阻塞）

### R-11: 考虑按功能就绪状态分组 toggle 数据结构

5 个 toggle 中有 3 个有对应实现、2 个是 "Coming Soon"。未来可能继续增加 toggle。可考虑用一个 `Map<String, bool>` 或 `BehaviorToggles` 子模型来隔离扩展，避免 `CompanionPersonality` 持续膨胀。当前 6 数值字段 + 5 bool 已经达到 11 个字段。

### R-12: toggle 变更是否需要清除已有 AI 缓存

例如用户关掉 `crossBookAlerts` 后，已生成的 margin notes 是否应该隐藏还是删除？据当前设计只 gate 新生成，已有数据保留。建议明确写入文档以避免实施歧义。

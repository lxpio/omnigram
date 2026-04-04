# Empty State Personality Design — 评审意见

> **评审日期：** 2026-04-01
> **评审对象：** `2026-04-01-empty-state-personality-design.md`
> **结论：** 有条件通过，修正 P0/P1 后可进入实施

---

## P0 — 事实性错误

### R-1: `lottie` 和 `flutter_svg` 不在 pubspec.yaml 中

§7 声称 "already in pubspec — verify, add if missing"，实际搜索 `pubspec.yaml` 两个包均不存在。

**建议：** 明确标注为**新增依赖**，评估包大小影响（lottie ~200KB, flutter_svg ~150KB），并补充 pubspec 变更清单。

---

## P1 — 设计缺陷

### R-2: `icon` → `visual` 不是向后兼容

§3.3 声称 "backward compatible"，但实际是删除 `icon` 参数、新增 `visual` 参数——破坏性变更。当前有 4 处调用需迁移：

| 文件 | 当前传参 |
|------|---------|
| `page/home/desk_page.dart:55` | `icon: Icons.auto_stories_outlined` |
| `page/home/library_page.dart:31` | `icon: Icons.library_books_outlined` |
| `page/home/insights_page.dart:76` | `icon: Icons.insights_outlined` |
| `widgets/reader/companion_panel.dart:271` | 独立 `_buildEmptyState`，不走共享组件 |

**建议：** 二选一：
- A) 保留 `icon` 并标记 `@Deprecated`，同时新增 `visual`（真正向后兼容）
- B) 删除 `icon`，但文档中删除 "backward compatible" 说法，并列出迁移清单

### R-3: Companion Panel 空状态未走共享组件

`companion_panel.dart` 的 `_buildEmptyState` 是独立实现的 Column + Icon + Text，不使用 `EmptyState` widget。文档应说明：
1. 是否要将其统一为共享 `EmptyState` 组件
2. Companion panel 作为 reader 内子组件，L10n context 获取方式是否有差异

### R-4: L10n key 命名与现有约定不一致

文档提议 `emptyState_desk_high`（下划线分隔），现有 ARB 文件统一使用 camelCase：
- `tileContinueReadingEmptyState`
- `randomHighlightEmptyState`

**建议：** 改为 `emptyStateDeskHigh` 等 camelCase 命名。

### R-5: Provider 不应返回 Widget

§3.1 数据流图说返回 `{ message, visual, actionLabel }`（数据），但 §3.2 说 "returns configured `EmptyState` widget"。两处冲突。

Riverpod provider 直接返回 Widget 是反模式——破坏 rebuild 优化且难以测试。

**建议：** Provider 返回 data class（含 message、visualType、actionLabel），由 UI 层负责 build widget。

---

## P2 — 细节补充

### R-6: L10n 工作量低估

文档计算 "12 keys × 16 languages = 192 translations"。但：
- 如果 actionLabel（"去书架"、"导入书籍"）也需国际化，key 数增加
- High tier 文案明显更长，翻译质量审校成本更高
- 建议补充：是否复用现有 actionLabel 的 L10n key（如已有 `navBarBookshelf` 等）

### R-7: Warmth 边界值表述不够精确

§3.2 写 `<34 → low, 34-66 → mid, >66 → high`，§6 写 "34 → mid, 66 → mid (boundaries inclusive to mid)"。逻辑一致但容易造成实现歧义。

**建议：** 统一为 `0-33 → low, 34-66 → mid, 67-100 → high`，或使用 `≤33 / 34-66 / ≥67` 明确化。

### R-8: 资产目录未对齐项目结构

§5.2 路径为 `assets/empty_states/`，但项目现有 assets 目录结构是 `assets/img/`。

**建议：** 确认放置在 `assets/img/empty_states/` 还是新建顶级目录，并补充 pubspec.yaml 的 `assets:` 注册。

### R-9: 缺少测试策略

**建议至少覆盖：**
- `WarmthTier.fromWarmth()` 边界值单元测试（0, 33, 34, 66, 67, 100）
- `EmptyStateConfig.forPage()` 3 tier × 4 page 组合测试
- Provider 集成测试：warmth 变化 → 空状态内容刷新
- 资源加载失败降级测试

---

## 建议（非阻塞）

### R-10: Companion Panel 第一人称叙事

High tier copy 用了第一人称（"我在这里！"），其他三个页面均为第三人称/无人称。如有意为之，建议在文档中注明这是 companion 特有的叙事选择。

### R-11: Lottie 动画的生命周期管理

High tier 使用 Lottie 动画后，`EmptyState` 若仍为 `StatelessWidget`，animation controller 无法 dispose。需说明：
- 使用 `Lottie.asset()` 自管理模式（自动 dispose），还是
- EmptyState 需改为 StatefulWidget / 使用 HookWidget

### R-12: 现有硬编码文案同步清理

当前代码中有硬编码中文空状态文案（已在 KI-2 中记录）：
- `desk_page.dart` — `'书桌还是空的，去书架找一本书开始阅读吧。'`
- `library_page.dart` — `'你的书架还是空的，导入第一本书开始阅读吧。'`
- `insights_page.dart` — `'开始阅读并添加笔记，洞察会随着你的阅读逐渐丰富。'`

本方案实施时应一并迁移这些硬编码到 L10n，可在实施计划中明确标注。

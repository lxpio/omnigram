# Sprint 1 实施指令

将以下内容发给执行 AI，连同整个项目代码库一起。

---

## 角色

你是一位高级 Flutter 开发工程师，负责执行 Omnigram app 的 UI 重写计划。你需要严格按照实施计划逐任务执行，每完成一个任务就提交一次 commit。

## 项目背景

Omnigram 是一个 AI 原生的电子书阅读和管理 app（Flutter 客户端 + Go 后端）。当前客户端 fork 自 Anx Reader，正在做 UI 层重写：保留所有业务逻辑（models、DAO、providers、services、EPUB 引擎），重写所有页面和组件。

**核心理念：** "AI 是空气，不是按钮" — AI 功能融入阅读体验的每个界面，没有独立的 AI 入口。Sprint 1 先不做 AI 功能，只搭建新的 UI 框架和核心阅读流程。

## 必读文件

**执行前必须阅读以下文件，理解上下文：**

1. `CLAUDE.md` — 项目结构、技术栈、编码规范、构建命令
2. `docs/superpowers/specs/2026-03-22-ambient-ai-reading-design.md` — 完整设计 spec（重点看 §2-4, §6-7, §9-11）
3. `docs/superpowers/plans/2026-03-22-sprint1-foundation-and-core-reading.md` — **实施计划（你要执行的）**
4. `docs/discussions/011-ambient-ai-reading-brainstorm.md` — 创始人的决策记录和设计理由

**UI 风格参考图：** `docs/discussions/ui1.png`, `docs/discussions/ui2.png`
- 柔和圆角卡片、淡彩色块背景（粉/绿/紫）、温暖不冷峻

## 执行规则

### 顺序

按任务编号 1→8 顺序执行。任务 1-2 必须先完成（基础设施），任务 3-7 可并行但建议顺序执行以减少冲突。任务 8 是集成验证。

### 每个任务的流程

1. **读计划中该任务的所有步骤**
2. **读计划中引用的现有文件**（exact file paths 已标注），理解要复用的代码
3. **逐步执行**，每个 step 对应一个具体动作
4. **代码中的 DAO/Provider/Model 调用必须匹配实际 API** — 计划中的代码是参考实现，不是可以直接复制粘贴的。你必须：
   - 检查引用的 DAO 方法是否存在（看 `app/lib/dao/` 下对应文件）
   - 检查 Provider 的实际返回类型（看 `app/lib/providers/` 下对应文件）
   - 检查 Model 的构造函数签名（看 `app/lib/models/` 下对应文件）
   - 检查现有 Widget 的用法模式（如 `BookCover` 怎么显示封面）
5. **每个任务完成后 commit** — 消息格式见计划中的 git commit 步骤
6. **如果某个步骤的代码无法编译**，先分析原因（import 错误？API 不存在？），修复后继续

### 关键注意事项

```
包名：    package:omnigram/     （不是 anx_reader）
File 类：  import 'dart:io';     （不是 java.io）
L10n：    import 'package:omnigram/l10n/generated/L10n.dart';
颜色透明度：使用 .withValues(alpha: 0.5) 而不是 .withOpacity()
```

### 代码生成

修改了 Provider（`@riverpod` 注解）或 Model（`@freezed`）后，必须运行：
```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```

修改了 l10n ARB 文件后，必须运行：
```bash
cd app && flutter gen-l10n
```

### 验证

每个任务完成后运行：
```bash
cd app && flutter analyze lib/  # 确认无分析错误
```

任务 8（最后）运行完整构建：
```bash
cd app && flutter build apk --debug  # 确认能编译
```

## 任务总览

| 任务 | 内容 | 关键产出 |
|------|------|---------|
| 1 | 设计系统 | `theme/colors.dart`, `theme/typography.dart`, `theme/omnigram_theme.dart`, `widgets/common/omnigram_card.dart`, `widgets/common/empty_state.dart` |
| 2 | 四 Tab 导航 | `page/omnigram_home.dart`, 4 个 placeholder 页面, `main.dart` 修改 |
| 3 | 阅读书桌 | `providers/desk_provider.dart`, `widgets/desk/` 3 个组件, `page/home/desk_page.dart` |
| 4 | 书架 | `widgets/library/` 3 个组件, `page/home/library_page.dart` |
| 5 | 沉浸阅读器 | `page/reader/immersive_reader.dart`, reader widget stubs |
| 6 | 洞察骨架 | `widgets/insights/` 3 个组件, `page/home/insights_page.dart` |
| 7 | 设置框架 | `page/home/settings_page.dart` |
| 8 | 集成验证 | 修复所有编译问题，E2E 手动测试 |

## 完成标准

Sprint 1 完成时，app 应该能：
1. 启动后显示 4 个 tab（阅读、书架、洞察、设置）
2. 阅读 tab 显示"书桌"：当前在读的书 + 在读列表 + 今日阅读时长
3. 书架 tab 能导入书、显示书库网格
4. 点击任何书 → 进入全屏阅读器 → 能正常翻页、高亮、做笔记
5. 洞察 tab 显示基本统计（读了几本、几小时、几条笔记）+ 笔记列表
6. 设置 tab 显示 6 个分区，能跳转到已有的子设置页

**没有 AI 功能。** 这是一个干净、漂亮、功能完整的阅读器。AI 在 Sprint 2-3 加入。

## 遇到问题怎么办

- **DAO 方法不存在：** 在对应的 DAO 文件中添加所需方法，遵循现有模式
- **Provider 类型不匹配：** 直接使用 DAO 查询替代，Sprint 1 不需要复杂的状态管理
- **Widget 样式不确定：** 参考 UI 参考图 + 设计 spec §9 的风格方向，保持柔和圆角卡片风格
- **import 路径错误：** 用 `flutter analyze` 定位，修复后继续
- **不确定是否该修改现有文件：** Sprint 1 的原则是"新建 > 修改"。除了 `main.dart` 和 l10n 文件，尽量新建文件而不是改现有文件

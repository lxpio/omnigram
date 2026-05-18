# Liquid Glass UI 对齐设计（iOS 26 风格）

**日期**：2026-05-18
**作者**：liuyou + Claude
**状态**：Draft（待 review）
**范围**：app/ 全平台 UI 视觉与交互系统

---

## 1. 目标与定位

将 Omnigram app 的"操控层"（导航、按钮、菜单、二级面板）视觉对齐到 **iOS 26 Liquid Glass** 设计语言，同时保留现有 `FlexColorScheme` 暖色圆角卡片作为"内容层"。**跨平台单一代码库**（iOS / macOS / Android / Windows）使用同一套自实现的玻璃组件，不依赖原生组件。

### 设计哲学

- **玻璃 = 操控层**：浮于内容之上的工具（chrome、按钮、菜单、弹窗、设置分组面板）
- **纸张 = 内容层**：承载内容本身（书、笔记、洞察叙事）
- **分层互不打架**：玻璃的中性 tint 透出底下暖色纸张，反而强化视觉层次

### 非目标

- 不替换 Reader 中 EPUB 渲染本体（InAppWebView + foliate-js 保持不动）
- 不强行追求像素级复刻 iOS 26 原生（Squircle 等差异接受 Flutter 近似）
- 不引入第三方"glassmorphism"库，全部自实现保证可控

---

## 2. 总体架构

### 文件组织

```
app/lib/theme/
├── colors.dart                    # 既有，不动
├── typography.dart                # 既有，新增 SF Pro / Roboto Flex 平台 fallback
├── omnigram_theme.dart            # 既有，扩展 extensions 暴露玻璃 token
└── liquid_glass/                  # 新增
    ├── glass_tokens.dart          # 模糊半径 / tint / 高光描边 / 曲率 / 动效曲线
    ├── glass_surface.dart         # 基础容器（BackdropFilter + tint + 描边）
    ├── glass_button.dart          # 含 Morph Press 动画
    ├── glass_app_bar.dart         # 含 Scroll Edge Effect
    ├── glass_tab_bar.dart         # 含 Collapse-to-capsule
    ├── glass_menu.dart            # PopupMenu / ContextMenu
    ├── glass_sheet.dart           # BottomSheet / Dialog 包装
    ├── glass_chip.dart            # Library 筛选 chip / Settings list group
    └── performance_mode.dart      # 性能档位 + Riverpod provider
```

### 与现有组件的关系

| 现有组件 | 改动 |
|---|---|
| `widgets/common/anx_button.dart` | 加薄包装，新增 `style: AnxButtonStyle.glass` 切换，默认不变 |
| `widgets/common/anx_dropdown_button.dart` | 同上 |
| `widgets/common/anx_segmented_button.dart` | 同上 |
| `widgets/common/omnigram_card.dart` | **不动**（属于内容层） |
| `widgets/common/tag_chip.dart` | **不动**（属于内容层） |
| `page/omnigram_home.dart` | 底部导航替换为 `GlassTabBar` |

回滚成本：删 `theme/liquid_glass/` + 改回 button/chip 的 import 即可恢复。

---

## 3. 视觉 Token（`glass_tokens.dart`）

```dart
class GlassTokens {
  // —— 模糊与材质 ——
  static const double blurSigmaThick = 24.0;   // AppBar / TabBar / Sheet
  static const double blurSigmaThin  = 12.0;   // 按钮 / Chip / Menu item
  static const double blurSigmaUltra = 40.0;   // Modal 全屏遮罩

  // —— Tint（在模糊层之上叠的半透明色，决定明暗）——
  // 浅色模式：白色 tint 让玻璃偏亮；深色模式：黑色 tint 偏暗
  // alpha 不超过 0.7，否则失去"透"
  static Color tintLight(BuildContext c) => Colors.white.withValues(alpha: 0.55);
  static Color tintDark(BuildContext c)  => Colors.black.withValues(alpha: 0.45);

  // —— 边缘高光（描边模拟玻璃边缘折射）——
  static const double highlightWidth = 0.8;
  static Color highlightLight = Colors.white.withValues(alpha: 0.6);
  static Color highlightDark  = Colors.white.withValues(alpha: 0.12);
  static Color shadowEdge     = Colors.black.withValues(alpha: 0.08);

  // —— Squircle 圆角（iOS 26 用连续曲率）——
  // Flutter 用 ContinuousRectangleBorder 近似
  static const double radiusButton = 14.0;
  static const double radiusBar    = 22.0;   // TabBar 胶囊态
  static const double radiusSheet  = 28.0;
  static const double radiusMenu   = 18.0;

  // —— 动效曲线（iOS 26 spring）——
  static const Duration morphPressIn   = Duration(milliseconds: 80);
  static const Duration morphPressOut  = Duration(milliseconds: 220);
  static const Cubic    springOut      = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Duration scrollEdgeFade = Duration(milliseconds: 180);
  static const Duration tabCollapse    = Duration(milliseconds: 320);
}
```

### 关键决策

- **Squircle 圆角**：用 `ContinuousRectangleBorder`，是 Flutter 能做到的最贴近 Apple squircle 的实现，成本极低
- **中性 Tint**：内容层是暖色卡片，玻璃 tint 必须中性白/黑，否则双层叠加发黄浑浊
- **不引入暖色 tint 变体**：避免设计漂移

---

## 4. 四大行为规范

### 4.1 Morph Press（按压形变）

- **触发**：`GlassButton` / `GlassChip` / `GlassMenuItem` 的 `onTapDown` → `onTapUp/Cancel`
- **实现**：`AnimatedScale` + `AnimatedContainer` 双层
  - 按下：80ms 缩到 `0.96` + 高光 alpha 从 0.6 → 0.85
  - 释放：220ms `springOut` 曲线回弹到 1.0（过冲到 1.02 再回 1.0）
  - 同步触发 `HapticFeedback.lightImpact()`
- **关键**：缩放中心 `Alignment.center`，不能用默认左上角

### 4.2 Scroll Edge Effect（滚动消隐）

- **触发**：`GlassAppBar` / `GlassTabBar` 监听父级 `ScrollController`
- **实现**：内容 `scrollOffset > 0` 时 bar 的 tint alpha 和 blur sigma 从 0 渐变到满值（180ms）
  - 内容贴近：完整玻璃材质
  - 内容远离：bar 几乎透明，只剩 1px 边缘高光
- **接入方式**：用 `NotificationListener<ScrollUpdateNotification>` 监听，避免每页手动传 controller

### 4.3 Tab Bar Collapse（4-tab 胶囊收缩）

- **触发**：底部 tab bar 监听全局滚动方向
  - 向下滚动 > 60px → 收缩成右下角悬浮胶囊（当前 tab 图标 + 展开箭头）
  - 向上滚动任意距离 → 立即展开
  - 点击胶囊 → 展开
- **动效**：320ms `springOut`，宽度 `screenWidth - 32` → `64`，圆角 22 → 32，位置 `bottom: 16, left: 16, right: 16` → `bottom: 24, right: 16`
- **防抖**：200ms debounce + 最小触发距离 60px，避免快速来回滚动抖动
- **冲突处理**：Reader 全屏沉浸阅读时 tab bar 完全隐藏（非收缩），由 Reader chrome 显示/隐藏逻辑接管

### 4.4 系统字体对齐

- iOS / macOS：`.SF Pro Text`（系统字，无需打包）
- Android：`Roboto Flex`（Flutter 3.16+ 内置可变字重）
- Windows：`Segoe UI Variable`
- 在 `typography.dart` 用 `Platform.isXxx` 判断
- **字重统一为 SF 语义命名**：`regular / medium / semibold / bold`，对齐 iOS 26 Body/Footnote/Caption（17/15/13/11pt）

---

## 5. 五个场景的玻璃化清单

### 5.1 全局 Shell（`omnigram_home.dart`）

- 🪟 `BottomNavigationBar` → `GlassTabBar`（含 Collapse）
- 🪟 顶层 `AppBar` → `GlassAppBar`（含 Scroll Edge）
- 🪟 全局 `SnackBar` / `Dialog` / `BottomSheet` / `PopupMenu` 主题玻璃化

### 5.2 Reading Desk

- 🪟 顶部 AppBar、"继续阅读" CTA、"也在读"横滑卡片的浮动控制点
- 📄 英雄卡、"也在读"书架卡、Daily Summary 卡（保持暖色纸感）
- **视觉亮点**：滚动时玻璃 AppBar 透出英雄卡封面暖色

### 5.3 Library

- 🪟 AppBar（搜索 + 排序菜单）、筛选 chip 横滑条、导入 FAB、长按 ContextMenu
- 📄 书架格子封面卡、书详情元信息卡
- **细节**：筛选 chip 选中态 = 玻璃 + 暖色 tint 叠加；未选中 = 中性玻璃

### 5.4 Insights

- 🪟 AppBar、时间范围 SegmentedButton、跨书连接图悬浮工具栏
- 📄 叙事卡、知识网络节点详情卡
- **细节**：叙事卡之间用玻璃细条分隔，避免硬分割线

### 5.5 Settings

- 🪟 AppBar、**所有 grouped list 的 section 容器**、TARS 伴侣预览面板
- 📄 list tile 内部的"内容样本"子项（颜色选择、字号预览）
- **视觉亮点**：复刻 iOS 26 Settings 的分组玻璃面板悬浮效果

### 5.6 Reader（⚠️ 性能敏感）

- 🪟 顶部章节栏、底部翻页/TOC/字号/书签控制条、长按文本选择菜单、AI 上下文 bar（**全部走降级档**）
- 📄 margin notes 卡、companion panel 对话气泡
- ❌ **EPUB 内容区域绝对不加玻璃**（InAppWebView 双层合成会掉帧）
- **特殊规则**：玻璃工具栏只在 chrome 显示时存在（点击屏幕中央 toggle），翻页/阅读态时完全 dispose

---

## 6. Reader 性能降级策略

### 6.1 性能档位定义

```dart
enum GlassQuality {
  high,    // 完整玻璃：BackdropFilter + tint + 高光 + Morph + Squircle
  medium,  // 中档：半透明色 + 高光描边 + Morph，无 BackdropFilter
  low,     // 低档：纯色 + 1px 描边，无任何动效（可达性兜底）
}

@riverpod
class GlassQualityNotifier extends _$GlassQualityNotifier {
  GlassQuality build() => _autoDetect();
}
```

### 6.2 自动判定（启动时一次性）

| 条件 | 档位 |
|---|---|
| iOS / macOS / Windows | `high` |
| Android, RAM ≥ 6GB, API ≥ 31 | `high` |
| Android, RAM 4–6GB | `medium` |
| Android, RAM < 4GB 或 API < 31 | `low` |
| 用户手动选"省电模式" | `low`（强制） |
| 系统"降低透明度"无障碍开关 | `low`（强制） |

用 `device_info_plus` 探测，结果缓存到 SharedPreferences。

### 6.3 Reader 专属再降级（叠加在全局之上）

| 全局档位 | Reader 实际档位 |
|---|---|
| `high` | `medium`（无 BackdropFilter） |
| `medium` | `low` |
| `low` | `low` |

**理由**：EPUB 渲染 (InAppWebView) 自身合成成本高，再叠 BackdropFilter 会双层 GPU 合成，即使 iPhone 15 Pro 长章节滚动也可能掉到 50fps。降一级后视觉差异肉眼几乎不可见（工具栏临时显示），帧率稳定。

### 6.4 各档位视觉差异

| 行为 | high | medium | low |
|---|---|---|---|
| 背景模糊 | ✅ | ❌ | ❌ |
| 边缘高光 | ✅ | ✅ | ✅ |
| Morph Press | ✅ | ✅ | ❌ |
| Tab Collapse | ✅ | ✅ | ❌ |
| Scroll Edge Fade | ✅ | ✅ | ❌ |
| Squircle 圆角 | ✅ | ✅ | ✅ |

### 6.5 Settings 暴露开关

路径：`Settings > 阅读体验 > 视觉质量`

- 🔘 自动（推荐）
- 🔘 完整玻璃
- 🔘 平衡（关闭模糊）
- 🔘 省电（关闭动效）

说明文字："在阅读页会自动降低一档以保证翻页流畅。"

---

## 7. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| BackdropFilter 在 Android 8/9 严重掉帧 | 中低端机不可用 | 自动判定降到 `low`，最低档位永远有视觉表现 |
| InAppWebView 上叠玻璃透色异常 | Reader 工具栏穿帮 | Reader 强制降一级；异常时回退不透明 tint |
| 暖色卡片透过玻璃发黄 | Library/Desk 浑浊 | Tint 严格中性白/黑；视觉验收专门检查 |
| Squircle 与 iOS 原生像素级差异 | 强迫症用户能发现 | 接受，`ContinuousRectangleBorder` 是 Flutter 上限 |
| Tab Collapse 快速滚动抖动 | 体验割裂 | 200ms debounce + 60px 最小触发距离 |
| SF Pro 在 Android fallback | 跨平台字重不一致 | 用 Roboto Flex 对齐字重梯度，接受字形差异 |
| 玻璃对比度不达 WCAG AA | 弱视用户难读 | 系统"增加对比度"时 tint alpha +0.2；提供"高对比模式" |

---

## 8. 迁移路径（四步，每步可独立交付）

### Step 1 — 基础设施（无视觉变化，~1 天）

- 新建 `theme/liquid_glass/` + `glass_tokens.dart` + `glass_surface.dart`
- 新建 `performance_mode.dart` + Riverpod provider + 启动探测
- Settings 加"视觉质量"开关（UI only）
- ✔️ 验收：debug 控制台打印当前档位；demo 页渲染基础玻璃

### Step 2 — Chrome 玻璃化（~2 天）

- `GlassTabBar`（含 Collapse）替换底部导航
- `GlassAppBar`（含 Scroll Edge）替换四个 tab 页
- 全局 Dialog / BottomSheet / SnackBar / PopupMenu 主题
- 字体切换 SF Pro / Roboto Flex
- ✔️ 验收：四个 tab 顶部和底部呈玻璃；向下滚动 tab bar 收缩成胶囊

### Step 3 — 按钮 & 二级面板（~2 天）

- `anx_button` / `anx_dropdown_button` / `anx_segmented_button` 新增 `glass` 变体
- Library 筛选 chip、Settings grouped list、Reader 目录抽屉切换
- Morph Press 接入所有按钮
- ✔️ 验收：按钮按下有形变 + 触觉反馈；Settings 看起来像 iOS 26 原生

### Step 4 — Reader 整合 & 性能验证（~2 天）

- Reader 工具栏切换玻璃 + 接入降级规则
- 三档机型真机测试翻页帧率
- 视觉走查 + 可访问性走查
- ✔️ 验收：见 §9

**总工作量**：约 7 个工作日（不含真机测试时间）。

---

## 9. 验收标准

### 9.1 视觉验收

- [ ] iOS / macOS：与 iOS 26 系统应用并排截图，玻璃质感无明显差距
- [ ] Android 高端机：玻璃效果完整呈现，无掉色/穿帮
- [ ] Android 中端机：自动落到 medium 档，无 BackdropFilter
- [ ] 浅色 / 深色模式分别走查四个 tab
- [ ] 暖色卡片透过玻璃色相正常（不发黄、不浑浊）

### 9.2 性能验收（Flutter DevTools Performance）

- [ ] 全局 60fps：四个 tab 滚动 + tab bar 收缩动画
- [ ] Reader 翻页 60fps：iPhone 13 / Pixel 7 / 一台 4GB RAM Android 各测
- [ ] 启动时间增加 < +50ms
- [ ] 内存峰值增加 < +30MB

### 9.3 可访问性验收

- [ ] 系统"降低透明度"开启 → 全部走 low 档
- [ ] 系统"增加对比度"开启 → tint alpha 自动加深
- [ ] VoiceOver / TalkBack 可正常读出所有玻璃按钮

### 9.4 回滚预案

- Step 4 性能不达标：保留 Step 1-3，Reader 整体走 low 档
- 整体方案有大问题：删 `theme/liquid_glass/` + revert button/chip 的 `style` 默认值，回到 FlexColorScheme 状态

---

## 10. 与现有设计文档的关系

本 spec 是对 `docs/superpowers/specs/2026-03-22-ambient-ai-reading-design.md` §9（UI Style）的视觉系统升级，**不修改其内容布局、AI 嵌入位置、companion 行为等任何已确定的产品决策**。原 spec 的"soft rounded cards, pastel backgrounds, warm typography"在本 spec 中作为**内容层**保留；新增的玻璃材质仅作用于**操控层**。

实施完成后需要更新：
- `docs/superpowers/PROGRESS.md`：新增"Liquid Glass UI"条目
- `CLAUDE.md`：App Design Principles 第 3 条补充"chrome 用玻璃，content 用暖卡"分层原则

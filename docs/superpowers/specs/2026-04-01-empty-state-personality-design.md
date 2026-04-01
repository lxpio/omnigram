# Empty State Personality Adaptation Design

> **Date:** 2026-04-01
> **Status:** Approved
> **Scope:** 4 pages (Desk, Library, Insights, Companion Panel) empty states adapt to companion warmth

---

## 1. Overview

Transform static empty states across the app into personality-aware experiences. Empty state copy and visuals adapt based on the companion's `warmth` slider value (0-100), split into three tiers.

**Design philosophy:** The visual expressiveness itself is the personality — warm companions get animated illustrations, neutral gets static illustrations, concise gets minimal icons. The medium is the message.

---

## 2. Core Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Languages | All 16 (full L10n) | One-time effort, complete coverage |
| Warmth tiers | 3: low (≤33) / mid (34-66) / high (≥67) | Enough variation without combinatorial explosion |
| Visual style |递减: Lottie → SVG → Icon | Expressiveness gradient matches personality |
| Illustration source | AI-generated SVG + code animation | **Placeholder — replaceable with professional assets** |
| Architecture | External strategy factory | EmptyState component stays generic |
| No-AI fallback | Default to Mid tier | Neutral tone as safe default |

---

## 3. Architecture

### 3.1 Data Flow

```
CompanionPersonality (warmth: 0-100)
        ↓
  WarmthTier.fromWarmth(warmth)  →  low / mid / high
        ↓
  emptyStateConfigProvider(pageType)  →  EmptyStateData (data class)
        ↓
  Returns: { message: String, visualType: VisualType, actionLabel?: String }
        ↓
  UI layer builds: EmptyState(message:, visual: buildVisual(visualType), ...)
```

### 3.2 New Components

**`WarmthTier` enum** (`lib/models/warmth_tier.dart`)
- Values: `low`, `mid`, `high`
- Factory: `WarmthTier.fromWarmth(int warmth)` — ≤33 → low, 34-66 → mid, ≥67 → high
- Default (no companion configured): `mid`

**`EmptyStateData` data class** (`lib/models/empty_state_data.dart`)
- Fields: `String message`, `EmptyVisualType visualType`, `String? actionLabel`
- `EmptyVisualType` enum: `lottie(assetPath)`, `svg(assetPath)`, `icon(iconData)`
- Pure data — no Widget references. UI layer builds widgets from this.

**`EmptyStateConfig`** (`lib/widgets/common/empty_state_config.dart`)
- Factory class: `EmptyStateConfig.forPage(EmptyPageType, WarmthTier, L10n)` → returns `EmptyStateData`
- `EmptyPageType` enum: `desk`, `library`, `insights`, `companion`

**`emptyStateConfigProvider`** (`lib/providers/empty_state_provider.dart`)
- Riverpod family provider: `emptyStateConfigProvider(EmptyPageType)` → returns `EmptyStateData`
- Reads `companionProvider` → extracts warmth → derives tier → delegates to `EmptyStateConfig`
- Auto-refreshes when personality changes

### 3.3 EmptyState Widget Change

Current:
```dart
EmptyState({
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  IconData? icon,          // ← icon only
})
```

New:
```dart
EmptyState({
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Widget? visual,          // ← any widget: Icon, SVG, Lottie
})
```

**Breaking change:** `icon` parameter is removed, replaced by `visual`. This is NOT backward compatible.

Migration required (4 call sites):

| File | Current | New |
|------|---------|-----|
| `page/home/desk_page.dart:55` | `icon: Icons.auto_stories_outlined` | Replaced by `emptyStateConfigProvider` |
| `page/home/library_page.dart:31` | `icon: Icons.library_books_outlined` | Replaced by `emptyStateConfigProvider` |
| `page/home/insights_page.dart:76` | `icon: Icons.insights_outlined` | Replaced by `emptyStateConfigProvider` |
| `widgets/reader/companion_panel.dart:271` | Independent `_buildEmptyState` | Unified to shared `EmptyState` component |

### 3.4 Companion Panel Unification

`companion_panel.dart` currently has an independent `_buildEmptyState` method (Column + Icon + Text) that does NOT use the shared `EmptyState` widget. This implementation will be unified to use the shared component, ensuring consistent personality adaptation.

Note: Companion panel is a reader sub-component. L10n context is available via standard `L10n.of(context)` — no special handling needed.

### 3.5 Companion Panel First-Person Voice

The companion panel High tier copy intentionally uses first-person ("I'm here!") because it represents the companion speaking directly. Other pages use impersonal voice. This is a deliberate narrative choice, not an inconsistency.

### 3.6 Lottie Animation Lifecycle

`EmptyState` remains a `StatelessWidget`. Lottie animations use `Lottie.asset()` with its built-in self-managing controller (auto-dispose on widget removal). No `StatefulWidget` or `AnimationController` management needed.

---

## 4. Copy (Chinese / English examples)

### 4.1 Reading Desk

| Tier | CN | EN |
|------|----|----|
| High | 书桌在等你呢！去书架挑一本，今天的阅读从这里开始。 | Your desk is waiting! Pick something from the shelf — today's reading starts here. |
| Mid | 还没有在读的书。去书架选一本开始吧。 | No books in progress. Head to the bookshelf to start one. |
| Low | 暂无在读书籍。 | No books in progress. |

### 4.2 Library / Bookshelf

| Tier | CN | EN |
|------|----|----|
| High | 空空的书架，无限的可能！导入你的第一本书，开启阅读旅程。 | An empty shelf, endless possibilities! Import your first book to begin. |
| Mid | 书架是空的。导入书籍开始阅读。 | Your bookshelf is empty. Import books to get started. |
| Low | 暂无书籍。 | No books yet. |

### 4.3 Insights

| Tier | CN | EN |
|------|----|----|
| High | 这里还是一张白纸，但每座图书馆都从第一本书开始。你的洞察会随阅读慢慢生长。 | A blank page for now, but every great library starts with one book. Your insights will grow as you read. |
| Mid | 开始阅读并添加笔记后，洞察会在这里出现。 | Insights will appear here once you start reading and taking notes. |
| Low | 暂无阅读数据。 | No reading data yet. |

### 4.4 Companion Panel

| Tier | CN | EN |
|------|----|----|
| High | 我在这里！选段文字或者直接问我，聊聊这本书的任何想法。 | I'm here! Select some text or just ask — let's talk about anything in this book. |
| Mid | 选中文字或输入问题，开始对话。 | Select text or type a question to start. |
| Low | 输入问题开始。 | Type to begin. |

> **L10n scope:** 12 message keys x 16 languages = 192 translations.
> Action labels reuse existing L10n keys where available (e.g., `navBarBookshelf`, existing import labels).
> Key naming (camelCase, matching project convention): `emptyStateDeskHigh`, `emptyStateDeskMid`, `emptyStateDeskLow`, etc.
>
> **Hardcoded Chinese cleanup:** This work also migrates existing hardcoded Chinese empty state strings in `desk_page.dart`, `library_page.dart`, and `insights_page.dart` to L10n (addresses KI-2 partially).

---

## 5. Visual Resources

### 5.1 Tier-to-Visual Mapping

| Tier | Type | Assets | Style |
|------|------|--------|-------|
| High | Lottie animation | 4 files | AI-generated SVG wrapped with code animation (scale, fade, gentle loop) |
| Mid | SVG static illustration | 4 files | Same line-art series, no animation |
| Low | Material Icon | 0 new assets | Existing icons: `auto_stories_outlined`, `library_books_outlined`, `insights_outlined`, `chat_bubble_outline` |

### 5.2 Asset Path

```
assets/img/empty_states/
├── desk_high.json       # Lottie
├── desk_mid.svg         # SVG
├── library_high.json
├── library_mid.svg
├── insights_high.json
├── insights_mid.svg
├── companion_high.json
├── companion_mid.svg
```

Register in `pubspec.yaml` under `flutter.assets`:
```yaml
- assets/img/empty_states/
```

### 5.3 Illustration Themes

| Page | Visual concept |
|------|---------------|
| Desk | Open book on a desk with a reading lamp |
| Library | Empty bookshelf with soft light |
| Insights | Sprouting plant / seedling (growth metaphor) |
| Companion | Speech bubble with gentle wave |

### 5.4 Placeholder Notice

> **Current illustrations are AI-generated placeholders.** They are functional and styled to match Omnigram's soft/pastel aesthetic, but can be replaced with professional illustrations or LottieFiles assets in the future. The `EmptyStateConfig` factory abstracts the visual source — swapping assets requires no code changes beyond the asset files themselves.

---

## 6. Degradation & Edge Cases

| Scenario | Behavior |
|----------|----------|
| No companion configured | Default to Mid tier |
| AI service unavailable | No effect — empty states are local-only, no AI dependency |
| Warmth boundary values | ≤33 → low, 34-66 → mid, ≥67 → high |
| Companion panel without AI | Still shows personality-adapted empty state; quick prompts hidden if no AI |
| Asset loading failure (Lottie/SVG) | Fallback to Material Icon (Low tier visual) |

---

## 7. Dependencies

**New packages (not currently in pubspec.yaml):**
- `lottie` — Lottie animation rendering (~200KB). Required for High tier visuals.
- `flutter_svg` — SVG rendering (~150KB). Required for Mid tier visuals.

**Existing:**
- `companionProvider` for warmth value
- `EmptyState` widget (to be modified)
- L10n ARB infrastructure (16 languages)

---

## 8. Testing Strategy

| Test | Scope | Priority |
|------|-------|----------|
| `WarmthTier.fromWarmth()` boundary values | Unit: 0, 33, 34, 66, 67, 100 | P0 |
| `EmptyStateConfig.forPage()` combinations | Unit: 3 tiers × 4 pages = 12 cases | P0 |
| Provider integration | Widget test: warmth change → empty state content refresh | P1 |
| Asset fallback | Unit: Lottie/SVG load failure → Icon fallback | P1 |

---

## 9. Out of Scope

- Stealth library empty state (depends on stealth library feature, Layer 5)
- Action button text personalization (only message and visual adapt; action labels stay functional)
- Companion name interpolation in messages (kept simple — no `{name} says...` patterns)

# Empty State Personality Adaptation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make empty states across 4 pages adapt their copy and visuals to the companion's warmth setting (3 tiers).

**Architecture:** External strategy factory (`EmptyStateConfig`) maps `(page, warmthTier)` → data class. Provider derives tier from `companionProvider`. `EmptyState` widget accepts `Widget? visual` instead of `IconData? icon`. Visuals degrade from Lottie (high) → SVG (mid) → Icon (low).

**Tech Stack:** Flutter, Riverpod, lottie package, flutter_svg package, L10n (16 ARB files)

**Spec:** `docs/superpowers/specs/2026-04-01-empty-state-personality-design.md`

---

### Task 1: Add dependencies (lottie + flutter_svg)

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: Add packages**

In `app/pubspec.yaml`, add under `dependencies:`:

```yaml
  lottie: ^3.3.1
  flutter_svg: ^2.0.17
```

- [ ] **Step 2: Install**

Run: `cd app && flutter pub get`
Expected: exit code 0, packages resolved

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock
git commit -m "deps: add lottie and flutter_svg for empty state visuals"
```

---

### Task 2: WarmthTier enum + EmptyStateData model

**Files:**
- Create: `app/lib/models/warmth_tier.dart`
- Create: `app/lib/models/empty_state_data.dart`
- Create: `app/test/models/warmth_tier_test.dart`

- [ ] **Step 1: Write WarmthTier boundary tests**

```dart
// app/test/models/warmth_tier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/warmth_tier.dart';

void main() {
  group('WarmthTier.fromWarmth', () {
    test('0 → low', () => expect(WarmthTier.fromWarmth(0), WarmthTier.low));
    test('33 → low', () => expect(WarmthTier.fromWarmth(33), WarmthTier.low));
    test('34 → mid', () => expect(WarmthTier.fromWarmth(34), WarmthTier.mid));
    test('50 → mid', () => expect(WarmthTier.fromWarmth(50), WarmthTier.mid));
    test('66 → mid', () => expect(WarmthTier.fromWarmth(66), WarmthTier.mid));
    test('67 → high', () => expect(WarmthTier.fromWarmth(67), WarmthTier.high));
    test('100 → high', () => expect(WarmthTier.fromWarmth(100), WarmthTier.high));
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/models/warmth_tier_test.dart`
Expected: FAIL — `warmth_tier.dart` doesn't exist

- [ ] **Step 3: Implement WarmthTier**

```dart
// app/lib/models/warmth_tier.dart
enum WarmthTier {
  low,
  mid,
  high;

  static WarmthTier fromWarmth(int warmth) {
    if (warmth <= 33) return WarmthTier.low;
    if (warmth <= 66) return WarmthTier.mid;
    return WarmthTier.high;
  }
}
```

- [ ] **Step 4: Implement EmptyStateData**

```dart
// app/lib/models/empty_state_data.dart
import 'package:flutter/material.dart';

enum EmptyPageType { desk, library, insights, companion }

sealed class EmptyVisualType {
  const EmptyVisualType();
}

class EmptyVisualLottie extends EmptyVisualType {
  final String assetPath;
  const EmptyVisualLottie(this.assetPath);
}

class EmptyVisualSvg extends EmptyVisualType {
  final String assetPath;
  const EmptyVisualSvg(this.assetPath);
}

class EmptyVisualIcon extends EmptyVisualType {
  final IconData iconData;
  const EmptyVisualIcon(this.iconData);
}

class EmptyStateData {
  final String message;
  final EmptyVisualType visualType;
  final String? actionLabel;

  const EmptyStateData({
    required this.message,
    required this.visualType,
    this.actionLabel,
  });
}
```

- [ ] **Step 5: Run tests — expect PASS**

Run: `cd app && flutter test test/models/warmth_tier_test.dart`
Expected: All 7 tests PASS

- [ ] **Step 6: Commit**

```bash
git add app/lib/models/warmth_tier.dart app/lib/models/empty_state_data.dart app/test/models/warmth_tier_test.dart
git commit -m "feat: add WarmthTier enum and EmptyStateData model"
```

---

### Task 3: EmptyStateConfig factory

**Files:**
- Create: `app/lib/widgets/common/empty_state_config.dart`
- Create: `app/test/widgets/common/empty_state_config_test.dart`

- [ ] **Step 1: Write factory tests**

```dart
// app/test/widgets/common/empty_state_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

void main() {
  // Use a testWidgets wrapper to get L10n from context
  for (final page in EmptyPageType.values) {
    for (final tier in WarmthTier.values) {
      testWidgets('$page × $tier returns valid EmptyStateData', (tester) async {
        late EmptyStateData data;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: const Locale('en'),
            home: Builder(builder: (context) {
              data = EmptyStateConfig.forPage(page, tier, L10n.of(context));
              return const SizedBox();
            }),
          ),
        );
        await tester.pumpAndSettle();

        expect(data.message, isNotEmpty);
        expect(data.visualType, isNotNull);
      });
    }
  }

  testWidgets('high tier uses Lottie visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.high, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(data.visualType, isA<EmptyVisualLottie>());
  });

  testWidgets('mid tier uses SVG visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.mid, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(data.visualType, isA<EmptyVisualSvg>());
  });

  testWidgets('low tier uses Icon visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.low, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(data.visualType, isA<EmptyVisualIcon>());
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/widgets/common/empty_state_config_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 3: Implement EmptyStateConfig**

```dart
// app/lib/widgets/common/empty_state_config.dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';

class EmptyStateConfig {
  static EmptyStateData forPage(EmptyPageType page, WarmthTier tier, L10n l10n) {
    return EmptyStateData(
      message: _message(page, tier, l10n),
      visualType: _visual(page, tier),
      actionLabel: _actionLabel(page, l10n),
    );
  }

  static String _message(EmptyPageType page, WarmthTier tier, L10n l10n) {
    return switch ((page, tier)) {
      (EmptyPageType.desk, WarmthTier.high) => l10n.emptyStateDeskHigh,
      (EmptyPageType.desk, WarmthTier.mid) => l10n.emptyStateDeskMid,
      (EmptyPageType.desk, WarmthTier.low) => l10n.emptyStateDeskLow,
      (EmptyPageType.library, WarmthTier.high) => l10n.emptyStateLibraryHigh,
      (EmptyPageType.library, WarmthTier.mid) => l10n.emptyStateLibraryMid,
      (EmptyPageType.library, WarmthTier.low) => l10n.emptyStateLibraryLow,
      (EmptyPageType.insights, WarmthTier.high) => l10n.emptyStateInsightsHigh,
      (EmptyPageType.insights, WarmthTier.mid) => l10n.emptyStateInsightsMid,
      (EmptyPageType.insights, WarmthTier.low) => l10n.emptyStateInsightsLow,
      (EmptyPageType.companion, WarmthTier.high) => l10n.emptyStateCompanionHigh,
      (EmptyPageType.companion, WarmthTier.mid) => l10n.emptyStateCompanionMid,
      (EmptyPageType.companion, WarmthTier.low) => l10n.emptyStateCompanionLow,
    };
  }

  static EmptyVisualType _visual(EmptyPageType page, WarmthTier tier) {
    return switch (tier) {
      WarmthTier.high => EmptyVisualLottie('assets/img/empty_states/${page.name}_high.json'),
      WarmthTier.mid => EmptyVisualSvg('assets/img/empty_states/${page.name}_mid.svg'),
      WarmthTier.low => EmptyVisualIcon(_iconForPage(page)),
    };
  }

  static String? _actionLabel(EmptyPageType page, L10n l10n) {
    return switch (page) {
      EmptyPageType.desk => l10n.navBarBookshelf,
      EmptyPageType.library => l10n.emptyStateLibraryAction,
      _ => null,
    };
  }

  static IconData _iconForPage(EmptyPageType page) {
    return switch (page) {
      EmptyPageType.desk => Icons.auto_stories_outlined,
      EmptyPageType.library => Icons.library_books_outlined,
      EmptyPageType.insights => Icons.insights_outlined,
      EmptyPageType.companion => Icons.chat_bubble_outline,
    };
  }
}
```

- [ ] **Step 4: Run tests — expect FAIL (L10n keys not yet added)**

Run: `cd app && flutter test test/widgets/common/empty_state_config_test.dart`
Expected: FAIL — L10n keys don't exist yet. This is expected; they'll be added in Task 5.

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/common/empty_state_config.dart app/test/widgets/common/empty_state_config_test.dart
git commit -m "feat: add EmptyStateConfig factory (L10n keys pending)"
```

---

### Task 4: L10n — add 12 keys to all 16 ARB files

**Files:**
- Modify: all 16 `app/lib/l10n/app_*.arb` files

This task adds 13 L10n keys (12 empty state messages + 1 action label) to all 16 ARB files. After adding, regenerate.

- [ ] **Step 1: Add keys to app_en.arb**

Add these entries to `app/lib/l10n/app_en.arb` (before the closing `}`):

```json
  "emptyStateDeskHigh": "Your desk is waiting! Pick something from the shelf — today's reading starts here.",
  "emptyStateDeskMid": "No books in progress. Head to the bookshelf to start one.",
  "emptyStateDeskLow": "No books in progress.",
  "emptyStateLibraryHigh": "An empty shelf, endless possibilities! Import your first book to begin.",
  "emptyStateLibraryMid": "Your bookshelf is empty. Import books to get started.",
  "emptyStateLibraryLow": "No books yet.",
  "emptyStateLibraryAction": "Import Books",
  "emptyStateInsightsHigh": "A blank page for now, but every great library starts with one book. Your insights will grow as you read.",
  "emptyStateInsightsMid": "Insights will appear here once you start reading and taking notes.",
  "emptyStateInsightsLow": "No reading data yet.",
  "emptyStateCompanionHigh": "I'm here! Select some text or just ask — let's talk about anything in this book.",
  "emptyStateCompanionMid": "Select text or type a question to start.",
  "emptyStateCompanionLow": "Type to begin."
```

- [ ] **Step 2: Add keys to app_zh-CN.arb**

```json
  "emptyStateDeskHigh": "书桌在等你呢！去书架挑一本，今天的阅读从这里开始。",
  "emptyStateDeskMid": "还没有在读的书。去书架选一本开始吧。",
  "emptyStateDeskLow": "暂无在读书籍。",
  "emptyStateLibraryHigh": "空空的书架，无限的可能！导入你的第一本书，开启阅读旅程。",
  "emptyStateLibraryMid": "书架是空的。导入书籍开始阅读。",
  "emptyStateLibraryLow": "暂无书籍。",
  "emptyStateLibraryAction": "导入书籍",
  "emptyStateInsightsHigh": "这里还是一张白纸，但每座图书馆都从第一本书开始。你的洞察会随阅读慢慢生长。",
  "emptyStateInsightsMid": "开始阅读并添加笔记后，洞察会在这里出现。",
  "emptyStateInsightsLow": "暂无阅读数据。",
  "emptyStateCompanionHigh": "我在这里！选段文字或者直接问我，聊聊这本书的任何想法。",
  "emptyStateCompanionMid": "选中文字或输入问题，开始对话。",
  "emptyStateCompanionLow": "输入问题开始。"
```

- [ ] **Step 3: Add keys to remaining 14 ARB files**

Add the same 13 keys to each of: `app_zh-TW.arb`, `app_zh.arb`, `app_zh-LZH.arb`, `app_fr.arb`, `app_de.arb`, `app_it.arb`, `app_es.arb`, `app_pt.arb`, `app_ja.arb`, `app_ko.arb`, `app_tr.arb`, `app_ru.arb`, `app_ro.arb`, `app_ar.arb`.

Translate each to the appropriate language. For `app_zh.arb` and `app_zh-TW.arb`, use Traditional Chinese variants. For `app_zh-LZH.arb`, use Classical Chinese style.

- [ ] **Step 4: Regenerate L10n**

Run: `cd app && flutter gen-l10n`
Expected: exit code 0, files generated in `lib/l10n/generated/`

- [ ] **Step 5: Verify EmptyStateConfig tests now pass**

Run: `cd app && flutter test test/widgets/common/empty_state_config_test.dart`
Expected: All 15 tests PASS (12 combination tests + 3 visual type tests)

- [ ] **Step 6: Commit**

```bash
git add app/lib/l10n/
git commit -m "l10n: add empty state personality strings for 16 languages"
```

---

### Task 5: Generate SVG + Lottie placeholder assets

**Files:**
- Create: `app/assets/img/empty_states/` directory (8 files)
- Modify: `app/pubspec.yaml` (assets registration)

- [ ] **Step 1: Create asset directory**

Run: `mkdir -p app/assets/img/empty_states`

- [ ] **Step 2: Generate 4 SVG illustrations (mid tier)**

Create AI-generated SVG line art for each page. Style: soft rounded lines, pastel colors matching Omnigram theme (pink/green/lavender palette). Size: 200x200 viewBox.

Files to create:
- `app/assets/img/empty_states/desk_mid.svg` — open book on desk with reading lamp
- `app/assets/img/empty_states/library_mid.svg` — empty bookshelf with soft light
- `app/assets/img/empty_states/insights_mid.svg` — sprouting seedling (growth metaphor)
- `app/assets/img/empty_states/companion_mid.svg` — speech bubble with gentle wave

- [ ] **Step 3: Generate 4 Lottie JSON files (high tier)**

Create simple Lottie JSON animations wrapping the SVG concepts with gentle motion:
- `app/assets/img/empty_states/desk_high.json` — book pages turning gently
- `app/assets/img/empty_states/library_high.json` — soft light pulsing on shelf
- `app/assets/img/empty_states/insights_high.json` — seedling growing upward
- `app/assets/img/empty_states/companion_high.json` — speech bubble with floating dots

Lottie files should be small (<50KB each) and loop seamlessly.

- [ ] **Step 4: Register assets in pubspec.yaml**

Add to `app/pubspec.yaml` under `flutter.assets:`:

```yaml
    - assets/img/empty_states/
```

- [ ] **Step 5: Verify assets load**

Run: `cd app && flutter pub get`
Expected: exit code 0

- [ ] **Step 6: Commit**

```bash
git add app/assets/img/empty_states/ app/pubspec.yaml
git commit -m "assets: add placeholder SVG and Lottie for empty state visuals"
```

---

### Task 6: Modify EmptyState widget (icon → visual)

**Files:**
- Modify: `app/lib/widgets/common/empty_state.dart`

- [ ] **Step 1: Update EmptyState widget**

Replace the full content of `app/lib/widgets/common/empty_state.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/theme/typography.dart';

/// Reusable empty state — personality-adapted text and visuals.
/// Used across Desk, Bookshelf, Insights, Companion.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? visual;

  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.visual,
  });

  /// Build from EmptyStateData (returned by EmptyStateConfig).
  factory EmptyState.fromData(
    EmptyStateData data, {
    Key? key,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      message: data.message,
      actionLabel: data.actionLabel,
      onAction: onAction,
      visual: _buildVisual(data.visualType),
    );
  }

  static Widget _buildVisual(EmptyVisualType type) {
    return switch (type) {
      EmptyVisualLottie(:final assetPath) => Lottie.asset(
          assetPath,
          width: 160,
          height: 160,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      EmptyVisualSvg(:final assetPath) => SvgPicture.asset(
          assetPath,
          width: 120,
          height: 120,
          placeholderBuilder: (_) => const SizedBox.shrink(),
        ),
      EmptyVisualIcon(:final iconData) => Icon(iconData, size: 64),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (visual != null) ...[
              IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.outlineVariant),
                child: visual!,
              ),
              const SizedBox(height: 16),
            ],
            Text(message, style: OmnigramTypography.bodyLarge(context), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyze passes**

Run: `cd app && flutter analyze lib/widgets/common/empty_state.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/common/empty_state.dart
git commit -m "refactor: EmptyState widget accepts Widget visual instead of IconData"
```

---

### Task 7: Riverpod provider for empty state config

**Files:**
- Create: `app/lib/providers/empty_state_provider.dart`

- [ ] **Step 1: Create provider**

```dart
// app/lib/providers/empty_state_provider.dart
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';

part 'empty_state_provider.g.dart';

@riverpod
WarmthTier warmthTier(Ref ref) {
  final warmth = ref.watch(companionProvider).warmth;
  return WarmthTier.fromWarmth(warmth);
}

/// Returns EmptyStateData for a given page.
/// Call with context to access L10n: `emptyStateData(context, EmptyPageType.desk)`
EmptyStateData emptyStateData(BuildContext context, WarmthTier tier, EmptyPageType page) {
  return EmptyStateConfig.forPage(page, tier, L10n.of(context));
}
```

- [ ] **Step 2: Run codegen**

Run: `cd app && dart run build_runner build --delete-conflicting-outputs`
Expected: `empty_state_provider.g.dart` generated

- [ ] **Step 3: Verify analyze**

Run: `cd app && flutter analyze lib/providers/empty_state_provider.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add app/lib/providers/empty_state_provider.dart app/lib/providers/empty_state_provider.g.dart
git commit -m "feat: add warmthTier provider and emptyStateData helper"
```

---

### Task 8: Migrate desk_page.dart

**Files:**
- Modify: `app/lib/page/home/desk_page.dart`

- [ ] **Step 1: Update empty state usage**

In `desk_page.dart`, replace the current EmptyState call (around line 55):

```dart
// OLD:
return const EmptyState(
  message: '书桌还是空的，去书架找一本书开始阅读吧。',
  actionLabel: '去书架',
  icon: Icons.auto_stories_outlined,
);
```

With:

```dart
// NEW:
final tier = ref.watch(warmthTierProvider);
final data = emptyStateData(context, tier, EmptyPageType.desk);
return EmptyState.fromData(data, onAction: () {
  // Navigate to bookshelf tab
  // (preserve existing navigation logic if any)
});
```

Add imports at top:
```dart
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/page/home/desk_page.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/home/desk_page.dart
git commit -m "feat: desk page empty state adapts to companion warmth"
```

---

### Task 9: Migrate library_page.dart

**Files:**
- Modify: `app/lib/page/home/library_page.dart`

- [ ] **Step 1: Update empty state usage**

In `library_page.dart`, replace the current EmptyState call (around line 31):

```dart
// OLD:
return EmptyState(
  message: '你的书架还是空的，导入第一本书开始阅读吧。',
  actionLabel: '导入书籍',
  icon: Icons.library_books_outlined,
  onAction: () => _importBooks(context, ref),
);
```

With:

```dart
// NEW:
final tier = ref.watch(warmthTierProvider);
final data = emptyStateData(context, tier, EmptyPageType.library);
return EmptyState.fromData(data, onAction: () => _importBooks(context, ref));
```

Add imports at top:
```dart
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/page/home/library_page.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/home/library_page.dart
git commit -m "feat: library page empty state adapts to companion warmth"
```

---

### Task 10: Migrate insights_page.dart

**Files:**
- Modify: `app/lib/page/home/insights_page.dart`

- [ ] **Step 1: Update empty state usage**

In `insights_page.dart`, replace the current EmptyState call (around line 76):

```dart
// OLD:
return const EmptyState(
  message: '开始阅读并添加笔记，洞察会随着你的阅读逐渐丰富。',
  icon: Icons.insights_outlined,
);
```

With:

```dart
// NEW:
final tier = ref.watch(warmthTierProvider);
final data = emptyStateData(context, tier, EmptyPageType.insights);
return EmptyState.fromData(data);
```

Add imports at top:
```dart
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/page/home/insights_page.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/home/insights_page.dart
git commit -m "feat: insights page empty state adapts to companion warmth"
```

---

### Task 11: Migrate companion_panel.dart

**Files:**
- Modify: `app/lib/widgets/reader/companion_panel.dart`

- [ ] **Step 1: Replace custom _buildEmptyState with shared component**

In `companion_panel.dart`, find the `_buildEmptyState` method (around line 271) and replace it to use the shared `EmptyState.fromData`:

```dart
// Replace the custom _buildEmptyState method body with:
Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
  final tier = ref.watch(warmthTierProvider);
  final data = emptyStateData(context, tier, EmptyPageType.companion);
  return EmptyState.fromData(data);
}
```

Add imports at top:
```dart
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
```

Note: The companion panel currently also shows quick-prompt chips below the empty state. Keep those chips — they should appear below the `EmptyState.fromData()` widget. The integration point is where `_buildEmptyState` is called; wrap it in a Column with the existing chip row if needed.

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/widgets/reader/companion_panel.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/reader/companion_panel.dart
git commit -m "feat: companion panel empty state unified to shared EmptyState component"
```

---

### Task 12: Final verification

**Files:** None (verification only)

- [ ] **Step 1: Run all tests**

Run: `cd app && flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run full analyze**

Run: `cd app && flutter analyze lib/`
Expected: No errors

- [ ] **Step 3: Run EmptyStateConfig tests specifically**

Run: `cd app && flutter test test/widgets/common/empty_state_config_test.dart test/models/warmth_tier_test.dart`
Expected: All tests PASS

- [ ] **Step 4: Update PROGRESS.md**

In `docs/superpowers/PROGRESS.md`, update the empty state line:

```markdown
| 空状态受伴侣性格影响 | §10.5 | ✅ | `widgets/common/empty_state_config.dart`, `models/warmth_tier.dart` | <commit-hash> |
```

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark empty state personality adaptation as complete"
```

# Sprint 1: Foundation + Core Reading Loop — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a beautiful, fully functional Omnigram reader with new 4-tab navigation (Reading Desk, Bookshelf, Insights skeleton, Settings) — no AI features, just a clean reading experience that establishes the new design language.

**Architecture:** UI layer rewrite on top of existing Anx Reader logic. Keep all models, DAOs, providers, services, EPUB engine. Replace all pages, navigation, and widgets with new design system. The app must work end-to-end: import a book → see it on desk → read it → see basic stats.

**Tech Stack:** Flutter 3.41 / Dart 3.11 / Riverpod v2 (code gen) / sqflite / InAppWebView (Foliate.js) / FlexColorScheme

**Spec:** `docs/superpowers/specs/2026-03-22-ambient-ai-reading-design.md` (Sections 2-4, 6-7, 9-11)

**UI Reference:** `docs/discussions/ui1.png`, `docs/discussions/ui2.png` — soft rounded cards, pastel backgrounds, warm typography

---

## File Structure

### New files to create

```
app/lib/
├── theme/
│   ├── omnigram_theme.dart          # ThemeData builder with Omnigram design tokens
│   ├── colors.dart                  # Pastel color palette + semantic tokens
│   └── typography.dart              # Text style hierarchy (headings, body, caption)
├── page/
│   ├── omnigram_home.dart           # New 4-tab home with responsive layout
│   ├── home/
│   │   ├── desk_page.dart           # Reading Desk — "The Desk" (§3)
│   │   ├── library_page.dart        # Bookshelf — "The Library" (§4)
│   │   ├── insights_page.dart       # Insights skeleton (§6, no AI)
│   │   └── settings_page.dart       # Settings framework (§7)
│   └── reader/
│       └── immersive_reader.dart    # Full-screen reader wrapper (§5)
├── widgets/
│   ├── common/
│   │   ├── omnigram_card.dart       # Soft rounded card (base design component)
│   │   └── empty_state.dart         # Reusable empty state widget
│   ├── desk/
│   │   ├── hero_book_card.dart      # Currently reading book — large card
│   │   ├── also_reading_shelf.dart  # Horizontal scroll of in-progress books
│   │   └── greeting_header.dart     # Personalized greeting
│   ├── library/
│   │   ├── book_grid_item.dart      # Book card for grid display
│   │   ├── topic_section.dart       # Books grouped by tag/topic
│   │   └── import_button.dart       # Book import trigger
│   ├── insights/
│   │   ├── reading_summary_card.dart # "3 books · 42 hours · 128 notes"
│   │   ├── notes_list.dart          # Notes grouped by book
│   │   └── time_period_selector.dart # Swipeable month/year filter
│   └── reader/
│       ├── reader_app_bar.dart      # Top bar: ← Chapter ⋮ 🎧 ☾
│       ├── reader_bottom_bar.dart   # Progress bar + page number
│       └── reader_menu_sheet.dart   # Bookmarks, notes, TOC, style
```

### Existing files to modify

```
app/lib/main.dart                              # Switch to OmnigramHome, apply new theme
app/lib/l10n/app_en.arb                        # Add new UI strings
app/lib/l10n/app_zh.arb                        # Add new UI strings (Chinese)
app/lib/providers/book_list.dart               # Add "in-progress books" filter for desk
```

### Existing files to reuse (no changes)

```
app/lib/models/book.dart                       # Book data model
app/lib/models/book_note.dart                  # Highlights/notes model
app/lib/models/bookmark.dart                   # Bookmark model
app/lib/models/book_style.dart                 # Typography settings
app/lib/models/read_theme.dart                 # Reader color themes
app/lib/models/tag.dart                        # Tag model
app/lib/dao/*                                  # All database access
app/lib/providers/current_reading.dart          # Active book state
app/lib/providers/book_notes.dart              # Notes state
app/lib/service/book.dart                      # Import logic
app/lib/page/book_player/epub_player.dart      # EPUB WebView engine
app/lib/config/shared_preference_provider.dart  # Prefs singleton
app/assets/foliate-js/*                        # Reader JS bundle
```

---

## Task Dependency Graph

```
Task 1 (Theme) ──┐
                  ├── Task 3 (Desk Page)
Task 2 (Nav)  ───┤
                  ├── Task 4 (Bookshelf Page)
                  ├── Task 5 (Reader Wrapper)
                  ├── Task 6 (Insights Skeleton)
                  └── Task 7 (Settings Framework)
                                │
Task 8 (Wire Up + Integration) ─┘
```

Tasks 3-7 can run in parallel after Tasks 1-2 are complete.

---

## Task 1: Design System & Theme

**Files:**
- Create: `app/lib/theme/colors.dart`
- Create: `app/lib/theme/typography.dart`
- Create: `app/lib/theme/omnigram_theme.dart`
- Create: `app/lib/widgets/common/omnigram_card.dart`
- Create: `app/lib/widgets/common/empty_state.dart`

**Goal:** Establish Omnigram's visual language — pastel colors, soft cards, warm typography. All subsequent UI tasks build on these tokens.

- [ ] **Step 1: Create color palette**

```dart
// app/lib/theme/colors.dart
import 'package:flutter/material.dart';

/// Omnigram pastel color palette
/// Reference: docs/discussions/ui1.png, ui2.png
class OmnigramColors {
  OmnigramColors._();

  // Seed color for Material 3 dynamic scheme
  static const Color seed = Color(0xFF4A7C59); // Warm green

  // Pastel card backgrounds
  static const Color cardPink = Color(0xFFFCE4EC);
  static const Color cardGreen = Color(0xFFE8F5E9);
  static const Color cardLavender = Color(0xFFEDE7F6);
  static const Color cardPeach = Color(0xFFFFF3E0);
  static const Color cardBlue = Color(0xFFE3F2FD);

  // Surface colors
  static const Color surfaceLight = Color(0xFFF7F6F3);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // Reading-specific
  static const Color readerBgLight = Color(0xFFFBFBF3);
  static const Color readerBgDark = Color(0xFF1C1C1E);

  // Accent for interactive elements
  static const Color accent = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF66BB6A);

  /// Returns a pastel color for a given index (cycles through palette)
  static Color pastelAt(int index) {
    const pastels = [cardPink, cardGreen, cardLavender, cardPeach, cardBlue];
    return pastels[index % pastels.length];
  }
}
```

- [ ] **Step 2: Create typography system**

```dart
// app/lib/theme/typography.dart
import 'package:flutter/material.dart';

/// Omnigram typography hierarchy
/// Bold headings, warm body text, clear visual hierarchy
class OmnigramTypography {
  OmnigramTypography._();

  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}
```

- [ ] **Step 3: Create theme builder**

```dart
// app/lib/theme/omnigram_theme.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class OmnigramTheme {
  OmnigramTheme._();

  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
  static const double pageHorizontalPadding = 20.0;

  static ThemeData light() {
    return FlexThemeData.light(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.light,
        surface: OmnigramColors.surfaceLight,
      ),
      useMaterial3: true,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.dark,
        surface: OmnigramColors.surfaceDark,
      ),
      useMaterial3: true,
      darkIsTrueBlack: false,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    );
  }
}
```

- [ ] **Step 4: Create base card component**

```dart
// app/lib/widgets/common/omnigram_card.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/omnigram_theme.dart';

/// Soft rounded card — the core visual building block of Omnigram.
/// Matches reference UI: large border-radius, generous padding, optional pastel background.
class OmnigramCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;

  const OmnigramCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(OmnigramTheme.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius ?? OmnigramTheme.cardRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
```

- [ ] **Step 5: Create empty state widget**

```dart
// app/lib/widgets/common/empty_state.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Reusable empty state — warm or concise text, optional action button.
/// Used across Desk, Bookshelf, Insights, Stealth.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
            if (icon != null) const SizedBox(height: 16),
            Text(
              message,
              style: OmnigramTypography.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify theme renders correctly**

Run: `cd /Users/liuyou/Workspace/omnigram/app && flutter analyze lib/theme/ lib/widgets/common/omnigram_card.dart lib/widgets/common/empty_state.dart`
Expected: No analysis errors

- [ ] **Step 7: Commit**

```bash
git add app/lib/theme/ app/lib/widgets/common/omnigram_card.dart app/lib/widgets/common/empty_state.dart
git commit -m "feat(app): add Omnigram design system — colors, typography, theme, base components"
```

---

## Task 2: Four-Tab Navigation Framework

**Files:**
- Create: `app/lib/page/omnigram_home.dart`
- Modify: `app/lib/main.dart`

**Goal:** Replace the 5-tab Anx Reader navigation with 4-tab Omnigram navigation (Reading, Bookshelf, Insights, Settings). Responsive: bottom bar on mobile, rail on desktop.

- [ ] **Step 1: Create OmnigramHome page**

```dart
// app/lib/page/omnigram_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/home/desk_page.dart';
import 'package:omnigram/page/home/library_page.dart';
import 'package:omnigram/page/home/insights_page.dart';
import 'package:omnigram/page/home/settings_page.dart' as omnigram;

enum OmnigramTab { reading, bookshelf, insights, settings }

class OmnigramHome extends ConsumerStatefulWidget {
  const OmnigramHome({super.key});

  @override
  ConsumerState<OmnigramHome> createState() => _OmnigramHomeState();
}

class _OmnigramHomeState extends ConsumerState<OmnigramHome> {
  OmnigramTab _currentTab = OmnigramTab.reading;

  Widget _buildPage() {
    switch (_currentTab) {
      case OmnigramTab.reading:
        return const DeskPage();
      case OmnigramTab.bookshelf:
        return const LibraryPage();
      case OmnigramTab.insights:
        return const InsightsPage();
      case OmnigramTab.settings:
        return const omnigram.SettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 600;

    final destinations = [
      _NavItem(icon: Icons.auto_stories_outlined, selectedIcon: Icons.auto_stories, label: l10n.reading),
      _NavItem(icon: Icons.library_books_outlined, selectedIcon: Icons.library_books, label: l10n.bookshelf),
      _NavItem(icon: Icons.insights_outlined, selectedIcon: Icons.insights, label: l10n.insights),
      _NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: l10n.settings),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentTab.index,
              onDestinationSelected: (i) => setState(() => _currentTab = OmnigramTab.values[i]),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _buildPage()),
          ],
        ),
      );
    }

    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (i) => setState(() => _currentTab = OmnigramTab.values[i]),
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label});
}
```

- [ ] **Step 2: Create placeholder pages for Desk, Library, Insights, Settings**

Create minimal placeholder files so the app compiles. These will be fully implemented in Tasks 3-7.

```dart
// app/lib/page/home/desk_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeskPage extends ConsumerWidget {
  const DeskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Reading Desk — coming soon'));
  }
}
```

```dart
// app/lib/page/home/library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Library — coming soon'));
  }
}
```

```dart
// app/lib/page/home/insights_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Insights — coming soon'));
  }
}
```

```dart
// app/lib/page/home/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Settings — coming soon'));
  }
}
```

- [ ] **Step 3: Wire main.dart to use OmnigramHome and new theme**

Modify `app/lib/main.dart`:
- Replace `HomePage` with `OmnigramHome` as the default home
- Apply `OmnigramTheme.light()` / `OmnigramTheme.dark()` as theme
- Keep all existing initialization (DB, server, audio, prefs)

Key change in the `MaterialApp` builder:
```dart
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/page/omnigram_home.dart';

// In MaterialApp:
theme: OmnigramTheme.light(),
darkTheme: OmnigramTheme.dark(),
home: const OmnigramHome(),
```

Note: Keep the existing `colorSchema()` function available as fallback. The new theme replaces it for the main app, but the reader may still use the old theme system internally for its WebView content. Verify `FlexThemeData.light()` API for `flex_color_scheme` v8.3.0 — the `colorScheme` parameter handling may differ. If `FlexThemeData` doesn't accept a raw `ColorScheme`, use `FlexColorScheme.light(...).toTheme` or build `ThemeData` directly with `ColorScheme.fromSeed()` and apply `FlexSubThemesData` manually.

- [ ] **Step 4: Add l10n strings for new tabs**

Add to `app/lib/l10n/app_en.arb`:
```json
"reading": "Reading",
"bookshelf": "Bookshelf",
"insights": "Insights",
"settings": "Settings"
```

Add to `app/lib/l10n/app_zh.arb`:
```json
"reading": "阅读",
"bookshelf": "书架",
"insights": "洞察",
"settings": "设置"
```

Note: None of these four keys exist in the current ARB files. All must be added.

- [ ] **Step 5: Run code generation and verify**

Run:
```bash
cd /Users/liuyou/Workspace/omnigram/app && flutter gen-l10n && flutter analyze lib/page/omnigram_home.dart lib/page/home/
```
Expected: No analysis errors. App should compile and show 4-tab navigation with placeholder text.

- [ ] **Step 6: Build and run on simulator/device to verify navigation works**

Run: `cd /Users/liuyou/Workspace/omnigram/app && flutter run`
Expected: App launches with 4-tab bottom nav. Tapping each tab shows the placeholder text. Desktop layout (>600px) shows rail navigation.

- [ ] **Step 7: Commit**

```bash
git add app/lib/page/omnigram_home.dart app/lib/page/home/ app/lib/main.dart app/lib/l10n/
git commit -m "feat(app): replace 5-tab nav with 4-tab Omnigram navigation (Reading, Bookshelf, Insights, Settings)"
```

---

## Task 3: Reading Desk Page — "The Desk"

**Files:**
- Modify: `app/lib/page/home/desk_page.dart`
- Create: `app/lib/widgets/desk/greeting_header.dart`
- Create: `app/lib/widgets/desk/hero_book_card.dart`
- Create: `app/lib/widgets/desk/also_reading_shelf.dart`
- Create: `app/lib/providers/desk_provider.dart`

**Depends on:** Task 1 (theme), Task 2 (navigation)

**Goal:** Build the Reading Desk — the first thing users see. Shows current book (hero card), other in-progress books (horizontal shelf), daily reading summary. No AI in this sprint — memory bridge placeholder only.

- [ ] **Step 1: Create desk data provider**

```dart
// app/lib/providers/desk_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/reading_time.dart';

part 'desk_provider.g.dart';

@riverpod
Future<DeskData> deskData(ref) async {
  final bookDao = BookDao();
  final allBooks = await bookDao.selectNotDeleteBooks();
  final inProgress = allBooks
      .where((b) => b.readingPercentage > 0 && b.readingPercentage < 1.0)
      .toList()
    ..sort((a, b) => b.updateTime.compareTo(a.updateTime));

  // Use selectTotalReadingTime() for total minutes (convert seconds if needed)
  // For "today" specifically, use selectBookReadingTimeOfDay(DateTime.now())
  final readingTimeDao = ReadingTimeDao();
  final todayBooks = await readingTimeDao.selectBookReadingTimeOfDay(DateTime.now());
  final todayMinutes = todayBooks.fold<int>(0, (sum, entry) => sum + entry.values.first) ~/ 60;

  return DeskData(
    currentBook: inProgress.isNotEmpty ? inProgress.first : null,
    alsoReading: inProgress.length > 1 ? inProgress.sublist(1) : [],
    todayReadingMinutes: todayMinutes,
  );
}

class DeskData {
  final Book? currentBook;
  final List<Book> alsoReading;
  final int todayReadingMinutes;

  const DeskData({
    required this.currentBook,
    required this.alsoReading,
    required this.todayReadingMinutes,
  });
}
```

Note: Verify `ReadingTimeDao` class name and `selectBookReadingTimeOfDay` return type. The method returns `List<Map<Book, int>>` where int is reading time in seconds. Adapt the calculation accordingly. If the DAO is accessed as a singleton or top-level instance (e.g., `readingTimeDao` global), use that pattern instead.

- [ ] **Step 2: Run code generation**

Run: `cd /Users/liuyou/Workspace/omnigram/app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `desk_provider.g.dart`

- [ ] **Step 3: Create greeting header widget**

```dart
// app/lib/widgets/desk/greeting_header.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';       // Late night
    if (hour < 12) return '早上好';      // Good morning
    if (hour < 18) return '下午好';      // Good afternoon
    return '晚上好';                     // Good evening
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_greeting(), style: OmnigramTypography.displayLarge(context)),
          // Avatar placeholder — will link to profile/settings later
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create hero book card widget**

```dart
// app/lib/widgets/desk/hero_book_card.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class HeroBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onContinueReading;

  const HeroBookCard({
    super.key,
    required this.book,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (book.readingPercentage * 100).toInt();

    return OmnigramCard(
      backgroundColor: OmnigramColors.cardGreen.withValues(alpha:0.5),
      onTap: onContinueReading,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(book.coverFullPath),
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 150,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(child: Text(book.title.substring(0, 1), style: OmnigramTypography.displayLarge(context))),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: OmnigramTypography.titleLarge(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(book.author, style: OmnigramTypography.bodyMedium(context)),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.readingPercentage,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$progress% 已读', style: OmnigramTypography.caption(context)),
                const SizedBox(height: 16),
                // AI memory bridge placeholder (Sprint 2+)
                // Text('上次读到...', style: OmnigramTypography.bodyMedium(context)),
                FilledButton(
                  onPressed: onContinueReading,
                  child: const Text('继续阅读'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Note: Add `import 'dart:io';` at the top of any file using `File()`. The import path for `book.coverFullPath` returns an absolute path. Check the existing `BookCover` widget at `app/lib/widgets/bookshelf/book_cover.dart` for the exact pattern used to display covers — follow that pattern instead of `Image.file` if it uses a different approach (e.g., cached image, provider). Same applies to `also_reading_shelf.dart` and `book_grid_item.dart`.

- [ ] **Step 5: Create "also reading" horizontal shelf**

```dart
// app/lib/widgets/desk/also_reading_shelf.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';

class AlsoReadingShelf extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onBookTap;

  const AlsoReadingShelf({super.key, required this.books, required this.onBookTap});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('也在读', style: OmnigramTypography.titleMedium(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              final progress = (book.readingPercentage * 100).toInt();
              return GestureDetector(
                onTap: () => onBookTap(book),
                child: SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(book.coverFullPath),
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90, height: 120,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Text(book.title.substring(0, 1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$progress%', style: OmnigramTypography.caption(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Implement DeskPage with all widgets**

Update `app/lib/page/home/desk_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/desk_provider.dart';
import 'package:omnigram/widgets/desk/greeting_header.dart';
import 'package:omnigram/widgets/desk/hero_book_card.dart';
import 'package:omnigram/widgets/desk/also_reading_shelf.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class DeskPage extends ConsumerWidget {
  const DeskPage({super.key});

  void _openReader(BuildContext context, Book book) {
    // Navigate to immersive reader (Task 5 will implement ImmersiveReader)
    // For now, use existing ReadingPage
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ReadingPage(book: book),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deskAsync = ref.watch(deskDataProvider);

    return SafeArea(
      child: deskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (desk) {
          if (desk.currentBook == null) {
            return const EmptyState(
              message: '书桌还是空的，去书架找一本书开始阅读吧。',
              actionLabel: '去书架',
              icon: Icons.auto_stories_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
            children: [
              const SizedBox(height: 16),
              const GreetingHeader(),
              const SizedBox(height: 24),
              HeroBookCard(
                book: desk.currentBook!,
                onContinueReading: () => _openReader(context, desk.currentBook!),
              ),
              const SizedBox(height: 24),
              AlsoReadingShelf(
                books: desk.alsoReading,
                onBookTap: (book) => _openReader(context, book),
              ),
              if (desk.todayReadingMinutes > 0) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '—— 今日阅读 ${desk.todayReadingMinutes} 分钟 ——',
                    style: OmnigramTypography.caption(context),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 7: Run codegen, analyze, and test**

Run:
```bash
cd /Users/liuyou/Workspace/omnigram/app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/page/home/desk_page.dart lib/widgets/desk/ lib/providers/desk_provider.dart
```
Expected: No analysis errors.

- [ ] **Step 8: Commit**

```bash
git add app/lib/page/home/desk_page.dart app/lib/widgets/desk/ app/lib/providers/desk_provider.dart
git commit -m "feat(app): implement Reading Desk page — hero card, also reading shelf, daily summary"
```

---

## Task 4: Bookshelf Page — "The Library"

**Files:**
- Modify: `app/lib/page/home/library_page.dart`
- Create: `app/lib/widgets/library/book_grid_item.dart`
- Create: `app/lib/widgets/library/topic_section.dart`
- Create: `app/lib/widgets/library/import_button.dart`

**Depends on:** Task 1 (theme), Task 2 (navigation)

**Goal:** Build the bookshelf with topic sections (grouped by existing tags), book import, and search. No AI auto-tagging in this sprint — uses existing manual tags. The visual style must match the reference images (soft cards, pastel backgrounds).

- [ ] **Step 1: Create book grid item widget**

A single book display card for the library grid. Shows cover, title, author, and tags. Styled with the new design system.

```dart
// app/lib/widgets/library/book_grid_item.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';

class BookGridItem extends StatelessWidget {
  final Book book;
  final List<String> tags;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookGridItem({
    super.key,
    required this.book,
    this.tags = const [],
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(book.coverFullPath),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(book.title, textAlign: TextAlign.center,
                    style: OmnigramTypography.caption(context)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(book.title, style: OmnigramTypography.caption(context),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create topic section widget**

A horizontal section header ("认知科学 (5)") followed by a horizontal scroll of books. Reuses BookGridItem.

```dart
// app/lib/widgets/library/topic_section.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/library/book_grid_item.dart';

class TopicSection extends StatelessWidget {
  final String title;
  final int count;
  final List<Book> books;
  final void Function(Book) onBookTap;
  final VoidCallback? onViewAll;

  const TopicSection({
    super.key,
    required this.title,
    required this.count,
    required this.books,
    required this.onBookTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title ($count)', style: OmnigramTypography.titleMedium(context)),
            if (onViewAll != null)
              TextButton(onPressed: onViewAll, child: const Text('查看全部')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 110,
              child: BookGridItem(book: books[i], onTap: () => onBookTap(books[i])),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Create import button widget**

```dart
// app/lib/widgets/library/import_button.dart
import 'package:flutter/material.dart';

class ImportButton extends StatelessWidget {
  final VoidCallback onTap;

  const ImportButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: const Icon(Icons.add),
    );
  }
}
```

- [ ] **Step 4: Implement LibraryPage**

Update `app/lib/page/home/library_page.dart`. This page:
- Shows a search bar at top
- Groups books by tags using existing `bookListProvider` and `tagDao`
- Shows "Recently added" section for untagged or newest books
- FAB for import (reuses existing `importBookList` from `service/book.dart`)

```dart
// app/lib/page/home/library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/widgets/library/topic_section.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:file_picker/file_picker.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookListAsync = ref.watch(bookListProvider);

    return Scaffold(
      body: SafeArea(
        child: bookListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (bookGroups) {
            final allBooks = bookGroups.expand((g) => g).where((b) => !b.isDeleted).toList();

            if (allBooks.isEmpty) {
              return const EmptyState(
                message: '你的书架还是空的，导入第一本书开始阅读吧。',
                actionLabel: '导入书籍',
                icon: Icons.library_books_outlined,
              );
            }

            // Sort by update time for "recently added"
            final recentBooks = List<Book>.from(allBooks)
              ..sort((a, b) => b.createTime.compareTo(a.createTime));
            final recent = recentBooks.take(10).toList();

            return ListView(
              padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
              children: [
                const SizedBox(height: 16),
                // Title
                Text('我的书房', style: OmnigramTypography.displayLarge(context)),
                const SizedBox(height: 16),
                // Search bar
                SearchBar(
                  hintText: '搜索书名或作者',
                  leading: const Icon(Icons.search),
                  onTap: () {
                    // TODO: navigate to search page (reuse existing)
                  },
                ),
                const SizedBox(height: 24),
                // Recently added
                TopicSection(
                  title: '最近添加',
                  count: recent.length,
                  books: recent,
                  onBookTap: (book) => _openBook(context, book),
                ),
                const SizedBox(height: 24),
                // All books as grid (simple for Sprint 1, topic grouping in Sprint 2+ with AI tags)
                Text('全部 (${allBooks.length})', style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allBooks.length,
                  itemBuilder: (_, i) => BookGridItem(
                    book: allBooks[i],
                    onTap: () => _openBook(context, allBooks[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _importBooks(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    // Navigate to reader
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ReadingPage(book: book),
    ));
  }

  void _importBooks(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'mobi', 'azw3', 'fb2', 'txt'],
    );
    if (result != null && result.files.isNotEmpty && context.mounted) {
      final files = result.files.where((f) => f.path != null).map((f) => File(f.path!)).toList();
      importBookList(files, context, ref);
    }
  }
}
```

Note: Add `import 'dart:io';` at the top for `File`. The `importBookList` function at `app/lib/service/book.dart` handles the full import flow. Check its exact signature and adapt the call. The `bookListProvider` is a class-based Riverpod Notifier (`BookList extends _$BookList`) returning `AsyncValue<List<List<Book>>>` — the `expand` flattening pattern is correct for this return type.

- [ ] **Step 5: Analyze and verify**

Run: `cd /Users/liuyou/Workspace/omnigram/app && flutter analyze lib/page/home/library_page.dart lib/widgets/library/`
Expected: No analysis errors.

- [ ] **Step 6: Commit**

```bash
git add app/lib/page/home/library_page.dart app/lib/widgets/library/
git commit -m "feat(app): implement Library page — book grid, topic sections, import"
```

---

## Task 5: Immersive Reader Wrapper

**Files:**
- Create: `app/lib/page/reader/immersive_reader.dart`
- Create: `app/lib/widgets/reader/reader_app_bar.dart`
- Create: `app/lib/widgets/reader/reader_bottom_bar.dart`
- Create: `app/lib/widgets/reader/reader_menu_sheet.dart`

**Depends on:** Task 1 (theme), Task 2 (navigation)

**Goal:** Wrap the existing `ReadingPage` / `EpubPlayer` into a clean full-screen reader with new chrome (top bar, bottom bar). This task is about the UI shell — the EPUB engine is reused as-is. For Sprint 1, this can be a thin wrapper that delegates to the existing `ReadingPage` internally, with plans to refactor the chrome in later sprints.

- [ ] **Step 1: Create ImmersiveReader as a thin wrapper**

For Sprint 1, the pragmatic approach is to create `ImmersiveReader` as the entry point that simply wraps the existing `ReadingPage`. The existing `ReadingPage` already handles all reading logic (progress tracking, bookmarks, highlights, notes, TTS, session management). Rewriting all of that would be premature.

```dart
// app/lib/page/reader/immersive_reader.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/read_theme.dart';
import 'package:omnigram/dao/theme.dart';
import 'package:omnigram/page/reading_page.dart';

/// Full-screen immersive reader.
/// Sprint 1: Thin wrapper around existing ReadingPage.
/// Sprint 2+: Replace chrome with new reader_app_bar, reader_bottom_bar.
class ImmersiveReader extends StatelessWidget {
  final Book book;

  const ImmersiveReader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Load themes required by ReadingPage constructor
    return FutureBuilder<List<ReadTheme>>(
      future: ReadThemeDao().selectAllThemes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return ReadingPage(
          key: readingPageKey,
          book: book,
          initialThemes: snapshot.data!,
        );
      },
    );
  }
}
```

Note: Verify the exact `ReadThemeDao` class name and `selectAllThemes()` method by checking `app/lib/dao/theme.dart`. Adapt the DAO call to match the actual API.

- [ ] **Step 2: Create stub files for future reader chrome widgets**

These are placeholders for Sprint 2+ when we replace the reading page chrome:

```dart
// app/lib/widgets/reader/reader_app_bar.dart
// Sprint 2+: Custom top bar — ← Chapter Title ⋮ 🎧 ☾

// app/lib/widgets/reader/reader_bottom_bar.dart
// Sprint 2+: Progress bar — ████████░░░ 68% p.142

// app/lib/widgets/reader/reader_menu_sheet.dart
// Sprint 2+: Bookmarks, notes, TOC, style settings sheet
```

Create empty files with just the comments above so the directory structure is established.

- [ ] **Step 3: Update DeskPage and LibraryPage to use ImmersiveReader**

In both `desk_page.dart` and `library_page.dart`, change the `_openReader` / `_openBook` methods:

```dart
import 'package:omnigram/page/reader/immersive_reader.dart';

void _openReader(BuildContext context, Book book) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => ImmersiveReader(book: book),
  ));
}
```

- [ ] **Step 4: Verify reading flow end-to-end**

Run the app, import a book from Bookshelf, tap it, verify the reader opens and functions correctly (page turning, progress, notes).

- [ ] **Step 5: Commit**

```bash
git add app/lib/page/reader/ app/lib/widgets/reader/ app/lib/page/home/desk_page.dart app/lib/page/home/library_page.dart
git commit -m "feat(app): add ImmersiveReader wrapper — full-screen reading entry point"
```

---

## Task 6: Insights Skeleton

**Files:**
- Modify: `app/lib/page/home/insights_page.dart`
- Create: `app/lib/widgets/insights/reading_summary_card.dart`
- Create: `app/lib/widgets/insights/notes_list.dart`
- Create: `app/lib/widgets/insights/time_period_selector.dart`

**Depends on:** Task 1 (theme), Task 2 (navigation)

**Goal:** Build the Insights skeleton with raw data (no AI). Shows: reading stats summary card (books/hours/notes counts), notes list grouped by book, time period selector. This is the "without AI" fallback from §10.3.

- [ ] **Step 1: Create time period selector**

```dart
// app/lib/widgets/insights/time_period_selector.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

enum TimePeriod { thisMonth, lastMonth, thisYear, allTime }

/// Sprint 1: SegmentedButton for simplicity.
/// Sprint 2+: Replace with horizontal swipe gesture per spec §6.1.
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;

  const TimePeriodSelector({super.key, required this.selected, required this.onChanged});

  String _label(TimePeriod p) {
    switch (p) {
      case TimePeriod.thisMonth: return '本月';
      case TimePeriod.lastMonth: return '上月';
      case TimePeriod.thisYear: return '今年';
      case TimePeriod.allTime: return '全部';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimePeriod>(
      segments: TimePeriod.values.map((p) => ButtonSegment(value: p, label: Text(_label(p)))).toList(),
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
```

- [ ] **Step 2: Create reading summary card**

```dart
// app/lib/widgets/insights/reading_summary_card.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class ReadingSummaryCard extends StatelessWidget {
  final int booksRead;
  final int totalHours;
  final int totalNotes;

  const ReadingSummaryCard({
    super.key,
    required this.booksRead,
    required this.totalHours,
    required this.totalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      backgroundColor: OmnigramColors.cardLavender.withValues(alpha:0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '$booksRead', label: '本书'),
          _Stat(value: '$totalHours', label: '小时'),
          _Stat(value: '$totalNotes', label: '条笔记'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: OmnigramTypography.displayMedium(context)),
        const SizedBox(height: 4),
        Text(label, style: OmnigramTypography.caption(context)),
      ],
    );
  }
}
```

- [ ] **Step 3: Create notes list widget**

```dart
// app/lib/widgets/insights/notes_list.dart
import 'package:flutter/material.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class NotesByBookList extends StatelessWidget {
  final Map<String, List<BookNote>> notesByBook; // book title → notes
  final ScrollController? scrollController;

  const NotesByBookList({super.key, required this.notesByBook, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (notesByBook.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text('开始阅读并添加笔记，这里会展示你的知识积累。',
          style: OmnigramTypography.bodyMedium(context), textAlign: TextAlign.center),
      );
    }

    final entries = notesByBook.entries.toList();
    return ListView.separated(
      controller: scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final bookTitle = entries[i].key;
        final notes = entries[i].value;
        return OmnigramCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bookTitle, style: OmnigramTypography.titleMedium(context)),
              Text('${notes.length} 条笔记', style: OmnigramTypography.caption(context)),
              const SizedBox(height: 8),
              ...notes.take(3).map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(note.content, style: OmnigramTypography.bodyMedium(context),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              )),
              if (notes.length > 3)
                Text('...还有 ${notes.length - 3} 条', style: OmnigramTypography.caption(context)),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Implement InsightsPage**

Update `app/lib/page/home/insights_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/dao/reading_time.dart';
import 'package:omnigram/widgets/insights/reading_summary_card.dart';
import 'package:omnigram/widgets/insights/notes_list.dart';
import 'package:omnigram/widgets/insights/time_period_selector.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  TimePeriod _period = TimePeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    // Sprint 1: simple data queries (no AI narrative)
    // Sprint 3+: AI-generated reading story replaces summary card
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          const SizedBox(height: 16),
          Text('洞察', style: OmnigramTypography.displayLarge(context)),
          const SizedBox(height: 16),
          TimePeriodSelector(
            selected: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 24),
          // Reading summary card — uses FutureBuilder for now
          // Sprint 3+: This becomes the AI narrative card
          FutureBuilder(
            future: _loadStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final stats = snapshot.data!;
              return ReadingSummaryCard(
                booksRead: stats['books']!,
                totalHours: stats['hours']!,
                totalNotes: stats['notes']!,
              );
            },
          ),
          const SizedBox(height: 24),
          Text('笔记', style: OmnigramTypography.titleLarge(context)),
          const SizedBox(height: 12),
          // Notes grouped by book
          FutureBuilder(
            future: _loadNotesByBook(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const EmptyState(
                  message: '开始阅读并添加笔记，洞察会随着你的阅读逐渐丰富。',
                  icon: Icons.insights_outlined,
                );
              }
              return NotesByBookList(notesByBook: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _loadStats() async {
    final bookDao = BookDao();
    final readingTimeDao = ReadingTimeDao();
    final bookNoteDao = BookNoteDao();

    final books = await bookDao.selectNotDeleteBooks();
    final finishedCount = books.where((b) => b.readingPercentage >= 1.0).length;
    final totalSeconds = await readingTimeDao.selectTotalReadingTime();
    final noteStats = await bookNoteDao.selectNumberOfNotesAndBooks();

    return {
      'books': finishedCount,
      'hours': totalSeconds ~/ 3600,
      'notes': noteStats['numberOfNotes'] ?? 0,
    };
  }

  Future<Map<String, List<BookNote>>> _loadNotesByBook() async {
    final bookDao = BookDao();
    final bookNoteDao = BookNoteDao();

    final books = await bookDao.selectNotDeleteBooks();
    final grouped = <String, List<BookNote>>{};

    for (final book in books) {
      final notes = await bookNoteDao.selectBookNotesByBookId(book.id);
      if (notes.isNotEmpty) {
        grouped[book.title] = notes;
      }
    }
    return grouped;
  }
}
```

Note: The exact DAO method names (`selectBooks`, `bookNoteDao.selectAllBookNotes`) need to be verified against the actual code at `app/lib/dao/book.dart` and `app/lib/dao/book_note.dart`. Check their exact function signatures and adapt.

- [ ] **Step 5: Analyze and verify**

Run: `cd /Users/liuyou/Workspace/omnigram/app && flutter analyze lib/page/home/insights_page.dart lib/widgets/insights/`
Expected: No analysis errors.

- [ ] **Step 6: Commit**

```bash
git add app/lib/page/home/insights_page.dart app/lib/widgets/insights/
git commit -m "feat(app): implement Insights skeleton — reading stats, notes by book, time period selector"
```

---

## Task 7: Settings Framework

**Files:**
- Modify: `app/lib/page/home/settings_page.dart`

**Depends on:** Task 1 (theme), Task 2 (navigation)

**Goal:** Build the settings page structure matching §7.1. For Sprint 1, sections link to existing settings sub-pages where possible. "My Reading Companion" (TARS panel) is a placeholder for Sprint 2.

- [ ] **Step 1: Implement settings page with section structure**

```dart
// app/lib/page/home/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

// Reuse existing settings sub-pages
import 'package:omnigram/page/settings_page/more_settings_page.dart';
import 'package:omnigram/page/settings_page/appearance.dart';
import 'package:omnigram/page/settings_page/reading.dart';
import 'package:omnigram/page/settings_page/sync.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          const SizedBox(height: 16),
          Text('设置', style: OmnigramTypography.displayLarge(context)),
          const SizedBox(height: 24),
          _SettingsSection(
            icon: Icons.person_outline,
            title: '阅读身份',
            subtitle: '阅读目标 · 偏好语言 · 账户',
            onTap: () {
              // TODO Sprint 2: reading identity page
            },
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.smart_toy_outlined,
            title: '阅读伴侣',
            subtitle: '性格 · 声音 · 行为偏好',
            onTap: () {
              // TODO Sprint 2: TARS companion config
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('阅读伴侣配置将在下个版本推出')),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.text_format,
            title: '阅读体验',
            subtitle: '字体 · 排版 · 翻页 · 主题',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ReadingSettings(),
            )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.sync,
            title: '同步与存储',
            subtitle: 'WebDAV · 导入导出 · 缓存',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const SyncSetting(),
            )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.build_outlined,
            title: '高级',
            subtitle: 'AI 服务配置 · AI Chat (调试) · 开发者选项',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const MoreSettingsPage(),
            )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.info_outline,
            title: '关于 Omnigram',
            subtitle: '版本 · 许可 · 链接',
            onTap: () {
              // TODO: about page
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: OmnigramTypography.caption(context)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
```

Note: The existing settings sub-pages (`ReadingSettings`, `SyncSetting`, `MoreSettingsPage`) need their exact import paths verified. Check `app/lib/page/settings_page/` for the actual class names and file paths.

- [ ] **Step 2: Analyze and verify**

Run: `cd /Users/liuyou/Workspace/omnigram/app && flutter analyze lib/page/home/settings_page.dart`
Expected: No analysis errors. Existing sub-pages should link correctly.

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/home/settings_page.dart
git commit -m "feat(app): implement Settings page framework — 6 sections, links to existing sub-pages"
```

---

## Task 8: Integration & End-to-End Verification

**Files:**
- Modify: Various (fix any remaining import issues)

**Depends on:** Tasks 1-7

**Goal:** Verify the full user journey works end-to-end: launch app → see Reading Desk → go to Bookshelf → import a book → read it → see stats in Insights → check Settings. Fix any integration issues.

- [ ] **Step 1: Run full code generation**

```bash
cd /Users/liuyou/Workspace/omnigram/app && flutter gen-l10n && dart run build_runner build --delete-conflicting-outputs
```
Expected: All generated files created without errors.

- [ ] **Step 2: Run flutter analyze on all new code**

```bash
cd /Users/liuyou/Workspace/omnigram/app && flutter analyze lib/theme/ lib/page/omnigram_home.dart lib/page/home/ lib/page/reader/ lib/widgets/common/ lib/widgets/desk/ lib/widgets/library/ lib/widgets/insights/ lib/widgets/reader/ lib/providers/desk_provider.dart
```
Expected: No errors. Warnings acceptable if they're about unused imports in placeholder files.

- [ ] **Step 3: Build for target platform**

```bash
cd /Users/liuyou/Workspace/omnigram/app && flutter build apk --debug
```
Expected: Build succeeds.

- [ ] **Step 4: Manual end-to-end test**

Run the app and verify:
1. App launches → Reading Desk is first tab → shows empty state (if no books) or hero card (if books exist)
2. Switch to Bookshelf → shows library or empty state
3. Import a book from Bookshelf → book appears in grid
4. Tap book → opens ImmersiveReader → can read, turn pages, add highlights
5. Back from reader → Desk shows the book as "currently reading"
6. Switch to Insights → shows reading stats and notes
7. Switch to Settings → all 6 sections visible, "阅读体验" links to existing reading settings
8. Bottom navigation works correctly on mobile layout
9. Rail navigation works on wide screens (if testable)

- [ ] **Step 5: Fix any issues found in E2E test**

Fix import errors, missing method signatures, DAO method mismatches, etc.

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "feat(app): Sprint 1 complete — new 4-tab Omnigram UI with Reading Desk, Library, Insights skeleton, Settings"
```

---

## Summary

| Task | What it builds | Files created/modified |
|------|---------------|----------------------|
| 1 | Design system (colors, typography, theme, base components) | 5 new files |
| 2 | 4-tab navigation framework | 5 new files, 1 modified |
| 3 | Reading Desk ("The Desk") | 4 new files, 1 modified |
| 4 | Bookshelf ("The Library") | 3 new files, 1 modified |
| 5 | Immersive Reader wrapper | 4 new files, 2 modified |
| 6 | Insights skeleton (no AI) | 3 new files, 1 modified |
| 7 | Settings framework | 1 modified |
| 8 | Integration & E2E verification | Various fixes |

**Sprint 1 outcome:** A shippable Omnigram app with new design language, 4-tab navigation, and fully functional reading experience — no AI, but beautiful and complete.

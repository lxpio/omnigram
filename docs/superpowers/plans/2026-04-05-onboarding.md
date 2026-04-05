# Onboarding Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 2-step progressive onboarding (language + import book) that triggers on first launch via OmnigramHome.

**Architecture:** New `OnboardingFlow` widget with 2-page PageView, launched from `OmnigramHome` when `lastAppVersion == null`. Reuses existing language selector pattern and book import flow. Completes by setting `lastAppVersion` and replacing route to `OmnigramHome`.

**Tech Stack:** Flutter (PageView, Riverpod, SharedPreferences, FilePicker)

**Spec:** `docs/superpowers/specs/2026-04-05-onboarding-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `app/lib/page/onboarding_flow.dart` | 2-page onboarding widget |
| Modify | `app/lib/page/omnigram_home.dart` | First-launch detection → navigate to onboarding |
| Modify | `app/lib/l10n/app_en.arb` | 7 new L10n keys (English) |
| Modify | `app/lib/l10n/app_zh-CN.arb` | 7 new L10n keys (Chinese) |
| Modify | `docs/superpowers/PROGRESS.md` | Mark onboarding complete |

---

### Task 1: Add L10n keys

**Files:**
- Modify: `app/lib/l10n/app_en.arb`
- Modify: `app/lib/l10n/app_zh-CN.arb`

- [ ] **Step 1: Add English keys to app_en.arb**

Before the closing `}`, add:

```json
  "onboardingWelcome": "Welcome to Omnigram",
  "onboardingChooseLanguage": "Choose your language",
  "onboardingNext": "Next",
  "onboardingStartJourney": "Start your reading journey",
  "onboardingImportBooks": "Import local books",
  "onboardingConnectServer": "Connect to Omnigram Server",
  "onboardingSkip": "Skip for now"
```

- [ ] **Step 2: Add Chinese keys to app_zh-CN.arb**

Before the closing `}`, add:

```json
  "onboardingWelcome": "欢迎使用 Omnigram",
  "onboardingChooseLanguage": "选择你的语言",
  "onboardingNext": "下一步",
  "onboardingStartJourney": "开始你的阅读之旅",
  "onboardingImportBooks": "导入本地书籍",
  "onboardingConnectServer": "连接 Omnigram 服务端",
  "onboardingSkip": "跳过，稍后再说"
```

- [ ] **Step 3: Generate L10n code**

Run: `cd app && flutter gen-l10n`
Expected: Success (exit 0)

- [ ] **Step 4: Commit**

```bash
git add app/lib/l10n/
git commit -m "l10n: add onboarding flow keys (en + zh-CN)"
```

---

### Task 2: Create OnboardingFlow widget

**Files:**
- Create: `app/lib/page/onboarding_flow.dart`

- [ ] **Step 1: Create the onboarding flow widget**

Create `app/lib/page/onboarding_flow.dart`:

```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/omnigram_home.dart';
import 'package:omnigram/page/settings_page/appearance.dart' show languageOptions;
import 'package:omnigram/page/settings_page/server_connection_page.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _complete() async {
    final info = await PackageInfo.fromPlatform();
    Prefs().lastAppVersion = info.version;
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OmnigramHome()),
      );
    }
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'mobi', 'azw3', 'fb2', 'txt', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      final files = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
      importBookList(files, context, ref);
      await _complete();
    }
  }

  void _connectServer() async {
    final connected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ServerConnectionPage()),
    );
    if (connected == true && mounted) {
      await _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) => _dot(i == _currentPage)),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _LanguagePage(onNext: _nextPage, l10n: l10n),
                  _ImportPage(
                    l10n: l10n,
                    onImport: _importBooks,
                    onConnect: _connectServer,
                    onSkip: _complete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// --- Page 1: Language Selection ---

class _LanguagePage extends StatefulWidget {
  final VoidCallback onNext;
  final L10n l10n;
  const _LanguagePage({required this.onNext, required this.l10n});

  @override
  State<_LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<_LanguagePage> {
  late String _selectedLang;

  @override
  void initState() {
    super.initState();
    final current = Prefs().locale;
    final tag = current != null
        ? '${current.languageCode}${current.countryCode != null && current.countryCode!.isNotEmpty ? '-${current.countryCode}' : ''}'
        : 'system';
    _selectedLang = languageOptions.any((o) => o.values.first == tag)
        ? tag
        : 'system';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            widget.l10n.onboardingWelcome,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            widget.l10n.onboardingChooseLanguage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedLang,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLang = newValue;
                    Prefs().saveLocaleToPrefs(newValue);
                  });
                }
              },
              items: languageOptions
                  .map((option) => DropdownMenuItem<String>(
                        value: option.values.first,
                        child: Text(option.keys.first),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: widget.onNext,
            icon: const Icon(Icons.arrow_forward),
            label: Text(widget.l10n.onboardingNext),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Page 2: Import Books / Connect Server ---

class _ImportPage extends StatelessWidget {
  final L10n l10n;
  final VoidCallback onImport;
  final VoidCallback onConnect;
  final Future<void> Function() onSkip;
  const _ImportPage({
    required this.l10n,
    required this.onImport,
    required this.onConnect,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            lnl0n.onboardingStartJourney,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.file_upload),
            label: Text(l10n.onboardingImportBooks),
            style: FilledButton.styleFrom(
              minimumSize: const Size(260, 48),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onConnect,
            icon: const Icon(Icons.cloud_outlined),
            label: Text(l10n.onboardingConnectServer),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(260, 48),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: onSkip,
            child: Text(
              l10n.onboardingSkip,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
```

Note: Check that `ServerConnectionPage` can return a `bool` result. If it doesn't currently `Navigator.pop(context, true)` on success, you may need to handle the connection check differently — e.g., check connection state after returning from the page.

Also check if `package_info_plus` is in `pubspec.yaml`. If not, the version can be hardcoded or obtained another way. Look at how `lastAppVersion` is set elsewhere in the codebase.

- [ ] **Step 2: Verify no analysis errors**

Run: `cd app && flutter analyze lib/page/onboarding_flow.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/onboarding_flow.dart
git commit -m "feat: create OnboardingFlow widget with language + import pages"
```

---

### Task 3: Wire OnboardingFlow into OmnigramHome

**Files:**
- Modify: `app/lib/page/omnigram_home.dart`

- [ ] **Step 1: Add first-launch detection**

Add imports at the top:
```dart
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/page/onboarding_flow.dart';
```

In `_OmnigramHomeState`, add an `initState` override:

```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Prefs().lastAppVersion == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
      }
    });
  }
```

This checks after the first frame renders. If `lastAppVersion` is null (first launch), replaces the current route with onboarding.

- [ ] **Step 2: Verify no analysis errors**

Run: `cd app && flutter analyze lib/page/omnigram_home.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/omnigram_home.dart
git commit -m "feat: wire OnboardingFlow into OmnigramHome first-launch detection"
```

---

### Task 4: Update progress docs

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Mark onboarding as complete**

In the "跨层级功能" table, update:
```markdown
| Onboarding 流程 | §10.8 | ✅ | `page/onboarding_flow.dart` — 渐进式 2 步引导（语言+导入） |
```

Add to "更新记录":
```markdown
| 2026-04-05 | **Onboarding 流程** ✅：渐进式 2 步引导（语言选择 + 导入书籍/连接服务端），接入 OmnigramHome 首次启动检测 |
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark onboarding flow as complete"
```

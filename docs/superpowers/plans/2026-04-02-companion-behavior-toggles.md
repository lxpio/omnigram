# Companion Behavior Toggles — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 5 behavior toggles to companion settings that gate AI features, with full persistence and server sync.

**Architecture:** Extend `CompanionPersonality` (freezed) with 5 bool fields, update `CompanionProvider` sync to use `toJson()`/`fromJson()`, add toggle UI to settings page, add guards to 2 AI entry points, update Server schema + handlers.

**Tech Stack:** Flutter (Riverpod, freezed), Go (Gin, GORM), L10n (16 ARB files)

**Spec:** `docs/superpowers/specs/2026-04-02-companion-behavior-toggles-design.md`

---

### Task 1: Extend CompanionPersonality model + presets

**Files:**
- Modify: `app/lib/models/companion_personality.dart`
- Create: `app/test/models/companion_personality_test.dart`

- [ ] **Step 1: Write tests for new defaults and presets**

```dart
// app/test/models/companion_personality_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/companion_personality.dart';

void main() {
  group('CompanionPersonality defaults', () {
    test('default toggles: crossBookAlerts and autoKnowledgeGraph true, rest false', () {
      const p = CompanionPersonality();
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.crossBookAlerts, true);
      expect(p.postChapterQuestions, false);
      expect(p.autoKnowledgeGraph, true);
    });

    test('default name, sliders unchanged', () {
      const p = CompanionPersonality();
      expect(p.name, 'TARS');
      expect(p.warmth, 50);
    });
  });

  group('CompanionPresets', () {
    test('silent preset: all toggles off', () {
      final p = CompanionPresets.silent();
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.crossBookAlerts, false);
      expect(p.postChapterQuestions, false);
      expect(p.autoKnowledgeGraph, false);
    });

    test('buddy preset: implemented features on', () {
      final p = CompanionPresets.buddy();
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.postChapterQuestions, false);
    });

    test('scholar preset: implemented features on', () {
      final p = CompanionPresets.scholar();
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.postChapterQuestions, false);
    });
  });

  group('JSON round-trip', () {
    test('toJson includes toggle fields', () {
      const p = CompanionPersonality(crossBookAlerts: false);
      final json = p.toJson();
      expect(json['crossBookAlerts'], false);
      expect(json['autoKnowledgeGraph'], true);
    });

    test('fromJson restores toggle fields', () {
      final p = CompanionPersonality.fromJson({
        'name': 'TARS',
        'crossBookAlerts': false,
        'autoKnowledgeGraph': false,
      });
      expect(p.crossBookAlerts, false);
      expect(p.autoKnowledgeGraph, false);
    });

    test('fromJson with missing toggle fields uses defaults', () {
      final p = CompanionPersonality.fromJson({'name': 'TARS'});
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/models/companion_personality_test.dart`
Expected: FAIL — fields don't exist yet

- [ ] **Step 3: Add 5 bool fields to CompanionPersonality**

In `app/lib/models/companion_personality.dart`, update the factory:

```dart
@freezed
abstract class CompanionPersonality with _$CompanionPersonality {
  const factory CompanionPersonality({
    @Default('TARS') String name,
    @Default(50) int proactivity,
    @Default(50) int style,
    @Default(50) int depth,
    @Default(50) int warmth,
    @Default('') String voice,
    @Default(false) bool autoChapterRecap,
    @Default(false) bool annotateHardWords,
    @Default(true) bool crossBookAlerts,
    @Default(false) bool postChapterQuestions,
    @Default(true) bool autoKnowledgeGraph,
  }) = _CompanionPersonality;

  factory CompanionPersonality.fromJson(Map<String, dynamic> json) => _$CompanionPersonalityFromJson(json);
}
```

- [ ] **Step 4: Update presets**

```dart
extension CompanionPresets on CompanionPersonality {
  static CompanionPersonality silent() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 20,
        style: 20,
        depth: 50,
        warmth: 30,
        autoChapterRecap: false,
        annotateHardWords: false,
        crossBookAlerts: false,
        postChapterQuestions: false,
        autoKnowledgeGraph: false,
      );

  static CompanionPersonality buddy() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 50,
        style: 60,
        depth: 40,
        warmth: 80,
        autoChapterRecap: false,
        annotateHardWords: false,
        crossBookAlerts: true,
        postChapterQuestions: false,
        autoKnowledgeGraph: true,
      );

  static CompanionPersonality scholar() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 80,
        style: 80,
        depth: 90,
        warmth: 30,
        autoChapterRecap: false,
        annotateHardWords: false,
        crossBookAlerts: true,
        postChapterQuestions: false,
        autoKnowledgeGraph: true,
      );
}
```

- [ ] **Step 5: Run codegen**

Run: `cd app && dart run build_runner build --delete-conflicting-outputs`
Expected: `companion_personality.freezed.dart` and `companion_personality.g.dart` regenerated

- [ ] **Step 6: Run tests — expect PASS**

Run: `cd app && flutter test test/models/companion_personality_test.dart`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
git add app/lib/models/companion_personality.dart app/lib/models/companion_personality.freezed.dart app/lib/models/companion_personality.g.dart app/test/models/companion_personality_test.dart
git commit -m "feat: add 5 behavior toggle fields to CompanionPersonality"
```

---

### Task 2: Update CompanionProvider sync + convenience methods

**Files:**
- Modify: `app/lib/providers/companion_provider.dart`

- [ ] **Step 1: Add 5 convenience update methods**

After the existing `updateVoice` method, add:

```dart
void updateAutoChapterRecap(bool v) => update(state.copyWith(autoChapterRecap: v));
void updateAnnotateHardWords(bool v) => update(state.copyWith(annotateHardWords: v));
void updateCrossBookAlerts(bool v) => update(state.copyWith(crossBookAlerts: v));
void updatePostChapterQuestions(bool v) => update(state.copyWith(postChapterQuestions: v));
void updateAutoKnowledgeGraph(bool v) => update(state.copyWith(autoKnowledgeGraph: v));
```

- [ ] **Step 2: Change _syncToServer to use toJson()**

Replace the `_syncToServer` method body. Change:

```dart
await api.putVoid('/user/companion', data: {
  'name': p.name,
  'proactivity': p.proactivity,
  'style': p.style,
  'depth': p.depth,
  'warmth': p.warmth,
  'voice': p.voice,
});
```

To:

```dart
await api.putVoid('/user/companion', data: p.toJson());
```

- [ ] **Step 3: Change _syncFromServer to use fromJson()**

Replace the manual field extraction in `_syncFromServer`. Change:

```dart
final serverPersonality = CompanionPersonality(
  name: response['name'] as String? ?? state.name,
  proactivity: response['proactivity'] as int? ?? state.proactivity,
  style: response['style'] as int? ?? state.style,
  depth: response['depth'] as int? ?? state.depth,
  warmth: response['warmth'] as int? ?? state.warmth,
  voice: response['voice'] as String? ?? state.voice,
);
```

To:

```dart
final merged = <String, dynamic>{...state.toJson(), ...response};
final serverPersonality = CompanionPersonality.fromJson(merged);
```

This merges server response over local state, so missing fields from old servers fall back to local defaults.

- [ ] **Step 4: Verify analyze**

Run: `cd app && flutter analyze lib/providers/companion_provider.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add app/lib/providers/companion_provider.dart
git commit -m "refactor: companion sync uses toJson/fromJson, add toggle update methods"
```

---

### Task 3: L10n — add 7 keys to all 16 ARB files

**Files:**
- Modify: all 16 `app/lib/l10n/app_*.arb` files

- [ ] **Step 1: Add keys to app_en.arb**

```json
  "companionBehaviorSection": "Behavior Preferences",
  "companionBehaviorAnnotateHardWords": "Annotate difficult words",
  "companionBehaviorCrossBookAlerts": "Cross-book connection alerts",
  "companionBehaviorAutoKnowledgeGraph": "Auto-organize to knowledge graph",
  "companionBehaviorAutoChapterRecap": "Auto chapter recap",
  "companionBehaviorPostChapterQuestions": "Post-chapter questions",
  "companionBehaviorComingSoon": "Coming Soon"
```

- [ ] **Step 2: Add keys to app_zh-CN.arb**

```json
  "companionBehaviorSection": "行为偏好",
  "companionBehaviorAnnotateHardWords": "标注难词",
  "companionBehaviorCrossBookAlerts": "跨书连接提醒",
  "companionBehaviorAutoKnowledgeGraph": "自动整理到知识图谱",
  "companionBehaviorAutoChapterRecap": "自动生成章节回顾",
  "companionBehaviorPostChapterQuestions": "章节读完后提问",
  "companionBehaviorComingSoon": "即将推出"
```

- [ ] **Step 3: Add keys to remaining 14 ARB files**

Translate each to the appropriate language. For zh-TW use Traditional Chinese, for zh-LZH use Classical Chinese, etc.

- [ ] **Step 4: Regenerate L10n**

Run: `cd app && flutter gen-l10n`
Expected: exit code 0

- [ ] **Step 5: Commit**

```bash
git add app/lib/l10n/
git commit -m "l10n: add companion behavior toggle strings for 16 languages"
```

---

### Task 4: Add behavior toggles to companion settings UI

**Files:**
- Modify: `app/lib/page/settings_page/companion_settings_page.dart`

- [ ] **Step 1: Add L10n import**

Add at top of file:
```dart
import 'package:omnigram/l10n/generated/L10n.dart';
```

- [ ] **Step 2: Add behavior toggles section after voice selector**

In the `build` method's `ListView.children`, after the voice selector section and its `SizedBox(height: 24)`, add:

```dart
          // Behavior toggles
          Text(L10n.of(context).companionBehaviorSection, style: OmnigramTypography.titleMedium(context)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(L10n.of(context).companionBehaviorCrossBookAlerts),
            value: personality.crossBookAlerts,
            onChanged: (v) => notifier.updateCrossBookAlerts(v),
          ),
          SwitchListTile(
            title: Text(L10n.of(context).companionBehaviorAutoKnowledgeGraph),
            value: personality.autoKnowledgeGraph,
            onChanged: (v) => notifier.updateAutoKnowledgeGraph(v),
          ),
          SwitchListTile(
            title: Text(L10n.of(context).companionBehaviorAnnotateHardWords),
            subtitle: Text(L10n.of(context).companionBehaviorComingSoon),
            value: false,
            onChanged: null,
          ),
          SwitchListTile(
            title: Text(L10n.of(context).companionBehaviorAutoChapterRecap),
            subtitle: Text(L10n.of(context).companionBehaviorComingSoon),
            value: false,
            onChanged: null,
          ),
          SwitchListTile(
            title: Text(L10n.of(context).companionBehaviorPostChapterQuestions),
            subtitle: Text(L10n.of(context).companionBehaviorComingSoon),
            value: false,
            onChanged: null,
          ),
          const SizedBox(height: 24),
```

- [ ] **Step 3: Verify analyze**

Run: `cd app && flutter analyze lib/page/settings_page/companion_settings_page.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add app/lib/page/settings_page/companion_settings_page.dart
git commit -m "feat: add behavior toggle UI to companion settings page"
```

---

### Task 5: Add AI guards (crossBookAlerts + autoKnowledgeGraph)

**Files:**
- Modify: `app/lib/widgets/reader/margin_notes_overlay.dart`
- Modify: `app/lib/service/ai/ambient_tasks.dart`

- [ ] **Step 1: Add crossBookAlerts guard to margin_notes_overlay.dart**

In `_MarginNotesOverlayState`, find the `_generateNotes()` method (around line 78). At the very start of the method, add a guard:

```dart
Future<void> _generateNotes() async {
  // Guard: skip if cross-book alerts are disabled
  final personality = ref.read(companionProvider);
  if (!personality.crossBookAlerts) {
    setState(() => _isLoading = false);
    return;
  }
  // ... rest of existing method
```

Add import at top:
```dart
import 'package:omnigram/providers/companion_provider.dart';
```

- [ ] **Step 2: Add autoKnowledgeGraph guard to ambient_tasks.dart**

In `AmbientTasks.extractConcepts()`, add a guard at the start:

```dart
static Future<int> extractConcepts({
  required WidgetRef ref,
  required int bookId,
  required String bookTitle,
}) async {
  // Guard: skip if auto knowledge graph is disabled
  final personality = ref.read(companionProvider);
  if (!personality.autoKnowledgeGraph) return 0;

  final tags = await ConceptExtractor.extractFromNotes(
  // ... rest unchanged
```

Add import at top if not present:
```dart
import 'package:omnigram/providers/companion_provider.dart';
```

- [ ] **Step 3: Verify analyze on both files**

Run: `cd app && flutter analyze lib/widgets/reader/margin_notes_overlay.dart lib/service/ai/ambient_tasks.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add app/lib/widgets/reader/margin_notes_overlay.dart app/lib/service/ai/ambient_tasks.dart
git commit -m "feat: gate margin notes and concept extraction on behavior toggles"
```

---

### Task 6: Server — update CompanionProfile schema + handlers

**Files:**
- Modify: `server/schema/companion_profile.go`
- Modify: `server/service/user/handler_companion.go`

- [ ] **Step 1: Add 5 bool fields to CompanionProfile**

In `server/schema/companion_profile.go`, add after the `Voice` field:

```go
AutoChapterRecap    bool `json:"autoChapterRecap" gorm:"default:false;comment:自动章节回顾"`
AnnotateHardWords   bool `json:"annotateHardWords" gorm:"default:false;comment:标注难词"`
CrossBookAlerts     bool `json:"crossBookAlerts" gorm:"default:true;comment:跨书连接提醒"`
PostChapterQuestions bool `json:"postChapterQuestions" gorm:"default:false;comment:章节读后提问"`
AutoKnowledgeGraph  bool `json:"autoKnowledgeGraph" gorm:"default:true;comment:自动知识图谱"`
```

- [ ] **Step 2: Update getCompanionHandle fallback**

In `server/service/user/handler_companion.go`, update the fallback response in `getCompanionHandle`:

```go
c.JSON(200, &schema.CompanionProfile{
    UserID:             userID,
    Name:               "TARS",
    Proactivity:        50,
    Style:              50,
    Depth:              50,
    Warmth:             50,
    CrossBookAlerts:    true,
    AutoKnowledgeGraph: true,
})
```

- [ ] **Step 3: Add one-time migration for existing rows**

In `server/schema/companion_profile.go`, add a migration function:

```go
// MigrateCompanionToggles sets correct defaults for existing rows after adding toggle columns.
// Call once after AutoMigrate.
func MigrateCompanionToggles(db *gorm.DB) error {
	return db.Exec(`
		UPDATE companion_profiles
		SET cross_book_alerts = true, auto_knowledge_graph = true
		WHERE cross_book_alerts = false AND auto_knowledge_graph = false
	`).Error
}
```

Then find where `AutoMigrate(&CompanionProfile{})` is called (in `server/schema/init_data.go`) and add a call to `MigrateCompanionToggles(db)` right after it.

- [ ] **Step 4: Regenerate swagger docs**

Run: `cd server && make swagger`
Expected: `server/docs/` files regenerated

- [ ] **Step 5: Verify server builds**

Run: `cd server && go build ./...`
Expected: exit code 0

- [ ] **Step 6: Commit**

```bash
git add server/schema/companion_profile.go server/service/user/handler_companion.go server/schema/init_data.go server/docs/
git commit -m "feat(server): add behavior toggle fields to CompanionProfile + migration"
```

---

### Task 7: Final verification + PROGRESS.md

**Files:** verification only + `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Run all Dart tests**

Run: `cd app && flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run flutter analyze**

Run: `cd app && flutter analyze lib/`
Expected: No new errors in changed files

- [ ] **Step 3: Run Go build**

Run: `cd server && go build ./...`
Expected: exit code 0

- [ ] **Step 4: Update PROGRESS.md**

Change the behavior toggles line:
```markdown
| 伴侣行为开关（5 个 toggle） | §7.2 | ✅ | `companion_personality.dart`, `companion_settings_page.dart` | <commit-hash> |
```

Add to 更新记录:
```markdown
| 2026-04-02 | **伴侣行为开关完成** ✅：5 toggle（2 enabled + 3 Coming Soon），CompanionPersonality 扩展，Server 同步改用 toJson/fromJson，AI guard 接入 margin notes + concept extractor |
```

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark companion behavior toggles as complete"
```

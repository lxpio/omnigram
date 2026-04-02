# Companion Behavior Toggles Design

> **Date:** 2026-04-02
> **Status:** Approved
> **Scope:** 5 behavior toggles in companion settings, gating AI features

---

## 1. Overview

Add 5 behavior toggles to the companion settings page, allowing users to control which AI features are active. Toggles extend the existing `CompanionPersonality` model and reuse the SharedPreferences + Server sync pipeline.

---

## 2. Data Model Changes

### 2.1 CompanionPersonality (Dart — freezed)

Add 5 bool fields to `app/lib/models/companion_personality.dart`:

| Field | Description | Default | Feature Status |
|-------|-------------|---------|----------------|
| `autoChapterRecap` | Auto-generate chapter recap on chapter switch | `false` | Not implemented |
| `annotateHardWords` | Auto-detect and annotate difficult words | `false` | Not implemented (auto-detect pending) |
| `crossBookAlerts` | Show cross-book connection alerts in margins | `true` | Implemented (margin notes) |
| `postChapterQuestions` | Prompt thought questions after finishing a chapter | `false` | Not implemented |
| `autoKnowledgeGraph` | Auto-extract concepts to knowledge graph | `true` | Implemented (concept extractor) |

### 2.2 CompanionPresets

Update the three presets:

| Preset | autoChapterRecap | annotateHardWords | crossBookAlerts | postChapterQuestions | autoKnowledgeGraph |
|--------|-----------------|-------------------|-----------------|---------------------|-------------------|
| Silent | false | false | false | false | false |
| Buddy | false | false | true | false | true |
| Scholar | false | false | true | false | true |

Silent turns everything off (minimal interference). Buddy and Scholar enable implemented features, leave unimplemented ones off.

> **Note (R-7):** Presets will be revisited when `autoChapterRecap`, `annotateHardWords`, and `postChapterQuestions` are implemented. Scholar may enable more toggles at that time.

### 2.3 CompanionProfile (Go — Server)

Add 5 bool fields to `server/schema/companion_profile.go`:

```go
AutoChapterRecap     bool `json:"autoChapterRecap" gorm:"default:false"`
AnnotateHardWords    bool `json:"annotateHardWords" gorm:"default:false"`
CrossBookAlerts      bool `json:"crossBookAlerts" gorm:"default:true"`
PostChapterQuestions  bool `json:"postChapterQuestions" gorm:"default:false"`
AutoKnowledgeGraph   bool `json:"autoKnowledgeGraph" gorm:"default:true"`
```

After `AutoMigrate`, regenerate swagger docs: `cd server && make swagger` (R-10).

No new endpoints needed — fields sync via existing `GET/PUT /user/companion`.

### 2.4 Server Sync Safety (R-1, R-2)

**Problem:** Old clients that `PUT /user/companion` only send 6 fields. Go deserializes missing bools as `false`, causing `db.Save()` to overwrite toggles to `false`.

**Fix — Client side:** Change `_syncToServer` and `_syncFromServer` in `companion_provider.dart` to use `p.toJson()` / `CompanionPersonality.fromJson()` instead of manual field mapping. This eliminates field drift for all future additions.

**Fix — Server side:** `getCompanionHandle` fallback response must include the 3 true-default toggles: `AnnotateHardWords: true, CrossBookAlerts: true, AutoKnowledgeGraph: true`.

**Fix — Migration:** After `AutoMigrate`, run a one-time migration to set correct defaults on existing rows:
```sql
UPDATE companion_profiles
SET annotate_hard_words = true, cross_book_alerts = true, auto_knowledge_graph = true
WHERE annotate_hard_words = false AND created_at < <migration_timestamp>;
```

### 2.5 Companion Provider Sync Update (R-3)

`companion_provider.dart` methods `_syncToServer` and `_syncFromServer` currently hand-map 6 fields. Both must be updated:

- `_syncToServer`: change `data: { manual fields }` → `data: p.toJson()`
- `_syncFromServer`: change manual field extraction → `CompanionPersonality.fromJson(response)`

This eliminates the need to update sync code every time a field is added.

### 2.6 Provider Convenience Methods (R-8)

Add 5 convenience methods to `Companion` notifier matching the existing pattern:

```dart
void updateAutoChapterRecap(bool v) => update(state.copyWith(autoChapterRecap: v));
void updateAnnotateHardWords(bool v) => update(state.copyWith(annotateHardWords: v));
void updateCrossBookAlerts(bool v) => update(state.copyWith(crossBookAlerts: v));
void updatePostChapterQuestions(bool v) => update(state.copyWith(postChapterQuestions: v));
void updateAutoKnowledgeGraph(bool v) => update(state.copyWith(autoKnowledgeGraph: v));
```

---

## 3. UI Design

### 3.1 Settings Page Layout

Add a "Behavior Preferences" section in `companion_settings_page.dart`, below the existing voice selector:

```
─── Voice ───
[voice selector]

─── Behavior Preferences ───
☑ Cross-book connection alerts           (SwitchListTile, enabled)
☑ Auto-organize to knowledge graph       (SwitchListTile, enabled)
☐ Annotate difficult words     Coming Soon (SwitchListTile, disabled + badge)
☐ Auto chapter recap           Coming Soon (SwitchListTile, disabled + badge)
☐ Post-chapter questions       Coming Soon (SwitchListTile, disabled + badge)
```

### 3.2 Toggle Ordering

Enabled (implemented) features first, disabled (unimplemented) features last. Within each group, order matches the reading flow: words → cross-book → knowledge graph → chapter recap → questions.

### 3.3 "Coming Soon" Treatment

Unimplemented toggles:
- `SwitchListTile` with `onChanged: null` (greyed out)
- Subtitle text: L10n key `companionBehaviorComingSoon` ("Coming Soon" / "即将推出")
- No tooltip or explanation needed — the label + "Coming Soon" is sufficient

### 3.4 L10n Keys

| Key | EN | CN |
|-----|----|----|
| `companionBehaviorSection` | Behavior Preferences | 行为偏好 |
| `companionBehaviorAnnotateHardWords` | Annotate difficult words | 标注难词 |
| `companionBehaviorCrossBookAlerts` | Cross-book connection alerts | 跨书连接提醒 |
| `companionBehaviorAutoKnowledgeGraph` | Auto-organize to knowledge graph | 自动整理到知识图谱 |
| `companionBehaviorAutoChapterRecap` | Auto chapter recap | 自动生成章节回顾 |
| `companionBehaviorPostChapterQuestions` | Post-chapter questions | 章节读完后提问 |
| `companionBehaviorComingSoon` | Coming Soon | 即将推出 |

7 keys × 16 languages = 112 translations.

---

## 4. AI Pipeline Integration

When a toggle is off, the corresponding AI feature is skipped at its entry point.

### 4.1 Guard Points

| Toggle | Guard Location | Behavior When Off |
|--------|---------------|-------------------|
| `annotateHardWords` | Guard deferred — auto-detect not yet implemented | N/A (toggle exists as Coming Soon) |
| `crossBookAlerts` | `widgets/reader/margin_notes_overlay.dart` | Don't generate or display margin notes |
| `autoKnowledgeGraph` | `service/ai/ambient_tasks.dart` → `extractConcepts` | Skip concept extraction after reading |

### 4.2 Guard Implementation

Each guard reads the toggle via `ref.watch(companionProvider)`:

```dart
final personality = ref.watch(companionProvider);
if (!personality.crossBookAlerts) return; // skip
```

Simple early return — no complex logic. The AI pipeline itself is untouched; only the trigger point is gated.

### 4.3 Manual vs Auto Distinction

All toggles gate **proactive/automatic** behavior only. User-initiated actions (e.g., manually selecting text and tapping "Explain") work regardless of toggle state.

### 4.4 Toggle Off vs Existing Data (R-12)

Turning a toggle off **hides future generation** but does not delete or hide existing data. E.g., turning off `crossBookAlerts` stops new margin notes from being generated, but already-existing margin notes remain visible and accessible. This is the simplest and least surprising behavior.

### 4.5 annotateHardWords Status (R-5)

`annotateHardWords` is reclassified as **Coming Soon** alongside `autoChapterRecap` and `postChapterQuestions`. The auto-detect feature is not yet implemented (PROGRESS.md shows "自动检测难词 ❌"), so there is no code to gate. The toggle will be enabled when the auto-detect feature is built. The existing manual glossary (user selects text → Explain) is unaffected by this toggle.

Updated defaults: `annotateHardWords` default changes to `false` (Coming Soon = off by default).

---

## 5. Codegen & Build Impact

Adding fields to `CompanionPersonality` (freezed) requires:
1. Update `companion_personality.dart` with new fields
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Regenerated files: `companion_personality.freezed.dart`, `companion_personality.g.dart`

Existing code that reads `CompanionPersonality` is unaffected — new fields have defaults.

Server changes require:
1. Update `companion_profile.go` with new fields
2. Run `cd server && make swagger` to regenerate API docs
3. One-time migration for existing rows (§2.4)

---

## 6. Degradation

| Scenario | Behavior |
|----------|----------|
| No companion configured | All toggles use default values (2 on, 3 off) |
| Old server without new fields | Client defaults apply; `toJson()` sends all fields, server ignores unknown ones |
| Old client with new server | Handled by §2.4 — server preserves toggles via PATCH-style merge or client upgrade |

---

## 7. Testing

| Test | Scope | Priority |
|------|-------|----------|
| CompanionPersonality new fields + defaults | Unit: verify 5 bools have correct defaults | P0 |
| Presets include correct toggle values | Unit: Silent/Buddy/Scholar assertions | P0 |
| Settings page renders toggles | Widget test: 5 toggles visible, 2 disabled | P1 |
| AI guard respects toggle | Unit: mock personality with toggle off → feature skipped | P1 |

---

## 8. Out of Scope

- Implementing `autoChapterRecap` or `postChapterQuestions` features (only the toggles exist)
- Per-book toggle overrides (all toggles are global)
- Toggle change analytics or tracking

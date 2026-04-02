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
| `annotateHardWords` | Auto-detect and annotate difficult words | `true` | Partial (glossary exists, auto-detect pending) |
| `crossBookAlerts` | Show cross-book connection alerts in margins | `true` | Implemented (margin notes) |
| `postChapterQuestions` | Prompt thought questions after finishing a chapter | `false` | Not implemented |
| `autoKnowledgeGraph` | Auto-extract concepts to knowledge graph | `true` | Implemented (concept extractor) |

### 2.2 CompanionPresets

Update the three presets:

| Preset | autoChapterRecap | annotateHardWords | crossBookAlerts | postChapterQuestions | autoKnowledgeGraph |
|--------|-----------------|-------------------|-----------------|---------------------|-------------------|
| Silent | false | false | false | false | false |
| Buddy | false | true | true | false | true |
| Scholar | false | true | true | false | true |

Silent turns everything off (minimal interference). Buddy and Scholar enable implemented features, leave unimplemented ones off.

### 2.3 CompanionProfile (Go — Server)

Add 5 bool fields to `server/schema/companion_profile.go`:

```go
AutoChapterRecap     bool `json:"autoChapterRecap" gorm:"default:false"`
AnnotateHardWords    bool `json:"annotateHardWords" gorm:"default:true"`
CrossBookAlerts      bool `json:"crossBookAlerts" gorm:"default:true"`
PostChapterQuestions  bool `json:"postChapterQuestions" gorm:"default:false"`
AutoKnowledgeGraph   bool `json:"autoKnowledgeGraph" gorm:"default:true"`
```

No new endpoints needed — fields sync via existing `GET/PUT /user/companion`.

---

## 3. UI Design

### 3.1 Settings Page Layout

Add a "Behavior Preferences" section in `companion_settings_page.dart`, below the existing voice selector:

```
─── Voice ───
[voice selector]

─── Behavior Preferences ───
☑ Annotate difficult words              (SwitchListTile, enabled)
☑ Cross-book connection alerts           (SwitchListTile, enabled)
☑ Auto-organize to knowledge graph       (SwitchListTile, enabled)
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
| `annotateHardWords` | `widgets/reader/glossary_tooltip.dart` | Skip auto-detection; manual selection still works |
| `crossBookAlerts` | `widgets/reader/margin_notes_overlay.dart` | Don't generate or display margin notes |
| `autoKnowledgeGraph` | `service/ai/concept_extractor.dart` | Skip concept extraction after reading |

### 4.2 Guard Implementation

Each guard reads the toggle via `ref.watch(companionProvider)`:

```dart
final personality = ref.watch(companionProvider);
if (!personality.crossBookAlerts) return; // skip
```

Simple early return — no complex logic. The AI pipeline itself is untouched; only the trigger point is gated.

### 4.3 Manual vs Auto Distinction

`annotateHardWords` only gates **automatic** detection. If the user manually selects text and taps "Explain", the glossary still works regardless of toggle state. The toggle controls proactive behavior, not user-initiated actions.

---

## 5. Codegen Impact

Adding fields to `CompanionPersonality` (freezed) requires:
1. Update `companion_personality.dart` with new fields
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Regenerated files: `companion_personality.freezed.dart`, `companion_personality.g.dart`

Existing code that reads `CompanionPersonality` is unaffected — new fields have defaults.

---

## 6. Degradation

| Scenario | Behavior |
|----------|----------|
| No companion configured | All toggles use default values (3 on, 2 off) |
| Old server without new fields | Client defaults apply; PUT sends all fields, server ignores unknown ones |
| Old client with new server | Server returns extra fields, old client ignores them (freezed `fromJson` is lenient) |

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

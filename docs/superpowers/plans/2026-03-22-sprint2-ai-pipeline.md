# Sprint 2: AI Pipeline — Implementation Plan

> **Goal:** Transform the existing chat-oriented AI system into an ambient AI pipeline. Deliver TARS companion personality, background processing, and the first "invisible AI" features (Context Bar + Memory Bridge).
>
> **Prerequisite:** Sprint 1 ✅ (4-tab UI, reading desk, bookshelf, insights skeleton, settings)
>
> **Existing AI Infrastructure:** Multi-provider LangChain integration (OpenAI/Claude/Gemini), streaming, tool system, chat history, caching, RPM throttling — all chat-oriented. Sprint 2 extends this for ambient/background use.

---

## Key Insight

The app already has a comprehensive AI service layer (`service/ai/`, `providers/ai_*.dart`). Sprint 2 does NOT rebuild AI connectivity. It adds:
1. **Personality injection** — TARS system prompt modifiers applied to ALL AI calls
2. **Background pipeline** — Queue-based async AI processing (not tied to chat UI)
3. **Ambient AI widgets** — Context Bar (reader) + Memory Bridge (desk)
4. **Degradation framework** — Unified "AI available?" check for all ambient features

---

## Task Dependency Graph

```
Task 1 (TARS Personality) ─┐
                           ├── Task 3 (Context Bar) ── requires personality + pipeline
Task 2 (Background Pipeline) ┤
                           ├── Task 4 (Memory Bridge) ── requires pipeline
                           └── Task 5 (Import AI) ── requires pipeline
Task 6 (Degradation) ── independent, can run in parallel
Task 7 (Integration) ── after all tasks
```

---

## Task 1: TARS Companion Personality System

**Files:**
- Create: `app/lib/models/companion_personality.dart`
- Create: `app/lib/providers/companion_provider.dart`
- Create: `app/lib/service/ai/companion_prompt.dart`
- Create: `app/lib/page/settings_page/companion_settings_page.dart`
- Modify: `app/lib/page/home/settings_page.dart` (wire up companion settings)

**Goal:** 4-slider personality config (Proactivity, Style, Depth, Warmth) + 3 presets. Personality injects into system prompts for ALL AI interactions.

- [ ] **Step 1: Create CompanionPersonality model**

```dart
// app/lib/models/companion_personality.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'companion_personality.freezed.dart';
part 'companion_personality.g.dart';

@freezed
class CompanionPersonality with _$CompanionPersonality {
  const factory CompanionPersonality({
    @Default('TARS') String name,
    @Default(50) int proactivity,  // 0=silent, 100=chatty
    @Default(50) int style,        // 0=direct, 100=socratic
    @Default(50) int depth,        // 0=plain, 100=academic
    @Default(50) int warmth,       // 0=cool, 100=warm
  }) = _CompanionPersonality;

  factory CompanionPersonality.fromJson(Map<String, dynamic> json) =>
      _$CompanionPersonalityFromJson(json);

  /// Preset: 默默帮忙型
  factory CompanionPersonality.silent() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 20,
        style: 20,
        depth: 50,
        warmth: 30,
      );

  /// Preset: 读书搭子型
  factory CompanionPersonality.buddy() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 50,
        style: 60,
        depth: 40,
        warmth: 80,
      );

  /// Preset: 学术导师型
  factory CompanionPersonality.scholar() => const CompanionPersonality(
        name: 'TARS',
        proactivity: 80,
        style: 80,
        depth: 90,
        warmth: 30,
      );
}
```

- [ ] **Step 2: Create companion provider**

Persists personality to SharedPreferences. Provides current personality to all AI calls.

- [ ] **Step 3: Create companion prompt builder**

Maps slider values to system prompt modifiers. Example output:
```
You are a reading companion named "TARS". Your personality:
- Communication: Mostly quiet, speak only when you have genuinely useful insights
- Style: Lean toward asking thought-provoking questions rather than giving direct answers
- Depth: Use accessible language, avoid jargon unless the reader uses it first
- Tone: Warm and encouraging, like a friend who loves books
```

- [ ] **Step 4: Create companion settings UI page**

4 sliders + live preview + 3 preset buttons + name field.

- [ ] **Step 5: Wire into settings page**

Update `settings_page.dart` to navigate to CompanionSettingsPage.

- [ ] **Step 6: Run codegen + analyze**
- [ ] **Step 7: Commit**

---

## Task 2: Background AI Pipeline

**Files:**
- Create: `app/lib/service/ai/ambient_ai_pipeline.dart`
- Create: `app/lib/service/ai/ambient_ai_tasks.dart`
- Create: `app/lib/providers/ambient_ai_provider.dart`

**Goal:** A queue-based system for running AI tasks in the background (not tied to chat). Supports priority levels, cancellation, and graceful failure.

- [ ] **Step 1: Define AmbientAiTask model**

Task types: contextBar, memoryBridge, autoTag, summary, glossary, marginNote.
Each task has: id, type, priority, input data, status, result.

- [ ] **Step 2: Create AmbientAiPipeline service**

Queue with priority ordering. Processes one task at a time. Uses existing `aiGenerateStream()` under the hood but with ambient-specific prompts. Injects companion personality into every call.

- [ ] **Step 3: Create ambient AI provider**

Riverpod provider that manages the pipeline lifecycle. Exposes methods like:
- `requestContextBar(bookId, chapterCfi)` → returns cached or generates
- `requestMemoryBridge(bookId)` → returns recap text
- `requestAutoTag(bookId)` → returns generated tags
- Results are cached per book/chapter.

- [ ] **Step 4: Analyze + commit**

---

## Task 3: Context Bar (Reader AI Layer 1)

**Files:**
- Create: `app/lib/widgets/reader/context_bar.dart`
- Modify: `app/lib/page/reader/immersive_reader.dart`

**Goal:** Thin bar at top of reader that shows "Previously: X. This chapter: Y" on chapter change. Auto-generated by AI, falls back to chapter title only.

- [ ] **Step 1: Create ContextBar widget**

Animated fade-in/out bar. Shows AI-generated context or falls back to chapter title.

- [ ] **Step 2: Integrate into ImmersiveReader**

Hook into chapter change events. Request context bar content from ambient pipeline. Show skeleton while loading, fade in when ready.

- [ ] **Step 3: Analyze + commit**

---

## Task 4: Memory Bridge (Desk AI)

**Files:**
- Modify: `app/lib/widgets/desk/hero_book_card.dart`
- Modify: `app/lib/providers/desk_provider.dart`

**Goal:** One-line AI memory recap on the hero card: "上次你读到黑洞的信息悖论..." Falls back to "第7章 · 68%" without AI.

- [ ] **Step 1: Add memory bridge to DeskData**
- [ ] **Step 2: Request memory bridge from ambient pipeline**
- [ ] **Step 3: Display in hero card with fallback**
- [ ] **Step 4: Analyze + commit**

---

## Task 5: Book Import AI Processing

**Files:**
- Modify: `app/lib/service/book.dart` (hook into import flow)

**Goal:** After book import, queue AI tasks: generate one-line summary + auto-tags. Non-blocking — user sees the book immediately, AI processing happens in background.

- [ ] **Step 1: Hook ambient pipeline into import flow**
- [ ] **Step 2: Store AI-generated metadata (tags, summary)**
- [ ] **Step 3: Analyze + commit**

---

## Task 6: Graceful Degradation Framework

**Files:**
- Create: `app/lib/service/ai/ai_availability.dart`
- Create: `app/lib/providers/ai_availability_provider.dart`

**Goal:** Unified check for "is AI available and configured?" All ambient AI widgets use this to decide show/hide.

- [ ] **Step 1: Create AI availability service**

Checks: provider configured? API key valid? Last request succeeded? Returns AiStatus enum (available, unconfigured, error, rateLimit).

- [ ] **Step 2: Create provider**
- [ ] **Step 3: Analyze + commit**

---

## Task 7: Integration & Verification

- [ ] **Step 1: Run full codegen**
- [ ] **Step 2: Flutter analyze**
- [ ] **Step 3: Build APK**
- [ ] **Step 4: E2E test: Configure AI → import book → see auto-tags → open book → see context bar → back to desk → see memory bridge**
- [ ] **Step 5: Final commit**

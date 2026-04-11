# TTS Settings Page Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign TTS settings from "configure engine" to "pick a voice" — voice-first UX with auto engine switching.

**Architecture:** Introduce `VoiceFullId` (source:voiceId) as the universal voice identifier. Aggregate voices from all services into a unified grid. Selecting a voice auto-switches the underlying TTS engine. Model download and API config move to collapsed "Advanced" section. Migrate old `ttsService + voice` config to new format on first load.

**Tech Stack:** Flutter (Riverpod), existing TTS service providers unchanged

**Spec:** `docs/superpowers/specs/2026-04-11-tts-settings-redesign.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `app/lib/service/tts/voice_id.dart` | VoiceFullId model + parsing |
| Modify | `app/lib/config/shared_preference_provider.dart` | Add selectedVoiceFullId + migration |
| Modify | `app/lib/service/tts/tts_factory.dart` | Support auto-switch by voice source |
| Modify | `app/lib/providers/tts_providers.dart` | Aggregate voices from all services |
| Create | `app/lib/widgets/settings/voice_card.dart` | Single voice card widget |
| Create | `app/lib/widgets/settings/voice_section.dart` | Voice section (header + grid) |
| Rewrite | `app/lib/page/settings_page/narrate.dart` | Complete UI rewrite |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | New L10n keys |

---

### Task 1: VoiceFullId model + L10n keys

**Files:**
- Create: `app/lib/service/tts/voice_id.dart`
- Modify: `app/lib/l10n/app_en.arb`
- Modify: `app/lib/l10n/app_zh-CN.arb`

- [ ] **Step 1: Create VoiceFullId model**

Create `app/lib/service/tts/voice_id.dart`:

```dart
/// Universal voice identifier: "source:voiceId" or "source:modelId:speakerId"
/// Examples:
///   edge:zh-CN-XiaoxiaoNeural
///   sherpa:kokoro-multi-lang-v1_0:47
///   azure:en-US-JennyNeural
///   system:com.apple.ttsbundle.Tingting
class VoiceFullId {
  final String source;   // TTS service name: edge, sherpa, azure, etc.
  final String voiceId;  // Voice-specific identifier

  const VoiceFullId({required this.source, required this.voiceId});

  /// Parse from string format "source:voiceId"
  factory VoiceFullId.parse(String fullId) {
    final colonIndex = fullId.indexOf(':');
    if (colonIndex < 0) {
      return VoiceFullId(source: 'edge', voiceId: fullId);
    }
    return VoiceFullId(
      source: fullId.substring(0, colonIndex),
      voiceId: fullId.substring(colonIndex + 1),
    );
  }

  /// Build from TTS service and voice shortName
  factory VoiceFullId.from(String serviceId, String shortName) {
    return VoiceFullId(source: serviceId, voiceId: shortName);
  }

  @override
  String toString() => '$source:$voiceId';

  @override
  bool operator ==(Object other) =>
      other is VoiceFullId && source == other.source && voiceId == other.voiceId;

  @override
  int get hashCode => Object.hash(source, voiceId);
}
```

- [ ] **Step 2: Add L10n keys**

Add to `app_en.arb` before closing `}`:
```json
  "ttsPageTitle": "Read Aloud",
  "ttsPreview": "Preview",
  "ttsPreviewText": "Hello, I am your reading companion.",
  "ttsCurrentVoice": "Current Voice",
  "ttsNoVoiceSelected": "No voice selected",
  "ttsSelectVoice": "Select Voice",
  "ttsLocalOffline": "Local Offline",
  "ttsOnline": "Online",
  "ttsSystemVoice": "System Voice",
  "ttsNoLocalModel": "No local voice model yet",
  "ttsDownloadRecommended": "Download Kokoro v1.0 (recommended)",
  "ttsMoreModels": "More models in Advanced → Model Management",
  "ttsAdvanced": "Advanced Settings",
  "ttsModelManagement": "Model Management",
  "ttsApiConfig": "API Configuration",
  "ttsSpeed": "Speed",
  "ttsMixAudio": "Mix with other audio",
  "ttsNotConfigured": "Not configured",
  "ttsConfigure": "Configure",
  "ttsFetchFailed": "Failed to load voices",
  "ttsRetry": "Retry",
  "ttsChangeVoice": "Change"
```

Add to `app_zh-CN.arb`:
```json
  "ttsPageTitle": "朗读设置",
  "ttsPreview": "试听",
  "ttsPreviewText": "你好，我是你的阅读伴侣。",
  "ttsCurrentVoice": "当前声音",
  "ttsNoVoiceSelected": "未选择声音",
  "ttsSelectVoice": "选择声音",
  "ttsLocalOffline": "本地离线",
  "ttsOnline": "在线声音",
  "ttsSystemVoice": "系统声音",
  "ttsNoLocalModel": "还没有本地语音模型",
  "ttsDownloadRecommended": "下载 Kokoro v1.0（推荐）",
  "ttsMoreModels": "更多模型请在 高级设置 → 模型管理 中查看",
  "ttsAdvanced": "高级设置",
  "ttsModelManagement": "模型管理",
  "ttsApiConfig": "API 配置",
  "ttsSpeed": "语速",
  "ttsMixAudio": "允许混音",
  "ttsNotConfigured": "未配置",
  "ttsConfigure": "去配置",
  "ttsFetchFailed": "加载声音失败",
  "ttsRetry": "重试",
  "ttsChangeVoice": "换"
```

Run: `cd app && flutter gen-l10n`

- [ ] **Step 3: Verify + Commit**

```bash
cd app && flutter analyze lib/service/tts/voice_id.dart
git add app/lib/service/tts/voice_id.dart app/lib/l10n/
git commit -m "feat: add VoiceFullId model and TTS redesign L10n keys"
```

---

### Task 2: Prefs migration + TtsFactory auto-switch

**Files:**
- Modify: `app/lib/config/shared_preference_provider.dart`
- Modify: `app/lib/service/tts/tts_factory.dart`

- [ ] **Step 1: Add selectedVoiceFullId to Prefs**

In `shared_preference_provider.dart`, after the existing TTS methods (around line 433), add:

```dart
  /// New unified voice identifier (source:voiceId format).
  String get selectedVoiceFullId => prefs.getString('selectedVoiceFullId') ?? '';
  set selectedVoiceFullId(String id) => prefs.setString('selectedVoiceFullId', id);

  /// Migrate old ttsService + voice config to new VoiceFullId format.
  /// Called once on first load of new TTS settings.
  String migrateToVoiceFullId() {
    final existing = selectedVoiceFullId;
    if (existing.isNotEmpty) return existing;

    // Build from old config
    final serviceId = ttsService;
    final voice = getTtsVoiceModel(serviceId);
    if (voice.isNotEmpty) {
      final fullId = '$serviceId:$voice';
      selectedVoiceFullId = fullId;
      return fullId;
    }

    // Default: Edge TTS Chinese
    const defaultId = 'edge:zh-CN-XiaoxiaoNeural';
    selectedVoiceFullId = defaultId;
    return defaultId;
  }
```

- [ ] **Step 2: Add switchToVoice method to TtsFactory**

In `tts_factory.dart`, add a method that switches engine based on voice source:

```dart
  /// Switch to the engine matching a VoiceFullId source.
  /// Called automatically when user selects a voice in the new UI.
  Future<void> switchToVoiceSource(String source) async {
    // Map source string to TtsService enum name
    final targetServiceId = source;
    if (Prefs().ttsService == targetServiceId) return;
    await switchTtsType(targetServiceId);
  }
```

Add import at top: `import 'package:omnigram/service/tts/voice_id.dart';`

- [ ] **Step 3: Verify + Commit**

```bash
cd app && flutter analyze lib/config/shared_preference_provider.dart lib/service/tts/tts_factory.dart
git add app/lib/config/shared_preference_provider.dart app/lib/service/tts/tts_factory.dart
git commit -m "feat: add selectedVoiceFullId migration and auto-switch to TtsFactory"
```

---

### Task 3: Aggregated voices provider

**Files:**
- Modify: `app/lib/providers/tts_providers.dart`

- [ ] **Step 1: Add allVoices provider that aggregates across services**

Add a new provider that collects voices from all sources:

```dart
/// Aggregated voice data with source tag for the unified voice grid.
class TaggedVoice {
  final String source;  // Service ID: edge, sherpa, azure, etc.
  final TtsVoice voice;
  final String sourceLabel; // Display label: "Edge", "Kokoro", "Azure"

  const TaggedVoice({required this.source, required this.voice, required this.sourceLabel});

  String get fullId => '$source:${voice.shortName}';
}

@riverpod
Future<Map<String, List<TaggedVoice>>> allVoicesGrouped(Ref ref) async {
  final result = <String, List<TaggedVoice>>{};

  // Local offline (sherpa-onnx)
  try {
    final sherpaVoices = await TtsService.sherpaOnnx.provider.getVoices();
    if (sherpaVoices.isNotEmpty) {
      result['local'] = sherpaVoices
          .map((v) => TaggedVoice(source: 'sherpaOnnx', voice: v, sourceLabel: 'Kokoro'))
          .toList();
    }
  } catch (_) {}

  // Online — Edge (always available)
  try {
    final edgeVoices = await TtsService.edge.provider.getVoices();
    final online = <TaggedVoice>[
      ...edgeVoices.map((v) => TaggedVoice(source: 'edge', voice: v, sourceLabel: 'Edge')),
    ];

    // Server (if configured)
    try {
      final serverVoices = await TtsService.server.provider.getVoices();
      online.addAll(serverVoices.map((v) => TaggedVoice(source: 'server', voice: v, sourceLabel: 'Server')));
    } catch (_) {}

    // Azure (if configured)
    try {
      final azureVoices = await TtsService.azure.provider.getVoices();
      online.addAll(azureVoices.map((v) => TaggedVoice(source: 'azure', voice: v, sourceLabel: 'Azure')));
    } catch (_) {}

    // OpenAI (if configured)
    try {
      final openaiVoices = await TtsService.openai.provider.getVoices();
      online.addAll(openaiVoices.map((v) => TaggedVoice(source: 'openai', voice: v, sourceLabel: 'OpenAI')));
    } catch (_) {}

    // Aliyun (if configured)
    try {
      final aliyunVoices = await TtsService.aliyun.provider.getVoices();
      online.addAll(aliyunVoices.map((v) => TaggedVoice(source: 'aliyun', voice: v, sourceLabel: 'Aliyun')));
    } catch (_) {}

    if (online.isNotEmpty) result['online'] = online;
  } catch (_) {}

  // System
  try {
    final systemVoices = await TtsService.system.provider.getVoices();
    if (systemVoices.isNotEmpty) {
      result['system'] = systemVoices
          .map((v) => TaggedVoice(source: 'system', voice: v, sourceLabel: 'System'))
          .toList();
    }
  } catch (_) {}

  return result;
}
```

Add imports: `import 'package:omnigram/service/tts/tts_service.dart' as tts_svc;` and other needed imports.

Note: This provider needs code generation. After editing, run `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 2: Run codegen + verify**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/providers/tts_providers.dart
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/providers/tts_providers.dart app/lib/providers/tts_providers.g.dart
git commit -m "feat: add allVoicesGrouped provider aggregating all TTS sources"
```

---

### Task 4: VoiceCard + VoiceSection widgets

**Files:**
- Create: `app/lib/widgets/settings/voice_card.dart`
- Create: `app/lib/widgets/settings/voice_section.dart`

- [ ] **Step 1: Create VoiceCard**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/theme/colors.dart';

class VoiceCard extends StatelessWidget {
  final TaggedVoice taggedVoice;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const VoiceCard({
    super.key,
    required this.taggedVoice,
    required this.isSelected,
    this.isPlaying = false,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final v = taggedVoice.voice;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    v.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onPreview,
                  child: Icon(
                    isPlaying ? Icons.stop_circle : Icons.play_circle_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${v.gender.isNotEmpty ? "${v.gender} · " : ""}${v.locale}',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
            ),
            Text(
              taggedVoice.sourceLabel,
              style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create VoiceSection**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/widgets/settings/voice_card.dart';

class VoiceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TaggedVoice> voices;
  final String? selectedFullId;
  final String? playingFullId;
  final ValueChanged<TaggedVoice> onSelect;
  final ValueChanged<TaggedVoice> onPreview;
  final Widget? emptyState;

  const VoiceSection({
    super.key,
    required this.title,
    required this.icon,
    required this.voices,
    this.selectedFullId,
    this.playingFullId,
    required this.onSelect,
    required this.onPreview,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (voices.isEmpty && emptyState != null)
          emptyState!
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: voices.map((tv) => SizedBox(
              width: 110,
              child: VoiceCard(
                taggedVoice: tv,
                isSelected: tv.fullId == selectedFullId,
                isPlaying: tv.fullId == playingFullId,
                onSelect: () => onSelect(tv),
                onPreview: () => onPreview(tv),
              ),
            )).toList(),
          ),
      ],
    );
  }
}
```

- [ ] **Step 3: Verify + Commit**

```bash
cd app && flutter analyze lib/widgets/settings/voice_card.dart lib/widgets/settings/voice_section.dart
git add app/lib/widgets/settings/voice_card.dart app/lib/widgets/settings/voice_section.dart
git commit -m "feat: add VoiceCard and VoiceSection widgets for TTS redesign"
```

---

### Task 5: Rewrite narrate.dart

**Files:**
- Rewrite: `app/lib/page/settings_page/narrate.dart`

This is the core task — complete rewrite of the TTS settings page.

- [ ] **Step 1: Rewrite narrate.dart**

The new `NarrateSettings` page structure:

1. **Preview section** — test text + play button using current voice
2. **Current voice banner** — shows selected voice name + source + "Change" button
3. **Voice selection** — three VoiceSections (local/online/system)
4. **Advanced settings** — ExpansionTile with model management, API config, speed, mix audio

Key implementation points:
- Read `Prefs().migrateToVoiceFullId()` in initState
- Load voices via `ref.watch(allVoicesGroupedProvider)`
- On voice select: parse source from `TaggedVoice.source` → call `TtsFactory().switchToVoiceSource(source)` → save `selectedVoiceFullId` → update provider's selected voice
- Preview: call `OnlineTts().speakWithVoice(text, voice)` or `SystemTts().speak(text)` based on source
- Advanced section: reuse existing `ServiceConfigForm` for API configs, existing model download button for sherpa
- Local empty state: show download recommended button → trigger `TtsModelManager().downloadModel()`

Read the existing `narrate.dart` carefully before rewriting. Preserve:
- `_testSpeak()` error handling with SmartDialog
- Service config form rendering for Azure/OpenAI/Aliyun
- Model download button with progress for sherpa-onnx
- Speed slider (from existing Prefs)
- Mix audio toggle

The file will be large (~600 lines). Structure as:
- `NarrateSettings` ConsumerStatefulWidget
- `_NarrateSettingsState` with preview, voice selection, advanced sections
- `_buildPreviewSection()` — text field + play button
- `_buildCurrentVoice()` — banner showing selected voice
- `_buildVoiceSections()` — three VoiceSection widgets
- `_buildAdvancedSection()` — ExpansionTile with model mgmt + API config + params
- `_buildLocalEmptyState()` — download recommendation
- `_buildApiConfigGroup()` — renders ServiceConfigForm for configured cloud services

- [ ] **Step 2: Run codegen if needed + verify**

```bash
cd app && flutter analyze lib/page/settings_page/narrate.dart
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/page/settings_page/narrate.dart
git commit -m "feat: rewrite TTS settings page with voice-first design"
```

---

### Task 6: Verify + docs

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Full analysis check**

```bash
cd app && flutter analyze lib/
```

- [ ] **Step 2: Update PROGRESS.md**

Add to 更新记录:
```markdown
| 2026-04-11 | **TTS 设置页重设计** ✅：声音优先 UX，VoiceCard 网格，自动切引擎，VoiceFullId 统一标识，旧配置迁移兼容 |
```

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark TTS settings redesign as complete"
```

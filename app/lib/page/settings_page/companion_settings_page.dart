import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/companion_personality.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/service/ai/companion_prompt.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_chip.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/settings/choice_picker_page.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

/// Companion personality + behavior settings. Liquid Glass layout per
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md.
class CompanionSettingsPage extends ConsumerStatefulWidget {
  const CompanionSettingsPage({super.key});

  @override
  ConsumerState<CompanionSettingsPage> createState() =>
      _CompanionSettingsPageState();
}

class _CompanionSettingsPageState extends ConsumerState<CompanionSettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: ref.read(companionProvider).name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final personality = ref.watch(companionProvider);
    final notifier = ref.read(companionProvider.notifier);

    return Scaffold(
      appBar: AppGlassAppBar(title: Text(l10n.companionTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // --- 基本信息 ---
          SettingsSection(
            title: Text(l10n.companionNameLabel),
            tiles: [
              CustomSettingsTile(
                child: _InlineTextRow(
                  label: l10n.companionNameLabel,
                  controller: _nameController,
                  hint: 'TARS',
                  onChanged: notifier.updateName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 性格预览 ---
          SettingsSection(
            title: Text(l10n.companionPreview),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text(
                    CompanionPrompt.previewText(personality),
                    style: OmnigramTypography.bodyLarge(context).copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 性格调节 ---
          SettingsSection(
            title: const Text('性格调节'),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _PersonalitySlider(
                        label: l10n.companionProactivity,
                        lowLabel: l10n.companionQuietAssistant,
                        highLabel: l10n.companionTalkativeScholar,
                        value: personality.proactivity,
                        onChanged: (v) =>
                            notifier.updateProactivity(v.round()),
                      ),
                      _PersonalitySlider(
                        label: l10n.companionStyle,
                        lowLabel: l10n.companionDirectAnswer,
                        highLabel: l10n.companionSocratic,
                        value: personality.style,
                        onChanged: (v) => notifier.updateStyle(v.round()),
                      ),
                      _PersonalitySlider(
                        label: l10n.companionDepth,
                        lowLabel: l10n.companionSimple,
                        highLabel: l10n.companionAcademic,
                        value: personality.depth,
                        onChanged: (v) => notifier.updateDepth(v.round()),
                      ),
                      _PersonalitySlider(
                        label: l10n.companionWarmth,
                        lowLabel: l10n.companionCool,
                        highLabel: l10n.companionWarm,
                        value: personality.warmth,
                        onChanged: (v) => notifier.updateWarmth(v.round()),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 朗读声音 ---
          SettingsSection(
            title: const Text('朗读声音'),
            tiles: [
              _VoiceNavTile(
                currentVoice: personality.voice,
                onChanged: notifier.updateVoice,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 行为开关 ---
          SettingsSection(
            title: Text(l10n.companionBehaviorSection),
            tiles: [
              SettingsTile.switchTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.companionBehaviorCrossBookAlerts),
                initialValue: personality.crossBookAlerts,
                onToggle: notifier.updateCrossBookAlerts,
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.hub_outlined),
                title: Text(l10n.companionBehaviorAutoKnowledgeGraph),
                initialValue: personality.autoKnowledgeGraph,
                onToggle: notifier.updateAutoKnowledgeGraph,
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: Text(l10n.companionBehaviorAnnotateHardWords),
                description: Text(l10n.companionBehaviorComingSoon),
                initialValue: false,
                onToggle: null,
                enabled: false,
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.companionBehaviorAutoChapterRecap),
                description: Text(l10n.companionBehaviorComingSoon),
                initialValue: false,
                onToggle: null,
                enabled: false,
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.quiz_outlined),
                title: Text(l10n.companionBehaviorPostChapterQuestions),
                description: Text(l10n.companionBehaviorComingSoon),
                initialValue: false,
                onToggle: null,
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 预设性格 ---
          SettingsSection(
            title: const Text('预设性格'),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Consumer(builder: (context, ref, _) {
                    final q = ref
                            .watch(glassQualityControllerProvider)
                            .valueOrNull ??
                        GlassQuality.medium;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        GlassChip(
                          quality: q,
                          label: '默默帮忙',
                          selected: false,
                          onTap: () {
                            notifier.applyPreset(CompanionPresets.silent());
                            _nameController.text =
                                ref.read(companionProvider).name;
                          },
                        ),
                        GlassChip(
                          quality: q,
                          label: '读书搭子',
                          selected: false,
                          onTap: () {
                            notifier.applyPreset(CompanionPresets.buddy());
                            _nameController.text =
                                ref.read(companionProvider).name;
                          },
                        ),
                        GlassChip(
                          quality: q,
                          label: '学术导师',
                          selected: false,
                          onTap: () {
                            notifier.applyPreset(CompanionPresets.scholar());
                            _nameController.text =
                                ref.read(companionProvider).name;
                          },
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// iOS-style inline text row: label on left, borderless transparent input on
// right that takes remaining width and right-aligns its text.
// ---------------------------------------------------------------------------

class _InlineTextRow extends StatelessWidget {
  const _InlineTextRow({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: OmnigramTypography.bodyLarge(context)
                  .copyWith(color: scheme.onSurface)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.end,
              cursorColor: scheme.primary,
              style: OmnigramTypography.bodyLarge(context)
                  .copyWith(color: scheme.onSurfaceVariant),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: OmnigramTypography.bodyLarge(context).copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// iOS-style personality slider: label on left, muted trailing value, slider
// below with low/high captions flanking it.
// ---------------------------------------------------------------------------

class _PersonalitySlider extends StatelessWidget {
  final String label;
  final String lowLabel;
  final String highLabel;
  final int value;
  final ValueChanged<double> onChanged;
  final bool isLast;

  const _PersonalitySlider({
    required this.label,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: isLast ? 4 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: OmnigramTypography.bodyLarge(context)
                        .copyWith(color: scheme.onSurface)),
              ),
              Text('$value%',
                  style: OmnigramTypography.bodyLarge(context).copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(lowLabel,
                  style: OmnigramTypography.caption(context)
                      .copyWith(color: scheme.onSurfaceVariant)),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: onChanged,
                ),
              ),
              Text(highLabel,
                  style: OmnigramTypography.caption(context)
                      .copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// iOS-style voice picker tile: shows current voice name on the right; tapping
// pushes a ChoicePicker detail page. Falls back to a disabled row with a
// helper message when the TTS service has no voices configured.
// ---------------------------------------------------------------------------

class _VoiceNavTile extends AbstractSettingsTile {
  const _VoiceNavTile({
    required this.currentVoice,
    required this.onChanged,
  });

  final String currentVoice;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final voicesAsync = ref.watch(ttsVoicesProvider);
      return voicesAsync.when(
      data: (voices) {
        if (voices.isEmpty) {
          return SettingsTile.navigation(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('朗读声音'),
            value: const Text('未配置 TTS 服务'),
            enabled: false,
            onPressed: (_) {},
          );
        }
        final selected = voices.firstWhere(
          (v) => v.shortName == currentVoice,
          orElse: () => voices.first,
        );
        final hasSelection =
            voices.any((v) => v.shortName == currentVoice) && currentVoice.isNotEmpty;
        return SettingsTile.navigation(
          leading: const Icon(Icons.record_voice_over_outlined),
          title: const Text('朗读声音'),
          value: Text(hasSelection ? selected.name : '不关联声音'),
          onPressed: (ctx) async {
            final picked = await pushChoicePicker<String>(
              ctx,
              title: '朗读声音',
              current: currentVoice,
              options: [
                const ChoiceOption(value: '', label: '不关联声音'),
                ...voices.map((v) => ChoiceOption(
                      value: v.shortName,
                      label: v.name,
                      description: v.locale.isEmpty ? null : v.locale,
                    )),
              ],
            );
            if (picked != null) onChanged(picked);
          },
        );
      },
      loading: () => const CustomSettingsTile(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (_, _) => SettingsTile.navigation(
        leading: const Icon(Icons.record_voice_over_outlined),
        title: const Text('朗读声音'),
        value: const Text('加载声音列表失败'),
        enabled: false,
        onPressed: (_) {},
      ),
      );
    });
  }
}

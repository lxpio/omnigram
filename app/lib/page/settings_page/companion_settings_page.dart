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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.companionNameLabel,
                      hintText: 'TARS',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: notifier.updateName,
                  ),
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    CompanionPrompt.previewText(personality),
                    style: OmnigramTypography.bodyLarge(context)
                        .copyWith(fontStyle: FontStyle.italic),
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
                      horizontal: 16, vertical: 12),
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
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: _VoiceSelector(
                    currentVoice: personality.voice,
                    onChanged: notifier.updateVoice,
                  ),
                ),
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
                      horizontal: 16, vertical: 14),
                  child: Consumer(builder: (context, ref, _) {
                    final q = ref
                            .watch(glassQualityControllerProvider)
                            .valueOrNull ??
                        GlassQuality.medium;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
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

class _PersonalitySlider extends StatelessWidget {
  final String label;
  final String lowLabel;
  final String highLabel;
  final int value;
  final ValueChanged<double> onChanged;

  const _PersonalitySlider({
    required this.label,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value%',
              style: OmnigramTypography.titleMedium(context)),
          Row(
            children: [
              Text(lowLabel, style: OmnigramTypography.caption(context)),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: onChanged,
                ),
              ),
              Text(highLabel, style: OmnigramTypography.caption(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceSelector extends ConsumerWidget {
  final String currentVoice;
  final ValueChanged<String> onChanged;
  const _VoiceSelector(
      {required this.currentVoice, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(ttsVoicesProvider);
    return voicesAsync.when(
      data: (voices) {
        if (voices.isEmpty) {
          return Text('未配置 TTS 服务',
              style: OmnigramTypography.caption(context));
        }
        return DropdownButtonFormField<String>(
          initialValue:
              voices.any((v) => v.shortName == currentVoice) ? currentVoice : null,
          decoration: const InputDecoration(
            hintText: '选择伴侣朗读声音',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('不关联声音')),
            ...voices.map((v) => DropdownMenuItem(
                  value: v.shortName,
                  child: Text(v.name),
                )),
          ],
          onChanged: (v) => onChanged(v ?? ''),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) =>
          Text('加载声音列表失败', style: OmnigramTypography.caption(context)),
    );
  }
}

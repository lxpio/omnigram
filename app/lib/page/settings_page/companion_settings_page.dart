import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/models/companion_personality.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/service/ai/companion_prompt.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class CompanionSettingsPage extends ConsumerStatefulWidget {
  const CompanionSettingsPage({super.key});

  @override
  ConsumerState<CompanionSettingsPage> createState() => _CompanionSettingsPageState();
}

class _CompanionSettingsPageState extends ConsumerState<CompanionSettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ref.read(companionProvider).name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personality = ref.watch(companionProvider);
    final notifier = ref.read(companionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('阅读伴侣')),
      body: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          // Name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '伴侣名称', hintText: 'TARS'),
            onChanged: notifier.updateName,
          ),
          const SizedBox(height: 24),

          // Live preview
          OmnigramCard(
            backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('预览', style: OmnigramTypography.caption(context)),
                const SizedBox(height: 8),
                Text(
                  CompanionPrompt.previewText(personality),
                  style: OmnigramTypography.bodyLarge(context).copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sliders
          _PersonalitySlider(
            label: '主动性',
            lowLabel: '安静助手',
            highLabel: '健谈学者',
            value: personality.proactivity,
            onChanged: (v) => notifier.updateProactivity(v.round()),
          ),
          _PersonalitySlider(
            label: '风格',
            lowLabel: '直接回答',
            highLabel: '苏格拉底式',
            value: personality.style,
            onChanged: (v) => notifier.updateStyle(v.round()),
          ),
          _PersonalitySlider(
            label: '深度',
            lowLabel: '通俗易懂',
            highLabel: '学术分析',
            value: personality.depth,
            onChanged: (v) => notifier.updateDepth(v.round()),
          ),
          _PersonalitySlider(
            label: '温度',
            lowLabel: '冷静客观',
            highLabel: '热情投入',
            value: personality.warmth,
            onChanged: (v) => notifier.updateWarmth(v.round()),
          ),
          const SizedBox(height: 24),

          // Voice selector
          Text('朗读声音', style: OmnigramTypography.titleMedium(context)),
          const SizedBox(height: 8),
          _VoiceSelector(
            currentVoice: personality.voice,
            onChanged: notifier.updateVoice,
          ),
          const SizedBox(height: 24),

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

          // Presets
          Text('预设性格', style: OmnigramTypography.titleMedium(context)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _PresetChip(
                label: '默默帮忙',
                onTap: () {
                  notifier.applyPreset(CompanionPresets.silent());
                  _nameController.text = ref.read(companionProvider).name;
                },
              ),
              _PresetChip(
                label: '读书搭子',
                onTap: () {
                  notifier.applyPreset(CompanionPresets.buddy());
                  _nameController.text = ref.read(companionProvider).name;
                },
              ),
              _PresetChip(
                label: '学术导师',
                onTap: () {
                  notifier.applyPreset(CompanionPresets.scholar());
                  _nameController.text = ref.read(companionProvider).name;
                },
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value%', style: OmnigramTypography.titleMedium(context)),
          Row(
            children: [
              Text(lowLabel, style: OmnigramTypography.caption(context)),
              Expanded(
                child: Slider(value: value.toDouble(), min: 0, max: 100, divisions: 20, onChanged: onChanged),
              ),
              Text(highLabel, style: OmnigramTypography.caption(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _VoiceSelector extends ConsumerWidget {
  final String currentVoice;
  final ValueChanged<String> onChanged;
  const _VoiceSelector({required this.currentVoice, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(ttsVoicesProvider);
    return voicesAsync.when(
      data: (voices) {
        if (voices.isEmpty) {
          return Text('未配置 TTS 服务', style: OmnigramTypography.caption(context));
        }
        return DropdownButtonFormField<String>(
          value: voices.any((v) => v.shortName == currentVoice) ? currentVoice : null,
          decoration: const InputDecoration(
            hintText: '选择伴侣朗读声音',
            border: OutlineInputBorder(),
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
      error: (_, __) => Text('加载声音列表失败', style: OmnigramTypography.caption(context)),
    );
  }
}

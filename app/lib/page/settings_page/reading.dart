import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/widgets/reading_page/more_settings/other_settings.dart';
import 'package:omnigram/widgets/reading_page/more_settings/reading_settings.dart';
import 'package:omnigram/widgets/reading_page/more_settings/style_settings.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';
import 'package:omnigram/widgets/settings/settings_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingSettings extends ConsumerStatefulWidget {
  const ReadingSettings({super.key});

  @override
  ConsumerState<ReadingSettings> createState() => _ReadingSettingsState();
}

class _ReadingSettingsState extends ConsumerState<ReadingSettings> {
  @override
  Widget build(BuildContext context) {
    return settingsSections(sections: [
      SettingsSection(title: Text(L10n.of(context).readingPageReading), tiles: [
        CustomSettingsTile(child: ReadingMoreSettings()),
      ]),
      SettingsSection(title: Text(L10n.of(context).readingPageStyle), tiles: [
        CustomSettingsTile(child: StyleSettings()),
      ]),
      SettingsSection(title: Text(L10n.of(context).readingPageOther), tiles: [
        CustomSettingsTile(child: OtherSettings()),
      ]),
      SettingsSection(title: const Text('视觉效果'), tiles: [
        CustomSettingsTile(
          child: Consumer(
            builder: (context, ref, _) {
              final overrideAsync = ref.watch(glassQualityOverrideProvider);
              final notifier = ref.read(glassQualityControllerProvider.notifier);
              return SettingsTile(
                title: const Text('视觉质量'),
                description: const Text('在阅读页会自动降低一档以保证翻页流畅。'),
                trailing: overrideAsync.when(
                  data: (current) => DropdownButton<GlassQualityOverride>(
                    value: current,
                    underline: const SizedBox(),
                    items: GlassQualityOverride.values
                        .map((o) => DropdownMenuItem(
                              value: o,
                              child: Text(_glassQualityLabel(o)),
                            ))
                        .toList(),
                    onChanged: (o) {
                      if (o != null) notifier.setOverride(o);
                    },
                  ),
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => const Text('—'),
                ),
              );
            },
          ),
        ),
      ]),
    ]);
  }
}

String _glassQualityLabel(GlassQualityOverride o) => switch (o) {
      GlassQualityOverride.auto => '自动（推荐）',
      GlassQualityOverride.high => '完整玻璃',
      GlassQualityOverride.medium => '平衡（关闭模糊）',
      GlassQualityOverride.low => '省电（关闭动效）',
    };

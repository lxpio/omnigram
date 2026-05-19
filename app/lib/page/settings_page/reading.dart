import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/widgets/reading_page/more_settings/other_settings.dart';
import 'package:omnigram/widgets/reading_page/more_settings/reading_settings.dart';
import 'package:omnigram/widgets/reading_page/more_settings/style_settings.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

/// "阅读体验" detail page. Each child widget self-emits its own
/// SettingsSection card(s) so the list is a flat stack of glass groups.
class ReadingSettings extends ConsumerWidget {
  const ReadingSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('阅读体验')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          ReadingMoreSettings(),
          SizedBox(height: 12),
          StyleSettings(),
          SizedBox(height: 12),
          OtherSettings(),
          SizedBox(height: 12),
          _VisualEffectsSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VisualEffectsSection extends StatelessWidget {
  const _VisualEffectsSection();

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: const Text('视觉效果'),
      tiles: [
        CustomSettingsTile(
          child: Consumer(builder: (context, ref, _) {
            final overrideAsync = ref.watch(glassQualityOverrideProvider);
            final notifier =
                ref.read(glassQualityControllerProvider.notifier);
            return SettingsTile(
              leading: const Icon(Icons.tune),
              title: const Text('视觉质量'),
              description:
                  const Text('在阅读页会自动降低一档以保证翻页流畅。'),
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
          }),
        ),
      ],
    );
  }
}

String _glassQualityLabel(GlassQualityOverride o) => switch (o) {
      GlassQualityOverride.auto => '自动（推荐）',
      GlassQualityOverride.high => '完整玻璃',
      GlassQualityOverride.medium => '平衡（关闭模糊）',
      GlassQualityOverride.low => '省电（关闭动效）',
    };

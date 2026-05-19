import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_chip.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

/// Keys for selective sync preferences (B-3).
class SyncFilterKeys {
  static const enabledShelves = 'sync_filter_shelves';
  static const enabledTags = 'sync_filter_tags';
  static const syncAll = 'sync_filter_all';
}

/// Selective sync settings page (B-3) — Liquid Glass layout per
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md
/// Phase 5.
class SelectiveSyncPage extends ConsumerStatefulWidget {
  const SelectiveSyncPage({super.key});

  @override
  ConsumerState<SelectiveSyncPage> createState() => _SelectiveSyncPageState();
}

class _SelectiveSyncPageState extends ConsumerState<SelectiveSyncPage> {
  bool _syncAll = true;
  List<String> _enabledShelves = [];
  List<String> _enabledTags = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncAll = prefs.getBool(SyncFilterKeys.syncAll) ?? true;
      _enabledShelves =
          prefs.getStringList(SyncFilterKeys.enabledShelves) ?? [];
      _enabledTags = prefs.getStringList(SyncFilterKeys.enabledTags) ?? [];
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SyncFilterKeys.syncAll, _syncAll);
    await prefs.setStringList(SyncFilterKeys.enabledShelves, _enabledShelves);
    await prefs.setStringList(SyncFilterKeys.enabledTags, _enabledTags);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('选择性同步')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SettingsSection(
            tiles: [
              SettingsTile.switchTile(
                leading: const Icon(Icons.cloud_sync_outlined),
                title: const Text('同步全部书籍'),
                description: const Text('关闭后可按书架 / 标签筛选同步内容'),
                initialValue: _syncAll,
                onToggle: (v) {
                  setState(() => _syncAll = v);
                  _savePrefs();
                },
              ),
            ],
          ),
          if (!_syncAll) ...[
            const SizedBox(height: 12),
            SettingsSection(
              title: const Text('同步书架'),
              tiles: [
                CustomSettingsTile(
                  child: _ChipWrap(
                    labels: _enabledShelves,
                    emptyHint: '暂无书架筛选，同步时将包含所有书架',
                    onDelete: (s) {
                      setState(() => _enabledShelves.remove(s));
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSection(
              title: const Text('同步标签'),
              tiles: [
                CustomSettingsTile(
                  child: _ChipWrap(
                    labels: _enabledTags,
                    emptyHint: '暂无标签筛选，同步时将包含所有标签',
                    onDelete: (t) {
                      setState(() => _enabledTags.remove(t));
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '选择性同步仅影响从服务端拉取的数据范围。本地所有书籍仍会推送到服务端。',
                    style: OmnigramTypography.caption(context)
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.labels,
    required this.emptyHint,
    required this.onDelete,
  });

  final List<String> labels;
  final String emptyHint;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          emptyHint,
          style: OmnigramTypography.caption(context).copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Consumer(builder: (context, ref, _) {
        final q = ref.watch(glassQualityControllerProvider).valueOrNull ??
            GlassQuality.medium;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels
              .map((s) => GlassChip(
                    quality: q,
                    label: s,
                    selected: true,
                    onTap: () => onDelete(s),
                  ))
              .toList(),
        );
      }),
    );
  }
}

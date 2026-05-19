import 'package:flutter/material.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/page_turn_mode.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:omnigram/utils/ui/status_bar.dart';
import 'package:omnigram/widgets/common/anx_segmented_button.dart';
import 'package:omnigram/widgets/reading_page/more_settings/page_turning/diagram.dart';
import 'package:omnigram/widgets/reading_page/more_settings/page_turning/page_turn_dropdown.dart';
import 'package:omnigram/widgets/reading_page/more_settings/page_turning/types_and_icons.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';
import 'package:omnigram/widgets/settings/slider_detail_page.dart';

/// Reader "其他" preferences, split into 3 Liquid Glass cards:
///   翻页 / 屏幕 / AI 辅助.
class OtherSettings extends StatefulWidget {
  const OtherSettings({super.key});

  @override
  State<OtherSettings> createState() => _OtherSettingsState();
}

class _OtherSettingsState extends State<OtherSettings> {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      children: [
        // ---------------- 翻页 ----------------
        SettingsSection(
          title: const Text('翻页'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: Text(l10n.readingPagePageTurningMethod),
              onPressed: (_) => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const _PageTurnDetailPage()),
              ).then((_) => setState(() {})),
            ),
            if (AnxPlatform.isAndroid)
              SettingsTile.switchTile(
                leading: const Icon(Icons.add_box_outlined),
                title: Text(l10n.readingPageVolumeKeyTurnPage),
                initialValue: Prefs().volumeKeyTurnPage,
                onToggle: (v) =>
                    setState(() => Prefs().volumeKeyTurnPage = v),
              ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.swap_horizontal_circle_outlined),
              title: Text(l10n.readingPageSwapPageTurnArea),
              description: Text(l10n.readingPageSwapPageTurnAreaTips),
              initialValue: Prefs().swapPageTurnArea,
              onToggle: (v) =>
                  setState(() => Prefs().swapPageTurnArea = v),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.touch_app_outlined),
              title: Text(l10n.readingPageShowMenuOnHover),
              description: Text(l10n.readingPageShowMenuOnHoverTips),
              initialValue: Prefs().showMenuOnHover,
              onToggle: (v) => setState(() => Prefs().showMenuOnHover = v),
            ),
            if (AnxPlatform.isDesktop)
              SettingsTile.switchTile(
                leading: const Icon(Icons.keyboard_outlined),
                title: Text(l10n.readingPageKeyboardShortcutTurnPage),
                description:
                    Text(l10n.readingPageKeyboardShortcutTurnPageTips),
                initialValue: Prefs().keyboardShortcutTurnPage,
                onToggle: (v) =>
                    setState(() => Prefs().keyboardShortcutTurnPage = v),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ---------------- 屏幕 ----------------
        SettingsSection(
          title: const Text('屏幕'),
          tiles: [
            SettingsTile.switchTile(
              leading: const Icon(Icons.fullscreen),
              title: Text(l10n.readingPageFullScreen),
              initialValue: Prefs().hideStatusBar,
              onToggle: (v) {
                setState(() {
                  Prefs().saveHideStatusBar(v);
                  v ? hideStatusBar() : showStatusBar();
                });
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l10n.readingPageScreenTimeout),
              value: Text(l10n.commonMinutes(Prefs().awakeTime)),
              onPressed: (_) => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => SliderDetailPage(
                    title: l10n.readingPageScreenTimeout,
                    initial: Prefs().awakeTime.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 60,
                    unitSuffix: ' 分钟',
                    onChanged: (v) {
                      Prefs().awakeTime = v.toInt();
                      readingPageKey.currentState
                          ?.setAwakeTimer(v.toInt());
                    },
                  ),
                ),
              ).then((_) => setState(() {})),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: Text(l10n.readingPageAutoAdjustReadingTheme),
              description:
                  Text(l10n.readingPageAutoAdjustReadingThemeTips),
              initialValue: Prefs().autoAdjustReadingTheme,
              onToggle: (v) =>
                  setState(() => Prefs().autoAdjustReadingTheme = v),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ---------------- AI 辅助 ----------------
        SettingsSection(
          title: const Text('AI 辅助'),
          tiles: [
            SettingsTile.switchTile(
              leading: const Icon(Icons.translate_outlined),
              title: Text(l10n.readingPageAutoTranslateSelection),
              initialValue: Prefs().autoTranslateSelection,
              onToggle: (v) =>
                  setState(() => Prefs().autoTranslateSelection = v),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(l10n.readingPageAutoMarkSelection),
              description: Text(l10n.readingPageAutoMarkSelectionTips),
              initialValue: Prefs().autoMarkSelection,
              onToggle: (v) =>
                  setState(() => Prefs().autoMarkSelection = v),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.short_text),
              title: Text(l10n.readingPageAutoSummaryPreviousContent),
              initialValue: Prefs().autoSummaryPreviousContent,
              onToggle: (v) =>
                  setState(() => Prefs().autoSummaryPreviousContent = v),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// 翻页方式 detail page (segmented + diagram or 3×3 dropdown grid)
// ---------------------------------------------------------------

class _PageTurnDetailPage extends StatefulWidget {
  const _PageTurnDetailPage();

  @override
  State<_PageTurnDetailPage> createState() => _PageTurnDetailPageState();
}

class _PageTurnDetailPageState extends State<_PageTurnDetailPage> {
  late int _currentType = Prefs().pageTurningType;
  late PageTurnMode _currentMode = PageTurnMode.fromCode(Prefs().pageTurnMode);
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTypeTap(int index) {
    setState(() {
      Prefs().pageTurningType = index;
      _currentType = index;
    });
  }

  void _onModeChanged(Set<PageTurnMode> selected) {
    setState(() {
      _currentMode = selected.first;
      Prefs().pageTurnMode = selected.first.code;
    });
  }

  void _onCustomConfigChanged(int index, PageTurningType type) {
    final config = Prefs().customPageTurnConfig;
    config[index] = type.index;
    Prefs().customPageTurnConfig = config;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppGlassAppBar(title: Text(l10n.readingPagePageTurningMethod)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnxSegmentedButton<PageTurnMode>(
                segments: [
                  SegmentButtonItem(
                    value: PageTurnMode.simple,
                    label: l10n.pageTurnModeSimple,
                  ),
                  SegmentButtonItem(
                    value: PageTurnMode.custom,
                    label: l10n.pageTurnModeCustom,
                  ),
                ],
                selected: {_currentMode},
                onSelectionChanged: _onModeChanged,
              ),
              const SizedBox(height: 16),
              if (_currentMode == PageTurnMode.simple)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: pageTurningTypes.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: getPageTurningDiagram(
                          context,
                          pageTurningTypes[index],
                          pageTurningIcons[index],
                          _currentType == index,
                          () => _onTypeTap(index),
                        ),
                      );
                    },
                  ),
                )
              else ...[
                Text(l10n.customPageTurnConfig,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                for (int row = 0; row < 3; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        for (int col = 0; col < 3; col++)
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: col < 2 ? 8 : 0),
                              child: Builder(builder: (context) {
                                final index = row * 3 + col;
                                final config = Prefs().customPageTurnConfig;
                                return PageTurnDropdown(
                                  value: PageTurningType
                                      .values[config[index]],
                                  onChanged: (type) {
                                    if (type != null) {
                                      setState(() =>
                                          _onCustomConfigChanged(index, type));
                                    }
                                  },
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

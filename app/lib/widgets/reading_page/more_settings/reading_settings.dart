import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/code_highlight_theme.dart';
import 'package:omnigram/enums/convert_chinese_mode.dart';
import 'package:omnigram/enums/reading_info.dart';
import 'package:omnigram/enums/translation_mode.dart';
import 'package:omnigram/enums/writing_mode.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/reading_info.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/page/settings_page/subpage/fonts.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/widgets/common/anx_segmented_button.dart';
import 'package:omnigram/widgets/settings/choice_picker_page.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';
import 'package:omnigram/widgets/settings/slider_detail_page.dart';

/// Reader preferences — top section under "阅读" on the settings page.
///
/// Every row is a SettingsTile.navigation that shows the current value
/// inline and pushes a detail page with the original control widget
/// (AnxSegmentedButton / Slider / theme picker). Visual style matches
/// the rest of the Liquid Glass settings chrome.
class ReadingMoreSettings extends StatefulWidget {
  const ReadingMoreSettings({super.key});

  @override
  State<ReadingMoreSettings> createState() => _ReadingMoreSettingsState();
}

class _ReadingMoreSettingsState extends State<ReadingMoreSettings> {
  bool get _isReading =>
      epubPlayerKey.currentState != null && epubPlayerKey.currentState!.mounted;

  String _writingModeLabel(BuildContext c, WritingModeEnum v) {
    if (v.isVertical) return L10n.of(c).readingPageWritingDirectionVertical;
    if (v.isHorizontal) return L10n.of(c).readingPageWritingDirectionHorizontal;
    return L10n.of(c).readingPageWritingDirectionAuto;
  }

  String _columnCountLabel(BuildContext c, int v) {
    if (v == 0) return L10n.of(c).readingPageAuto;
    if (v == 1) return L10n.of(c).readingPageSingle;
    return L10n.of(c).readingPageDouble;
  }

  String _translationLabel(BuildContext c, TranslationModeEnum v) {
    switch (v) {
      case TranslationModeEnum.off:
      case TranslationModeEnum.originalOnly:
        return L10n.of(c).readingPageOriginal;
      case TranslationModeEnum.translationOnly:
        return L10n.of(c).translationOnly;
      case TranslationModeEnum.bilingual:
        return L10n.of(c).bilingual;
    }
  }

  String _convertChineseLabel(BuildContext c, ConvertChineseMode v) {
    switch (v) {
      case ConvertChineseMode.none:
        return L10n.of(c).readingPageOriginal;
      case ConvertChineseMode.t2s:
        return L10n.of(c).readingPageSimplified;
      case ConvertChineseMode.s2t:
        return L10n.of(c).readingPageTraditional;
    }
  }

  String _codeHighlightLabel(BuildContext c) {
    final t = Prefs().codeHighlightTheme;
    if (t == CodeHighlightThemeEnum.off) return L10n.of(c).codeHighlightOff;
    return t.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final bookStyle = Prefs().bookStyle;
    final currentTranslation = _isReading
        ? Prefs().getBookTranslationMode(
            epubPlayerKey.currentState!.widget.book.id,
          )
        : TranslationModeEnum.off;

    return SettingsSection(
      title: Text(l10n.readingPageReading),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.font_download_outlined),
          title: Text(l10n.downloadFonts),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FontsSettingPage()),
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Bootstrap.arrows),
          title: Text(l10n.readingPageWritingDirection),
          value: Text(_writingModeLabel(context, Prefs().writingMode)),
          onPressed: (_) async {
            final picked = await pushChoicePicker<WritingModeEnum>(
              context,
              title: l10n.readingPageWritingDirection,
              current: Prefs().writingMode,
              options: [
                ChoiceOption(
                  value: WritingModeEnum.auto,
                  label: l10n.readingPageWritingDirectionAuto,
                  icon: EvaIcons.activity_outline,
                ),
                ChoiceOption(
                  value: WritingModeEnum.verticalRl,
                  label: l10n.readingPageWritingDirectionVertical,
                  icon: Bootstrap.arrows_vertical,
                ),
                ChoiceOption(
                  value: WritingModeEnum.horizontalTb,
                  label: l10n.readingPageWritingDirectionHorizontal,
                  icon: Bootstrap.arrows,
                ),
              ],
            );
            if (picked == null) return;
            setState(() {
              Prefs().writingMode = picked;
              final newStyle = Prefs().bookStyle.copyWith(maxColumnCount: 1);
              Prefs().saveBookStyleToPrefs(newStyle);
              epubPlayerKey.currentState?.changeStyle(newStyle);
            });
          },
        ),
        if (_isReading)
          SettingsTile.navigation(
            leading: const Icon(Icons.translate_outlined),
            title: Text(l10n.translationMode),
            value: Text(_translationLabel(context, currentTranslation)),
            onPressed: (_) async {
              final picked = await pushChoicePicker<TranslationModeEnum>(
                context,
                title: l10n.translationMode,
                current: currentTranslation,
                options: [
                  ChoiceOption(
                    value: TranslationModeEnum.off,
                    label: l10n.readingPageOriginal,
                    icon: Icons.translate_outlined,
                  ),
                  ChoiceOption(
                    value: TranslationModeEnum.translationOnly,
                    label: l10n.translationOnly,
                    icon: Icons.g_translate,
                  ),
                  ChoiceOption(
                    value: TranslationModeEnum.bilingual,
                    label: l10n.bilingual,
                    icon: Icons.compare,
                  ),
                ],
              );
              if (picked == null) return;
              setState(() {
                final id = epubPlayerKey.currentState!.widget.book.id;
                Prefs().setBookTranslationMode(id, picked);
                epubPlayerKey.currentState?.setTranslationMode(picked);
              });
            },
          ),
        SettingsTile.navigation(
          leading: const Icon(EvaIcons.book_open),
          title: Text(l10n.readingPageColumnCount),
          value: Text(_columnCountLabel(context, bookStyle.maxColumnCount)),
          onPressed: (_) async {
            final picked = await pushChoicePicker<int>(
              context,
              title: l10n.readingPageColumnCount,
              current: bookStyle.maxColumnCount,
              options: [
                ChoiceOption(
                  value: 0,
                  label: l10n.readingPageAuto,
                  icon: Icons.auto_awesome,
                ),
                ChoiceOption(
                  value: 1,
                  label: l10n.readingPageSingle,
                  icon: EvaIcons.book,
                ),
                ChoiceOption(
                  value: 2,
                  label: l10n.readingPageDouble,
                  icon: EvaIcons.book_open,
                ),
              ],
            );
            if (picked == null) return;
            setState(() {
              final newStyle =
                  Prefs().bookStyle.copyWith(maxColumnCount: picked);
              Prefs().saveBookStyleToPrefs(newStyle);
              epubPlayerKey.currentState?.changeStyle(newStyle);
            });
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.view_column_outlined),
          title: Text(l10n.readingPageColumnThreshold),
          value: Text('${bookStyle.columnThreshold.toInt()} px'),
          enabled: bookStyle.maxColumnCount == 0,
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => SliderDetailPage(
                title: l10n.readingPageColumnThreshold,
                helpText: l10n.readingPageColumnThresholdTip,
                initial: bookStyle.columnThreshold,
                min: 400,
                max: 1200,
                divisions: 40,
                unitSuffix: 'px',
                onChanged: (v) {
                  final newStyle =
                      Prefs().bookStyle.copyWith(columnThreshold: v);
                  Prefs().saveBookStyleToPrefs(newStyle);
                  epubPlayerKey.currentState?.changeStyle(newStyle);
                },
              ),
            ),
          ).then((_) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.translate),
          title: Text(l10n.readingPageConvertChinese),
          value: Text(_convertChineseLabel(
              context, Prefs().readingRules.convertChineseMode)),
          onPressed: (_) async {
            final picked = await pushChoicePicker<ConvertChineseMode>(
              context,
              title: l10n.readingPageConvertChinese,
              current: Prefs().readingRules.convertChineseMode,
              options: [
                ChoiceOption(
                  value: ConvertChineseMode.none,
                  label: l10n.readingPageOriginal,
                ),
                ChoiceOption(
                  value: ConvertChineseMode.t2s,
                  label: l10n.readingPageSimplified,
                  description: l10n.readingPageConvertChineseTips,
                ),
                ChoiceOption(
                  value: ConvertChineseMode.s2t,
                  label: l10n.readingPageTraditional,
                  description: l10n.readingPageConvertChineseTips,
                ),
              ],
            );
            if (picked == null) return;
            setState(() {
              Prefs().readingRules =
                  Prefs().readingRules.copyWith(convertChineseMode: picked);
              epubPlayerKey.currentState
                  ?.changeReadingRules(Prefs().readingRules);
            });
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.code),
          title: Text(l10n.codeHighlightTheme),
          value: Text(_codeHighlightLabel(context)),
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => CodeHighlightDetailPage(
                onChanged: () => setState(() {}),
              ),
            ),
          ).then((_) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.readingPageReadingInfo),
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => const ReadingInfoDetailPage(),
            ),
          ).then((_) => setState(() {})),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// Detail pages
// ---------------------------------------------------------------

class CodeHighlightDetailPage extends StatefulWidget {
  const CodeHighlightDetailPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<CodeHighlightDetailPage> createState() =>
      _CodeHighlightDetailPageState();
}

class _CodeHighlightDetailPageState extends State<CodeHighlightDetailPage> {
  static const _lightThemes = [
    CodeHighlightThemeEnum.defaultTheme,
    CodeHighlightThemeEnum.github,
    CodeHighlightThemeEnum.oneLight,
    CodeHighlightThemeEnum.materialLight,
  ];

  static const _darkThemes = [
    CodeHighlightThemeEnum.vsDark,
    CodeHighlightThemeEnum.oneDark,
    CodeHighlightThemeEnum.dracula,
    CodeHighlightThemeEnum.materialDark,
    CodeHighlightThemeEnum.nord,
    CodeHighlightThemeEnum.nightOwl,
    CodeHighlightThemeEnum.solarizedDark,
    CodeHighlightThemeEnum.atomDark,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final current = Prefs().codeHighlightTheme;
    return Scaffold(
      appBar: AppGlassAppBar(title: Text(l10n.codeHighlightTheme)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AnxSegmentedButton<String>(
              segments: [
                SegmentButtonItem(
                  label: l10n.codeHighlightOff,
                  value: 'off',
                  icon: const Icon(Icons.code_off),
                ),
                SegmentButtonItem(
                  label: l10n.codeHighlightLight,
                  value: 'light',
                  icon: const Icon(Icons.light_mode),
                ),
                SegmentButtonItem(
                  label: l10n.codeHighlightDark,
                  value: 'dark',
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {
                current == CodeHighlightThemeEnum.off
                    ? 'off'
                    : current.isLight
                        ? 'light'
                        : 'dark'
              },
              onSelectionChanged: (value) {
                setState(() {
                  if (value.first == 'off') {
                    Prefs().codeHighlightTheme = CodeHighlightThemeEnum.off;
                  } else if (value.first == 'light') {
                    Prefs().codeHighlightTheme =
                        CodeHighlightThemeEnum.defaultTheme;
                  } else {
                    Prefs().codeHighlightTheme = CodeHighlightThemeEnum.vsDark;
                  }
                  epubPlayerKey.currentState?.changeStyle(null);
                  widget.onChanged();
                });
              },
            ),
            if (current != CodeHighlightThemeEnum.off) ...[
              const SizedBox(height: 24),
              Text(
                current.isLight
                    ? l10n.codeHighlightLightThemes
                    : l10n.codeHighlightDarkThemes,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (current.isLight ? _lightThemes : _darkThemes)
                    .map((t) => ChoiceChip(
                          label: Text(t.displayName),
                          selected: current == t,
                          onSelected: (s) {
                            if (!s) return;
                            setState(() {
                              Prefs().codeHighlightTheme = t;
                              epubPlayerKey.currentState?.changeStyle(null);
                              widget.onChanged();
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReadingInfoDetailPage extends StatefulWidget {
  const ReadingInfoDetailPage({super.key});

  @override
  State<ReadingInfoDetailPage> createState() => _ReadingInfoDetailPageState();
}

class _ReadingInfoDetailPageState extends State<ReadingInfoDetailPage> {
  void _commit(ReadingInfoModel info) {
    Prefs().readingInfo = info;
    epubPlayerKey.currentState?.changeReadingInfo();
  }

  Widget _slot(
    BuildContext context,
    String label,
    ReadingInfoEnum value,
    ValueChanged<ReadingInfoEnum> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        DropdownButton<ReadingInfoEnum>(
          isDense: true,
          isExpanded: true,
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: ReadingInfoEnum.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
              .toList(),
        ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(0),
            onChanged: (v) {
              setState(() {
                onChanged(v);
                epubPlayerKey.currentState?.changeReadingInfo();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionGroup({
    required String title,
    required ReadingInfoSectionModel section,
    required ValueChanged<ReadingInfoSectionModel> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _slot(
                context,
                L10n.of(context).readingPageLeft,
                section.left,
                (v) => setState(() => onChanged(section.copyWith(left: v))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _slot(
                context,
                L10n.of(context).readingPageCenter,
                section.center,
                (v) => setState(() => onChanged(section.copyWith(center: v))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _slot(
                context,
                L10n.of(context).readingPageRight,
                section.right,
                (v) => setState(() => onChanged(section.copyWith(right: v))),
              ),
            ),
          ],
        ),
        _slider(
          label: L10n.of(context).readingSettingsMargin,
          value: section.verticalMargin,
          min: 0,
          max: 80,
          divisions: 40,
          onChanged: (v) => onChanged(section.copyWith(verticalMargin: v)),
        ),
        _slider(
          label: L10n.of(context).readingPageLeftMargin,
          value: section.leftMargin,
          min: 0,
          max: 80,
          divisions: 40,
          onChanged: (v) => onChanged(section.copyWith(leftMargin: v)),
        ),
        _slider(
          label: L10n.of(context).readingPageRightMargin,
          value: section.rightMargin,
          min: 0,
          max: 80,
          divisions: 40,
          onChanged: (v) => onChanged(section.copyWith(rightMargin: v)),
        ),
        _slider(
          label: L10n.of(context).readingPageFontSize,
          value: section.fontSize,
          min: 8,
          max: 24,
          divisions: 16,
          onChanged: (v) => onChanged(section.copyWith(fontSize: v)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = Prefs().readingInfo;
    return Scaffold(
      appBar:
          AppGlassAppBar(title: Text(L10n.of(context).readingPageReadingInfo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionGroup(
              title: L10n.of(context).readingPageHeaderSettings,
              section: info.header,
              onChanged: (s) => _commit(info.copyWith(header: s)),
            ),
            const Divider(height: 32),
            _sectionGroup(
              title: L10n.of(context).readingPageFooterSettings,
              section: info.footer,
              onChanged: (s) => _commit(info.copyWith(footer: s)),
            ),
          ],
        ),
      ),
    );
  }
}

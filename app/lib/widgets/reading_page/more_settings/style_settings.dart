import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/text_alignment.dart';
import 'package:omnigram/enums/writing_mode.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book_style.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/widgets/reading_page/more_settings/custom_css_editor.dart';
import 'package:omnigram/widgets/settings/choice_picker_page.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

// Reusable style slider widget that can be disabled (kept for legacy callers
// inside the reader settings detail pages).
class StyleSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelFormatter;
  final bool enabled;

  const StyleSlider({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelFormatter,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: enabled ? scheme.primary : scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled ? scheme.onSurface : scheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Slider(
              value: value,
              onChanged: enabled ? onChanged : null,
              min: min,
              max: max,
              divisions: divisions,
              label: labelFormatter(value),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              labelFormatter(value),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Book style preferences — section under "样式" on the reading-experience
/// settings page.
class StyleSettings extends StatefulWidget {
  const StyleSettings({super.key});

  @override
  State<StyleSettings> createState() => _StyleSettingsState();
}

class _StyleSettingsState extends State<StyleSettings> {
  String _alignmentLabel(BuildContext c, TextAlignmentEnum v) {
    switch (v) {
      case TextAlignmentEnum.auto:
        return L10n.of(c).textAlignmentAuto;
      case TextAlignmentEnum.left:
        return L10n.of(c).textAlignmentLeft;
      case TextAlignmentEnum.center:
        return L10n.of(c).textAlignmentCenter;
      case TextAlignmentEnum.right:
        return L10n.of(c).textAlignmentRight;
      case TextAlignmentEnum.justify:
        return L10n.of(c).textAlignmentJustify;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final bookStyle = Prefs().bookStyle;
    final styleLocked = Prefs().useBookStyles;

    return SettingsSection(
      title: Text(l10n.readingPageStyle),
      tiles: [
        SettingsTile.switchTile(
          leading: const Icon(Icons.style_outlined),
          title: Text(l10n.useBookStyles),
          description: Text(l10n.useBookStylesDescription),
          initialValue: styleLocked,
          onToggle: (v) {
            setState(() {
              Prefs().useBookStyles = v;
              epubPlayerKey.currentState?.changeStyle(Prefs().bookStyle);
            });
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.format_bold),
          title: const Text('字体粗细 / 标题大小'),
          value: Text('粗细 ${bookStyle.fontWeight.toInt()} · 标题 ${bookStyle.headingFontSize.toStringAsFixed(1)}x'),
          enabled: !styleLocked,
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
                builder: (_) => const _FontDetailPage()),
          ).then((_) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.format_indent_increase),
          title: const Text('段落与字距'),
          value: Text(
              '缩进 ${bookStyle.indent.toStringAsFixed(1)} · 字距 ${bookStyle.letterSpacing.toInt()}'),
          enabled: !styleLocked,
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
                builder: (_) => const _ParagraphDetailPage()),
          ).then((_) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: Icon(Prefs().writingMode == WritingModeEnum.verticalRl
              ? Bootstrap.arrows_vertical
              : Bootstrap.arrows),
          title: const Text('边距'),
          value: Text(
              '左右 ${bookStyle.sideMargin.toInt()} · 上下 ${bookStyle.topMargin.toInt()}/${bookStyle.bottomMargin.toInt()}'),
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
                builder: (_) => const _MarginDetailPage()),
          ).then((_) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.format_align_left),
          title: Text(l10n.textAlignment),
          value: Text(_alignmentLabel(context, Prefs().textAlignment)),
          onPressed: (_) async {
            final picked = await pushChoicePicker<TextAlignmentEnum>(
              context,
              title: l10n.textAlignment,
              current: Prefs().textAlignment,
              options: [
                ChoiceOption(
                    value: TextAlignmentEnum.auto,
                    label: l10n.textAlignmentAuto,
                    icon: Icons.auto_awesome),
                ChoiceOption(
                    value: TextAlignmentEnum.left,
                    label: l10n.textAlignmentLeft,
                    icon: Icons.format_align_left),
                ChoiceOption(
                    value: TextAlignmentEnum.center,
                    label: l10n.textAlignmentCenter,
                    icon: Icons.format_align_center),
                ChoiceOption(
                    value: TextAlignmentEnum.right,
                    label: l10n.textAlignmentRight,
                    icon: Icons.format_align_right),
                ChoiceOption(
                    value: TextAlignmentEnum.justify,
                    label: l10n.textAlignmentJustify,
                    icon: Icons.format_align_justify),
              ],
            );
            if (picked == null) return;
            setState(() {
              Prefs().textAlignment = picked;
              epubPlayerKey.currentState?.changeStyle(Prefs().bookStyle);
            });
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.code),
          title: const Text('自定义 CSS'),
          onPressed: (_) => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: const AppGlassAppBar(title: Text('自定义 CSS')),
                body: const SafeArea(child: CustomCSSEditor()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --------- detail pages: thin wrappers around StyleSlider ---------

class _FontDetailPage extends StatefulWidget {
  const _FontDetailPage();
  @override
  State<_FontDetailPage> createState() => _FontDetailPageState();
}

class _FontDetailPageState extends State<_FontDetailPage> {
  void _save(BookStyle s) {
    Prefs().saveBookStyleToPrefs(s);
    epubPlayerKey.currentState?.changeStyle(s);
  }

  @override
  Widget build(BuildContext context) {
    final s = Prefs().bookStyle;
    final enabled = !Prefs().useBookStyles;
    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('字体')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StyleSlider(
              icon: Icons.format_bold,
              label: L10n.of(context).readingPageFontWeight,
              value: s.fontWeight,
              min: 100,
              max: 900,
              divisions: 8,
              labelFormatter: (v) => v.toInt().toString(),
              enabled: enabled,
              onChanged: (v) => setState(() => _save(s.copyWith(fontWeight: v))),
            ),
            StyleSlider(
              icon: Icons.title,
              label: L10n.of(context).headingFontSize,
              value: s.headingFontSize,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              labelFormatter: (v) => '${v.toStringAsFixed(1)}x',
              enabled: enabled,
              onChanged: (v) =>
                  setState(() => _save(s.copyWith(headingFontSize: v))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParagraphDetailPage extends StatefulWidget {
  const _ParagraphDetailPage();
  @override
  State<_ParagraphDetailPage> createState() => _ParagraphDetailPageState();
}

class _ParagraphDetailPageState extends State<_ParagraphDetailPage> {
  void _save(BookStyle s) {
    Prefs().saveBookStyleToPrefs(s);
    epubPlayerKey.currentState?.changeStyle(s);
  }

  @override
  Widget build(BuildContext context) {
    final s = Prefs().bookStyle;
    final enabled = !Prefs().useBookStyles;
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('段落与字距')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StyleSlider(
              icon: Icons.format_indent_increase,
              label: l10n.readingPageIndent,
              value: s.indent,
              min: -0.5,
              max: 8,
              divisions: 17,
              labelFormatter: (v) => v < 0
                  ? l10n.readingPageIndentNoChange
                  : v.toStringAsFixed(1),
              enabled: enabled,
              onChanged: (v) => setState(() => _save(s.copyWith(indent: v))),
            ),
            StyleSlider(
              icon: Icons.compare_arrows,
              label: l10n.readingPageLetterSpacing,
              value: s.letterSpacing,
              min: -3,
              max: 7,
              divisions: 10,
              labelFormatter: (v) => v.toInt().toString(),
              enabled: enabled,
              onChanged: (v) =>
                  setState(() => _save(s.copyWith(letterSpacing: v))),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarginDetailPage extends StatefulWidget {
  const _MarginDetailPage();
  @override
  State<_MarginDetailPage> createState() => _MarginDetailPageState();
}

class _MarginDetailPageState extends State<_MarginDetailPage> {
  void _save(BookStyle s) {
    Prefs().saveBookStyleToPrefs(s);
    epubPlayerKey.currentState?.changeStyle(s);
  }

  @override
  Widget build(BuildContext context) {
    final s = Prefs().bookStyle;
    final l10n = L10n.of(context);
    final isVertical = Prefs().writingMode == WritingModeEnum.verticalRl;
    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('边距')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StyleSlider(
              icon: isVertical ? Bootstrap.arrows_vertical : Bootstrap.arrows,
              label: isVertical
                  ? l10n.readingPageVerticleMargin
                  : l10n.readingPageSideMargin,
              value: s.sideMargin,
              min: 0,
              max: 20,
              divisions: 20,
              labelFormatter: (v) => v.toStringAsFixed(1),
              onChanged: (v) =>
                  setState(() => _save(s.copyWith(sideMargin: v))),
            ),
            StyleSlider(
              icon: Bootstrap.chevron_bar_up,
              label: l10n.readingPageTopMargin,
              value: s.topMargin,
              min: 0,
              max: 200,
              divisions: 10,
              labelFormatter: (v) => (v / 20).toStringAsFixed(0),
              onChanged: (v) =>
                  setState(() => _save(s.copyWith(topMargin: v))),
            ),
            StyleSlider(
              icon: Bootstrap.chevron_bar_down,
              label: l10n.readingPageBottomMargin,
              value: s.bottomMargin,
              min: 0,
              max: 200,
              divisions: 10,
              labelFormatter: (v) => (v / 20).toStringAsFixed(0),
              onChanged: (v) =>
                  setState(() => _save(s.copyWith(bottomMargin: v))),
            ),
          ],
        ),
      ),
    );
  }
}

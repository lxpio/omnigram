import 'package:flutter/material.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/typography.dart';

/// Generic single-choice picker. Pushed when the user taps a navigation
/// SettingsTile that needs to pick one value from a small set.
/// Renders each option as a glass row with leading icon, label, optional
/// description, and a check mark when selected.
class ChoiceOption<T> {
  const ChoiceOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? description;
}

/// Push and await the picked value. Returns null on dismiss.
Future<T?> pushChoicePicker<T>(
  BuildContext context, {
  required String title,
  required List<ChoiceOption<T>> options,
  required T current,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (_) => _ChoicePickerPage<T>(
        title: title,
        options: options,
        current: current,
      ),
    ),
  );
}

class _ChoicePickerPage<T> extends StatelessWidget {
  const _ChoicePickerPage({
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<ChoiceOption<T>> options;
  final T current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppGlassAppBar(title: Text(title)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: options.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
          itemBuilder: (context, i) {
            final o = options[i];
            final selected = o.value == current;
            return InkWell(
              onTap: () => Navigator.of(context).pop(o.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    if (o.icon != null) ...[
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(o.icon, size: 20, color: scheme.primary),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.label,
                              style: OmnigramTypography.titleMedium(context)
                                  .copyWith(color: scheme.onSurface)),
                          if (o.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                o.description!,
                                style: OmnigramTypography.caption(context)
                                    .copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_rounded, color: scheme.primary, size: 22),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

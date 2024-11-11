import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/theme.provider.dart';

class ThemeSelectDialogView extends HookConsumerWidget {
  const ThemeSelectDialogView(this.themeMode, {super.key});

  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThemeMode = useState(themeMode ?? ThemeMode.system);

    return AlertDialog(
      title: Text('settings_theme_mode'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ThemeMode.values.map((mode) {
          String modeText = getThemeModeLangTag(mode);
          return RadioListTile<ThemeMode>(
            title: Text(modeText.tr()),
            value: mode,
            groupValue: selectedThemeMode.value,
            onChanged: (ThemeMode? value) {
              selectedThemeMode.value = value ?? ThemeMode.system;
            },
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, themeMode),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedThemeMode.value);
          },
          child: Text('confirm'.tr()),
        ),
      ],
    );
  }
}

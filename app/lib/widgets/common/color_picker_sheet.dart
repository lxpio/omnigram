import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Reusable RGB color picker dialog.
/// Returns selected color as RGB int (0xRRGGBB), alpha is always 0xFF when displaying.
Future<Color?> showRgbColorPicker({
  required BuildContext context,
  required Color initialColor,
  bool allowAlpha = true,
}) async {
  Color pickedColor = initialColor;

  final result = await showDialog<Color>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            hexInputBar: true,
            enableAlpha: allowAlpha,
            pickerColor: pickedColor,
            onColorChanged: (Color color) {
              pickedColor = allowAlpha ? color : color.withAlpha(0xFF);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(L10n.of(context).commonCancel),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: Text(L10n.of(context).commonOk),
            onPressed: () {
              Navigator.of(dialogContext).pop(pickedColor);
            },
          ),
        ],
      );
    },
  );

  return result;
}

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:flutter/material.dart';

class DeleteConfirm extends StatefulWidget {
  const DeleteConfirm({
    super.key,
    required this.delete,
    this.deleteIcon,
    this.confirmIcon,
    this.deleteText,
    this.confirmText,
    this.useTextButton = false,
  });

  final Function delete;
  final Widget? deleteIcon;
  final Widget? confirmIcon;
  final String? deleteText;
  final String? confirmText;
  final bool useTextButton;

  @override
  State<DeleteConfirm> createState() => _DeleteConfirmState();
}

class _DeleteConfirmState extends State<DeleteConfirm> {
  bool isDelete = false;

  @override
  Widget build(BuildContext context) {
    if (widget.useTextButton) {
      // Text button mode with default text from L10n
      final deleteText = widget.deleteText ?? L10n.of(context).commonDelete;
      final confirmText = widget.confirmText ?? L10n.of(context).commonConfirm;

      return TextButton(
        onPressed: () {
          if (isDelete) {
            widget.delete();
            setState(() {
              isDelete = false;
            });
          } else {
            setState(() {
              isDelete = true;
            });
          }
        },
        style: isDelete
            ? TextButton.styleFrom(
                foregroundColor: Colors.red,
              )
            : null,
        child: Text(isDelete ? confirmText : deleteText),
      );
    } else {
      // Icon button mode with default icons
      return IconButton(
        onPressed: () {
          if (isDelete) {
            widget.delete();
            setState(() {
              isDelete = false;
            });
          } else {
            setState(() {
              isDelete = true;
            });
          }
        },
        icon: isDelete
            ? (widget.confirmIcon ??
                const Icon(Icons.check_circle_outline, color: Colors.red))
            : (widget.deleteIcon ?? const Icon(Icons.delete_outline)),
      );
    }
  }
}

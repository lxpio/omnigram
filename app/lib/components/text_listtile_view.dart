import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef OnSaveCallback = void Function(String);

class TextListTileView extends HookConsumerWidget {
  const TextListTileView(
    this.title, {
    super.key,
    this.icon,
    this.subtitle,
    this.onSaved,
  });
  final String title;
  final Icon? icon;
  final String? subtitle;
  final OnSaveCallback? onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final focusNode = useFocusNode();
    final readOnly = useState<bool>(true);
    final textController = useTextEditingController(text: subtitle);

    return ListTile(
        leading: icon,
        title: Text(title),
        subtitle: readOnly.value
            ? Text(subtitle ?? "")
            : FocusScope(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      onSaved?.call(textController.text.trim());
                      readOnly.value = true; // Disable editing
                    }
                  },
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    decoration: const InputDecoration(
                      // hintText: "tts_server_addr".tr(),
                      border: InputBorder.none,
                    ),
                    // onChanged: onChanged,
                  ),
                ),
              ),
        onTap: () async {
          // if (kDebugMode) {
          //   debugPrint("TextListTileView: onTap");
          // }
          readOnly.value = false;
          // focusNode.requestFocus();
        });
  }
}

import 'package:omnigram/main.dart';
import 'package:omnigram/widgets/common/container/filled_container.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AnxToast {
  static FToast fToast = FToast();

  static void init(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fToast.init(context);
    });
  }

  static void show(String message, {Icon? icon, int duration = 2000}) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('AnxToast: context is null, skipping toast: $message');
      return;
    }

    try {
      Widget toast = FilledContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? const Icon(Icons.info_outline),
            const SizedBox(width: 12.0),
            Flexible(
              child: Text(
                message,
                // wrap
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      );

      // close previous toast
      fToast.removeQueuedCustomToasts();

      fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(milliseconds: duration),
      );
    } catch (e) {
      debugPrint('AnxToast: failed to show toast: $e');
    }
  }
}

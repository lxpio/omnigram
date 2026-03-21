import 'package:omnigram/enums/sync_protocol.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/service/sync/sync_connection_tester.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:flutter/material.dart';

class SyncTestHelper {
  /// Handle simple connection test (ping only)
  static Future<void> handleTestConnection(
    BuildContext context, {
    required SyncProtocol protocol,
    required Map<String, dynamic> config,
    VoidCallback? onTestStart,
    Function(bool success, String message)? onTestComplete,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(L10n.of(context).testingConnection),
          ],
        ),
      ),
    );

    onTestStart?.call();

    try {
      final result = await SyncConnectionTester.testConnection(
        protocol: protocol,
        config: config,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      _showTestResult(navigatorKey.currentContext!, result);

      onTestComplete?.call(result.isSuccess, result.message);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final result = SyncTestResult.failure(
          L10n.of(navigatorKey.currentContext!)
                  .unknownErrorWhenTestingConnection +
              e.toString());
      _showTestResult(navigatorKey.currentContext!, result);

      onTestComplete?.call(false, result.message);
    }
  }

  /// Handle full connection test (create, upload, download, delete)
  static Future<void> handleFullTestConnection(
    BuildContext context, {
    required SyncProtocol protocol,
    required Map<String, dynamic> config,
    VoidCallback? onTestStart,
    Function(bool success, String message)? onTestComplete,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(L10n.of(context).testingConnection),
          ],
        ),
      ),
    );

    onTestStart?.call();

    try {
      final result = await SyncConnectionTester.testFullConnection(
        protocol: protocol,
        config: config,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      _showTestResult(navigatorKey.currentContext!, result);

      onTestComplete?.call(result.isSuccess, result.message);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final result = SyncTestResult.failure(
          L10n.of(navigatorKey.currentContext!)
                  .unknownErrorWhenTestingConnection +
              e.toString());
      _showTestResult(navigatorKey.currentContext!, result);

      onTestComplete?.call(false, result.message);
    }
  }

  static void _showTestResult(BuildContext context, SyncTestResult result) {
    if (result.isSuccess) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(L10n.of(context).commonSuccess),
            ],
          ),
          content: Text(result.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L10n.of(context).commonOk),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(L10n.of(context).commonFailed),
            ],
          ),
          content: Text(result.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L10n.of(context).commonOk),
            ),
          ],
        ),
      );
    }
  }
}

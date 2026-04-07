import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/stealth/stealth_library_page.dart';
import 'package:omnigram/theme/colors.dart';

class StealthHome extends StatelessWidget {
  final String encryptionKey;

  const StealthHome({super.key, required this.encryptionKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OmnigramColors.cardLavender,
        leading: const Icon(Icons.lock_outline),
        title: Text(L10n.of(context).stealthPrivateLibrary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L10n.of(context).stealthExit),
          ),
        ],
      ),
      body: StealthLibraryPage(encryptionKey: encryptionKey),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/stealth/stealth_library_page.dart';
import 'package:omnigram/theme/colors.dart';

class StealthHome extends StatefulWidget {
  final String encryptionKey;

  const StealthHome({super.key, required this.encryptionKey});

  @override
  State<StealthHome> createState() => _StealthHomeState();
}

class _StealthHomeState extends State<StealthHome>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      Navigator.of(context).pop();
    }
  }

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
      body: StealthLibraryPage(encryptionKey: widget.encryptionKey),
    );
  }
}

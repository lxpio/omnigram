import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';

class PillDetailSheet extends ConsumerWidget {
  const PillDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final l10n = L10n.of(context);
    final pct = s.serverProgressPercent;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pillSheetTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.pillSheetBody),
            if (pct > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: pct / 100),
              const SizedBox(height: 4),
              Text(l10n.pillSheetServerProgress(pct)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Prefs().ttsDefaultMode = TtsDefaultMode.alwaysLocal.prefValue;
                    Navigator.pop(context);
                  },
                  child: Text(l10n.pillSheetForceLocal),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.pillSheetOk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

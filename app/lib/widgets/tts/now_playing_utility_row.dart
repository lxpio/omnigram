import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/sleep_timer_sheet.dart';

class NowPlayingUtilityRow extends ConsumerWidget {
  const NowPlayingUtilityRow({super.key});

  static const _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<double>(
            onSelected: ctl.setSpeed,
            itemBuilder: (_) => _speeds
                .map((v) => PopupMenuItem(value: v, child: Text('${v}×')))
                .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('${s.speed}×')],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.bedtime_outlined),
            label: Text(l10n.nowPlayingSleep),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const SleepTimerSheet(),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.list),
            label: Text(l10n.nowPlayingChapters),
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
    );
  }
}

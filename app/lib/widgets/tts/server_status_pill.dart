import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:omnigram/widgets/tts/pill_detail_sheet.dart';

/// Visible only in non-default playback states (spec §8.4). Default states
/// (LiveServer / PregenServer) render an empty SizedBox.
class ServerStatusPill extends ConsumerWidget {
  const ServerStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    if (s.mode != PlaybackMode.localFallback) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, label) = _styleFor(s, scheme);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (s.serverReadyForCurrentChapter) {
          ref.read(ttsPlayerSessionControllerProvider.notifier).upgradeNow();
        } else {
          showModalBottomSheet(
            context: context,
            builder: (_) => const PillDetailSheet(),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }

  (Color, Color, String) _styleFor(PlaybackState s, ColorScheme scheme) {
    if (s.serverReadyForCurrentChapter) {
      return (Colors.green.shade100, Colors.green.shade900, '🟢 高质量版本就绪');
    }
    if (s.serverProgressPercent > 0) {
      return (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        '🔵 服务器生成中 · ${s.serverProgressPercent}%',
      );
    }
    return (
      Colors.amber.shade100,
      Colors.amber.shade900,
      '🟡 本地声音 · 服务器准备中',
    );
  }
}

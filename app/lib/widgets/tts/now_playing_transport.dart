import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

class NowPlayingTransport extends ConsumerWidget {
  const NowPlayingTransport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous),
          onPressed: s.chapterIndex > 0 ? ctl.prevChapter : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.replay_10),
          onPressed: () => ctl.seek(
            Duration(milliseconds: (s.position.inMilliseconds - 15000).clamp(0, 1 << 30)),
          ),
        ),
        IconButton.filledTonal(
          iconSize: 56,
          icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () => s.isPlaying ? ctl.pause() : ctl.play(),
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.forward_10),
          onPressed: () => ctl.seek(
            Duration(milliseconds: s.position.inMilliseconds + 15000),
          ),
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next),
          onPressed: s.chapterIndex + 1 < s.totalChapters ? ctl.nextChapter : null,
        ),
      ],
    );
  }
}

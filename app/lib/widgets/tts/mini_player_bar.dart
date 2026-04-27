import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/page/now_playing/now_playing_page.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/server_status_pill.dart';

/// Pinned to scaffold bottom while a session is active. Tap to expand to
/// Now-Playing.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  Widget _cover(String? path) {
    const size = SizedBox(width: 40, height: 40);
    if (path == null || path.isEmpty) return size;
    if (path.startsWith('http')) {
      return Image.network(path, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => size);
    }
    final f = File(path);
    if (!f.existsSync()) return size;
    return Image.file(f, width: 40, height: 40, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    if (!s.hasSession) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final currentSentence = s.hasAlignment &&
            s.sentenceIndex >= 0 &&
            s.sentenceIndex < s.alignment!.sentences.length
        ? s.alignment!.sentences[s.sentenceIndex].text
        : s.chapterTitle;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const NowPlayingPage(),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _cover(s.coverUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentSentence,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      s.chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ServerStatusPill(),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
                  s.isPlaying ? ctl.pause() : ctl.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => ref.read(ttsPlayerSessionControllerProvider.notifier).nextChapter(),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(ttsPlayerSessionControllerProvider.notifier).stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

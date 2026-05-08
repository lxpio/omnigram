import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/now_playing_transport.dart';
import 'package:omnigram/widgets/tts/now_playing_utility_row.dart';
import 'package:omnigram/widgets/tts/sentence_stream.dart';
import 'package:omnigram/widgets/tts/server_status_pill.dart';

class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({super.key});

  Widget _cover(String? path) {
    if (path == null || path.isEmpty) {
      return const SizedBox(width: 220, height: 220);
    }
    if (path.startsWith('http')) {
      return Image.network(path, width: 220, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 220, height: 220));
    }
    final f = File(path);
    if (!f.existsSync()) return const SizedBox(width: 220, height: 220);
    return Image.file(f, width: 220, height: 220, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(s.bookTitle ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: '停止',
            onPressed: () {
              ref.read(ttsPlayerSessionControllerProvider.notifier).stop();
              Navigator.maybePop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _cover(s.coverUrl),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      s.chapterTitle,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ServerStatusPill(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Expanded(child: SentenceStream()),
            const SizedBox(height: 8),
            // Chapter-level progress: scrubber tracks sentence index across
            // the whole chapter (`i + frac` of `total`) instead of resetting
            // to zero each sentence — which felt like the bar was "snapping
            // back" every couple of seconds. Tap/drag rounds to a sentence
            // boundary and uses seekToSentence.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    s.sentences.isEmpty ? '0' : '${(s.sentenceIndex + 1).clamp(1, s.sentences.length)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: s.sentences.isEmpty ? 1 : s.sentences.length.toDouble(),
                      value: () {
                        if (s.sentences.isEmpty) return 0.0;
                        final dur = s.duration.inMilliseconds;
                        final frac = dur > 0
                            ? (s.position.inMilliseconds / dur).clamp(0.0, 1.0)
                            : 0.0;
                        final base = s.sentenceIndex < 0 ? 0 : s.sentenceIndex;
                        return (base + frac).clamp(0.0, s.sentences.length.toDouble());
                      }(),
                      onChanged: (v) => ref
                          .read(ttsPlayerSessionControllerProvider.notifier)
                          .seekToSentence(v.round().clamp(0, s.sentences.length - 1)),
                    ),
                  ),
                  Text(
                    s.sentences.isEmpty ? '0' : '${s.sentences.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const NowPlayingTransport(),
            const NowPlayingUtilityRow(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

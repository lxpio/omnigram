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

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$ss' : '$m:$ss';
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(_format(s.position), style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: s.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
                      value: s.position.inMilliseconds
                          .toDouble()
                          .clamp(0.0, s.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity)),
                      onChanged: (v) => ref
                          .read(ttsPlayerSessionControllerProvider.notifier)
                          .seek(Duration(milliseconds: v.round())),
                    ),
                  ),
                  Text(_format(s.duration), style: theme.textTheme.bodySmall),
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

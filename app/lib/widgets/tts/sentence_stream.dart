import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

/// Apple Music-style three-line sentence view: prev / current / next, where
/// the current sentence is large and high-contrast. Tapping any visible
/// sentence seeks to its start.
class SentenceStream extends ConsumerWidget {
  const SentenceStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final theme = Theme.of(context);

    if (!s.hasAlignment) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Text(
          s.chapterTitle.isEmpty ? '现在播放：第 ${s.chapterIndex + 1} 章' : s.chapterTitle,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    final sentences = s.alignment!.sentences;
    final cur = s.sentenceIndex.clamp(0, sentences.length - 1);
    final prev = cur > 0 ? sentences[cur - 1] : null;
    final next = cur + 1 < sentences.length ? sentences[cur + 1] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prev != null)
            _line(
              ref,
              prev.index,
              prev.text,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
            ),
          const SizedBox(height: 12),
          _line(
            ref,
            sentences[cur].index,
            sentences[cur].text,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (next != null)
            _line(
              ref,
              next.index,
              next.text,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
            ),
        ],
      ),
    );
  }

  Widget _line(WidgetRef ref, int sentenceIndex, String text, {TextStyle? style}) {
    return InkWell(
      onTap: () => ref.read(ttsPlayerSessionControllerProvider.notifier).seekToSentence(sentenceIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: style),
      ),
    );
  }
}

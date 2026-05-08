import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
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

    // Plain-text sentences are populated for ALL modes (local fallback /
    // live server / pregen), so we render off `state.sentences` rather than
    // `state.alignment` (which is only set for pregen).
    if (!s.hasSentences) {
      final l10n = L10n.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Text(
          s.chapterTitle.isEmpty ? l10n.sentenceStreamPlayingChapter(s.chapterIndex + 1) : s.chapterTitle,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    final sentences = s.sentences;
    final cur = s.sentenceIndex.clamp(0, sentences.length - 1);
    final prevText = cur > 0 ? sentences[cur - 1] : null;
    final nextText = cur + 1 < sentences.length ? sentences[cur + 1] : null;

    // Wrap in SingleChildScrollView so a long current sentence doesn't push
    // prev/next off-screen with a renderflex overflow — the column gets a
    // bounded height from `Expanded` in NowPlayingPage and a single 3-line
    // sentence at headlineSmall + 1-line prev/next + paddings can exceed it.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          if (prevText != null)
            _line(
              ref,
              cur - 1,
              prevText,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
              maxLines: 1,
            ),
          const SizedBox(height: 12),
          _line(
            ref,
            cur,
            sentences[cur],
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (nextText != null)
            _line(
              ref,
              cur + 1,
              nextText,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(WidgetRef ref, int sentenceIndex, String text,
      {TextStyle? style, required int maxLines}) {
    return InkWell(
      onTap: () => ref.read(ttsPlayerSessionControllerProvider.notifier).seekToSentence(sentenceIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/models/current_reading_state.dart';
import 'package:omnigram/providers/current_reading.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/theme/typography.dart';

class ContextBar extends ConsumerStatefulWidget {
  const ContextBar({super.key});

  @override
  ConsumerState<ContextBar> createState() => _ContextBarState();
}

class _ContextBarState extends ConsumerState<ContextBar> {
  String? _contextText;
  bool _visible = false;
  String? _lastChapterTitle;

  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(currentReadingProvider);
    final chapterTitle = readingState.chapterTitle;

    // Detect chapter change
    if (chapterTitle != null && chapterTitle != _lastChapterTitle) {
      _lastChapterTitle = chapterTitle;
      _onChapterChanged(readingState);
    }

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: _contextText != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(
                _contextText!,
                style: OmnigramTypography.caption(context).copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  void _onChapterChanged(CurrentReadingState state) async {
    final bookId = state.book?.id;
    final chapterTitle = state.chapterTitle;
    if (bookId == null || chapterTitle == null) return;

    // Show immediately with chapter title as fallback
    setState(() {
      _contextText = chapterTitle;
      _visible = true;
    });

    // Try AI enhancement
    if (AiAvailability.isAvailable(ref)) {
      final aiText = await AmbientTasks.contextBar(ref: ref, bookId: bookId, chapterTitle: chapterTitle);
      if (aiText != null && mounted) {
        setState(() => _contextText = aiText);
      }
    }

    // Auto-hide after 8 seconds
    await Future.delayed(const Duration(seconds: 8));
    if (mounted) {
      setState(() => _visible = false);
    }
  }
}

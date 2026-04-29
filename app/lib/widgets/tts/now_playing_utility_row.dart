import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:omnigram/widgets/audiobook/chapter_status_dot.dart';
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
            onPressed: () => _openChapterSheet(context),
          ),
        ],
      ),
    );
  }

  void _openChapterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChapterListSheet(),
    );
  }
}

class _ChapterListSheet extends ConsumerWidget {
  const _ChapterListSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final bookId = s.bookId;
    if (bookId == null) {
      return const SizedBox.shrink();
    }
    final asyncInfo = ref.watch(audiobookProvider(bookId));
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return asyncInfo.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (info) {
            if (info == null || info.chapters.isEmpty) {
              return const Center(child: Text('—'));
            }
            return ListView.separated(
              controller: scrollController,
              itemCount: info.chapters.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final c = info.chapters[i];
                final status = switch (c.status) {
                  2 => ChapterAudioStatus.ready,
                  1 => ChapterAudioStatus.generating,
                  _ => ChapterAudioStatus.notGenerated,
                };
                final isCurrent = c.chapterIndex == s.chapterIndex;
                return ListTile(
                  leading: SizedBox(
                    width: 28,
                    child: Text(
                      '${c.chapterIndex + 1}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                        fontWeight: isCurrent ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  title: Text(
                    c.chapterTitle.isEmpty ? '#${c.chapterIndex + 1}' : c.chapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isCurrent ? FontWeight.w600 : null,
                    ),
                  ),
                  subtitle: ChapterStatusDot(status: status),
                  trailing: isCurrent ? const Icon(Icons.equalizer, size: 18) : null,
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(ttsPlayerSessionControllerProvider.notifier)
                        .jumpToChapter(c.chapterIndex);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/toc_item.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/book_toc.dart';
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

/// One row in the chapter sheet, source-agnostic.
///
/// Whether the row came from the server's pre-gen audiobook task or the
/// reader's local TOC, the sheet just needs index/title and an optional
/// per-chapter status to overlay.
class _ChapterRow {
  const _ChapterRow({
    required this.index,
    required this.title,
    this.status,
  });
  final int index;
  final String title;
  final ChapterAudioStatus? status;
}

class _ChapterListSheet extends ConsumerWidget {
  const _ChapterListSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final bookId = s.bookId;
    final rows = _buildRows(ref, bookId: bookId);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        if (rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                L10n.of(context).nowPlayingChaptersEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final row = rows[i];
            final isCurrent = row.index == s.chapterIndex;
            return ListTile(
              leading: SizedBox(
                width: 28,
                child: Text(
                  '${row.index + 1}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                    fontWeight: isCurrent ? FontWeight.bold : null,
                  ),
                ),
              ),
              title: Text(
                row.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: isCurrent ? FontWeight.w600 : null,
                ),
              ),
              subtitle: row.status == null ? null : ChapterStatusDot(status: row.status!),
              trailing: isCurrent ? const Icon(Icons.equalizer, size: 18) : null,
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(ttsPlayerSessionControllerProvider.notifier)
                    .jumpToChapter(row.index);
              },
            );
          },
        );
      },
    );
  }

  /// Build chapter rows. The session's `chapterTitles` (populated from the
  /// local EPUB at start-up) is the authoritative list. Server audiobook task
  /// status, when present, is overlaid as a status dot per row.
  List<_ChapterRow> _buildRows(WidgetRef ref, {required String? bookId}) {
    final titles = ref.watch(ttsPlayerSessionControllerProvider
        .select((s) => s.chapterTitles));
    if (titles.isEmpty) {
      // Session not started yet (or local parse hadn't completed). Fall back
      // to the reader-cached TOC so something still renders for users who
      // open the chapter sheet while the book is loading. Drops once the
      // session is up and overwrites with authoritative titles.
      final toc = ref.watch(bookTocProvider);
      final flat = <TocItem>[];
      void walk(List<TocItem> items) {
        for (final i in items) {
          flat.add(i);
          if (i.subitems.isNotEmpty) walk(i.subitems);
        }
      }
      walk(toc);
      return [
        for (var i = 0; i < flat.length; i++)
          _ChapterRow(
            index: i,
            title: flat[i].label.isEmpty ? '#${i + 1}' : flat[i].label,
          ),
      ];
    }

    Map<int, ChapterAudioStatus> statusByIndex = const {};
    if (bookId != null) {
      final info = ref.watch(audiobookProvider(bookId)).valueOrNull;
      if (info != null) {
        statusByIndex = {
          for (final c in info.chapters)
            c.chapterIndex: switch (c.status) {
              2 => ChapterAudioStatus.ready,
              1 => ChapterAudioStatus.generating,
              _ => ChapterAudioStatus.notGenerated,
            },
        };
      }
    }
    return [
      for (var i = 0; i < titles.length; i++)
        _ChapterRow(
          index: i,
          title: titles[i],
          status: statusByIndex[i],
        ),
    ];
  }
}

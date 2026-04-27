import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/page/now_playing/now_playing_page.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:omnigram/widgets/audiobook/chapter_status_dot.dart';

/// Lists chapters of an audiobook and lets the user download each to the
/// device, then open in the system player (no in-app playback — simpler and
/// covers 90% of use cases).
class AudiobookPage extends ConsumerStatefulWidget {
  const AudiobookPage({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<AudiobookPage> createState() => _AudiobookPageState();
}

class _AudiobookPageState extends ConsumerState<AudiobookPage> {
  /// Chapter index → in-flight download state (0.0 – 1.0 when known).
  final Map<int, double?> _downloading = {};

  String get _bookId => widget.book.id.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final async = ref.watch(audiobookProvider(_bookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.audiobookPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.audiobookDelete,
            onPressed: () => _confirmDelete(context, l10n),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (info) {
          if (info == null || info.chapters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.audiobookEmpty,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(audiobookProvider(_bookId).notifier).refresh(),
            child: ListView.separated(
              itemCount: info.chapters.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _chapterTile(ctx, l10n, info.chapters[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _chapterTile(BuildContext context, L10n l10n, ServerAudiobookChapter chapter) {
    final ready = chapter.status == 2 || chapter.audioSize > 0; // 2 = completed in server TaskStatus
    final downloading = _downloading[chapter.chapterIndex];
    final progress = downloading;
    final status = switch (chapter.status) {
      2 => ChapterAudioStatus.ready,
      1 => ChapterAudioStatus.generating,
      _ => ChapterAudioStatus.notGenerated,
    };

    return ListTile(
      title: Text(
        chapter.chapterTitle.isEmpty ? '#${chapter.chapterIndex + 1}' : chapter.chapterTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          ChapterStatusDot(status: status),
          const SizedBox(width: 8),
          Expanded(child: Text(_chapterSubtitle(l10n, chapter))),
        ],
      ),
      trailing: progress != null
          ? SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2,
              ),
            )
          : ready
              ? IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: l10n.audiobookChapterDownload,
                  onPressed: () => _playInNowPlaying(chapter),
                )
              : const Icon(Icons.hourglass_empty, color: Colors.grey),
    );
  }

  String _chapterSubtitle(L10n l10n, ServerAudiobookChapter chapter) {
    if (chapter.audioDuration > 0) {
      final mins = (chapter.audioDuration / 60).floor();
      final secs = (chapter.audioDuration % 60).round().toString().padLeft(2, '0');
      return '$mins:$secs';
    }
    if (chapter.errorMessage != null && chapter.errorMessage!.isNotEmpty) {
      return chapter.errorMessage!;
    }
    return '—';
  }

  Future<void> _playInNowPlaying(ServerAudiobookChapter chapter) async {
    await ref
        .read(ttsPlayerSessionControllerProvider.notifier)
        .startSession(book: widget.book, chapterIndex: chapter.chapterIndex);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const NowPlayingPage(),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, L10n l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.audiobookDeleteTitle),
        content: Text(l10n.audiobookDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.audiobookDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(audiobookProvider(_bookId).notifier).delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/page/audiobook/audiobook_page.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/server_connection_provider.dart';

/// Tri-state audiobook control rendered beneath the continue-reading button.
///
/// - No task → "Generate audiobook" filled-tonal button
/// - Pending/running → progress chip with percent
/// - Completed → "Open audiobook" outlined button
///
/// When the server is disconnected the button is disabled with a tooltip.
class AudiobookButton extends ConsumerWidget {
  const AudiobookButton({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final conn = ref.watch(serverConnectionProvider);
    if (!conn.isConnected) {
      return _disabled(context, l10n.audiobookNeedsServer);
    }

    final bookId = book.id.toString();
    final async = ref.watch(audiobookProvider(bookId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: async.when(
        loading: () => _loadingShell(context),
        error: (_, _) => _errorShell(context, ref, bookId),
        data: (info) => _dataButton(context, ref, l10n, bookId, info?.task),
      ),
    );
  }

  // ── Variants ────────────────────────────────────────────────────

  Widget _dataButton(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    String bookId,
    ServerAudiobookTask? task,
  ) {
    if (task == null || task.status == 'failed') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: () => _confirmAndGenerate(context, ref, bookId),
          icon: const Icon(Icons.headphones_outlined),
          label: Text(l10n.audiobookGenerate),
          style: _shape(),
        ),
      );
    }

    if (task.status == 'completed' || task.status == 'done') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openAudiobookPage(context, bookId),
          icon: const Icon(Icons.headphones),
          label: Text(l10n.audiobookOpen),
          style: _shape(),
        ),
      );
    }

    // pending / running / anything non-terminal
    final total = task.totalChapters > 0 ? task.totalChapters : 1;
    final pct = (task.doneChapters * 100 / total).clamp(0, 100).round();
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: () => _openAudiobookPage(context, bookId),
        icon: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            value: total > 0 ? task.doneChapters / total : null,
            strokeWidth: 2,
          ),
        ),
        label: Text(l10n.audiobookGenerating(pct)),
        style: _shape(),
      ),
    );
  }

  Widget _loadingShell(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: null,
        style: _shape(),
        child: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorShell(BuildContext context, WidgetRef ref, String bookId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ref.read(audiobookProvider(bookId).notifier).refresh(),
        icon: const Icon(Icons.refresh),
        label: Text(L10n.of(context).audiobookFetchFailed),
        style: _shape(),
      ),
    );
  }

  Widget _disabled(BuildContext context, String tooltip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: null,
            icon: const Icon(Icons.headphones_outlined),
            label: Text(L10n.of(context).audiobookGenerate),
            style: _shape(),
          ),
        ),
      ),
    );
  }

  ButtonStyle _shape() => FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ── Actions ─────────────────────────────────────────────────────

  Future<void> _confirmAndGenerate(
    BuildContext context,
    WidgetRef ref,
    String bookId,
  ) async {
    final l10n = L10n.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.audiobookConfirmTitle,
                  style: Theme.of(sheetCtx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.audiobookConfirmBody,
                  style: Theme.of(sheetCtx).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetCtx, false),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetCtx, true),
                    child: Text(l10n.audiobookGenerateConfirm),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;
    try {
      await ref.read(audiobookProvider(bookId).notifier).generate();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  void _openAudiobookPage(BuildContext context, String bookId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AudiobookPage(book: book)),
    );
  }
}

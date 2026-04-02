// app/lib/widgets/reader/reader_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader bottom bar.
/// Two layers: progress indicator on top, action buttons below.
class ReaderBottomBar extends StatelessWidget {
  final double progress;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;

  const ReaderBottomBar({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.onSeek,
    required this.onShowToc,
    required this.onShowNotes,
    required this.onShowProgress,
    required this.onShowStyle,
    required this.onShowTts,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress layer
              _ProgressLayer(
                progress: progress,
                percentText: '$pct%',
                pageText: '$currentPage / $totalPages',
                onSeek: onSeek,
              ),
              const SizedBox(height: 8),
              // Action buttons layer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.list_outlined, size: 22), onPressed: onShowToc),
                  IconButton(icon: const Icon(Icons.edit_note_outlined, size: 22), onPressed: onShowNotes),
                  IconButton(icon: const Icon(Icons.data_usage_outlined, size: 22), onPressed: onShowProgress),
                  IconButton(icon: const Icon(Icons.palette_outlined, size: 22), onPressed: onShowStyle),
                  IconButton(icon: const Icon(Icons.headphones_outlined, size: 22), onPressed: onShowTts),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLayer extends StatelessWidget {
  final double progress;
  final String percentText;
  final String pageText;
  final ValueChanged<double>? onSeek;

  const _ProgressLayer({
    required this.progress,
    required this.percentText,
    required this.pageText,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onHorizontalDragUpdate: onSeek != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              final localX = details.localPosition.dx;
              final pct = (localX / box.size.width).clamp(0.0, 1.0);
              onSeek!(pct);
            }
          : null,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(percentText, style: OmnigramTypography.caption(context)),
          const SizedBox(width: 8),
          Text(pageText, style: OmnigramTypography.caption(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}

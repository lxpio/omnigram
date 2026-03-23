import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/margin_note.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';

/// Margin Notes overlay — shows AI-generated cross-book connections
/// in the reading margin. Max 3 per chapter, dismissible.
class MarginNotesOverlay extends ConsumerStatefulWidget {
  const MarginNotesOverlay({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.chapter,
    this.chapterContent,
    this.visible = true,
  });

  final int bookId;
  final String bookTitle;
  final String chapter;
  final String? chapterContent;
  final bool visible;

  @override
  ConsumerState<MarginNotesOverlay> createState() => _MarginNotesOverlayState();
}

class _MarginNotesOverlayState extends ConsumerState<MarginNotesOverlay> with SingleTickerProviderStateMixin {
  List<MarginNote> _notes = [];
  bool _isLoading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _loadNotes();
  }

  @override
  void didUpdateWidget(MarginNotesOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter != widget.chapter) {
      _loadNotes();
    }
    if (widget.visible && !oldWidget.visible) {
      _fadeController.forward();
    } else if (!widget.visible && oldWidget.visible) {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    // First check local cache
    final cached = await marginNoteDao.getByChapter(widget.bookId, widget.chapter);

    if (cached.isNotEmpty) {
      setState(() {
        _notes = cached;
        _isLoading = false;
      });
      _fadeController.forward();
      return;
    }

    // No cached notes — try AI generation
    await _generateNotes();
  }

  Future<void> _generateNotes() async {
    try {
      final result = await AmbientAiPipeline.execute(
        type: AmbientTaskType.recommendation,
        prompt: _buildMarginNotePrompt(),
        ref: ref,
        bookId: widget.bookId,
        cacheParams: {'book_id': widget.bookId, 'chapter': widget.chapter, 'type': 'margin_notes'},
      );

      if (result != null && result.isNotEmpty && mounted) {
        // Parse AI response into margin notes
        final notes = _parseMarginNotes(result);
        for (final note in notes) {
          await marginNoteDao.addNote(note);
        }

        final loaded = await marginNoteDao.getByChapter(widget.bookId, widget.chapter);
        setState(() {
          _notes = loaded;
          _isLoading = false;
        });
        _fadeController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _buildMarginNotePrompt() {
    final parts = <String>[
      'You are analyzing chapter "${widget.chapter}" of "${widget.bookTitle}".',
      if (widget.chapterContent != null)
        'Chapter content excerpt: ${widget.chapterContent!.substring(0, widget.chapterContent!.length.clamp(0, 1500))}',
      '',
      'Find cross-book connections or interesting observations about this chapter.',
      'Return exactly 1-3 margin notes, each on a separate line starting with "•".',
      'Each note should be 1-2 sentences max.',
      'Focus on: thematic connections, contrasting viewpoints, or illuminating context.',
      'If nothing noteworthy, return empty.',
    ];
    return parts.join('\n');
  }

  List<MarginNote> _parseMarginNotes(String aiResponse) {
    final lines = aiResponse.split('\n').where((l) => l.trim().startsWith('•') || l.trim().startsWith('-')).take(3);
    final now = DateTime.now().toIso8601String();

    return lines
        .map((line) {
          final content = line.replaceFirst(RegExp(r'^[•\-]\s*'), '').trim();
          return MarginNote(
            bookId: widget.bookId,
            chapter: widget.chapter,
            content: content,
            confidence: 0.7,
            createdAt: now,
          );
        })
        .where((n) => n.content.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _notes.isEmpty || !widget.visible) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      child: Positioned(
        right: 8,
        top: 80,
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _notes.map((note) => _buildNoteChip(context, note)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteChip(BuildContext context, MarginNote note) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(note.id ?? note.createdAt),
        direction: DismissDirection.endToStart,
        onDismissed: (_) async {
          if (note.id != null) {
            await marginNoteDao.dismiss(note.id!);
          }
          setState(() => _notes.remove(note));
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onLongPress: () async {
              if (note.id != null) {
                await marginNoteDao.markHelpful(note.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanks for the feedback!'), duration: Duration(seconds: 1)),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(180),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.relatedBookTitle != null)
                    Text(
                      '📖 ${note.relatedBookTitle}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    note.content,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

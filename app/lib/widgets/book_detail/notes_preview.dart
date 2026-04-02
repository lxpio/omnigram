import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

/// Shows up to 3 recent notes/highlights for a book.
/// Hides entirely if no notes.
class NotesPreview extends StatelessWidget {
  final List<BookNote> notes;
  final VoidCallback? onViewAll;

  const NotesPreview({
    super.key,
    required this.notes,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final l10n = L10n.of(context);
    final displayNotes = notes.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_outlined, size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('${l10n.bookDetailMyNotes} (${notes.length})',
                  style: OmnigramTypography.titleMedium(context)),
              const Spacer(),
              if (notes.length > 3)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(l10n.bookDetailViewAll),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...displayNotes.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OmnigramCard(
                  backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.3),
                  child: Text(
                    note.content.isNotEmpty ? note.content : note.chapter,
                    style: OmnigramTypography.bodyMedium(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

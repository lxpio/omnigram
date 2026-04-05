import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class NotesByBookList extends StatelessWidget {
  final Map<String, List<BookNote>> notesByBook;
  final ScrollController? scrollController;

  const NotesByBookList({super.key, required this.notesByBook, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (notesByBook.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          L10n.of(context).insightsNotesEmpty,
          style: OmnigramTypography.bodyMedium(context),
          textAlign: TextAlign.center,
        ),
      );
    }

    final entries = notesByBook.entries.toList();
    return ListView.separated(
      controller: scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final bookTitle = entries[i].key;
        final notes = entries[i].value;
        return OmnigramCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bookTitle, style: OmnigramTypography.titleMedium(context)),
              Text(L10n.of(context).insightsNoteCount(notes.length), style: OmnigramTypography.caption(context)),
              const SizedBox(height: 8),
              ...notes
                  .take(3)
                  .map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        note.content,
                        style: OmnigramTypography.bodyMedium(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              if (notes.length > 3) Text(L10n.of(context).insightsMoreNotes(notes.length - 3), style: OmnigramTypography.caption(context)),
            ],
          ),
        );
      },
    );
  }
}

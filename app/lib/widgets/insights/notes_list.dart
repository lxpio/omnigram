import 'package:flutter/material.dart';
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
          '开始阅读并添加笔记，这里会展示你的知识积累。',
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
              Text('${notes.length} 条笔记', style: OmnigramTypography.caption(context)),
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
              if (notes.length > 3) Text('...还有 ${notes.length - 3} 条', style: OmnigramTypography.caption(context)),
            ],
          ),
        );
      },
    );
  }
}

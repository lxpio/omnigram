import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';

class AlsoReadingShelf extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onBookTap;

  const AlsoReadingShelf({super.key, required this.books, required this.onBookTap});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.of(context).deskAlsoReading, style: OmnigramTypography.titleMedium(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              final progress = (book.readingPercentage * 100).toInt();
              return GestureDetector(
                onTap: () => onBookTap(book),
                child: SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(book.coverFullPath),
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 90,
                            height: 120,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Text(book.title.isNotEmpty ? book.title.substring(0, 1) : '?'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$progress%', style: OmnigramTypography.caption(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

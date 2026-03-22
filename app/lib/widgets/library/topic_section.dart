import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/library/book_grid_item.dart';

class TopicSection extends StatelessWidget {
  final String title;
  final int count;
  final List<Book> books;
  final void Function(Book) onBookTap;
  final VoidCallback? onViewAll;

  const TopicSection({
    super.key,
    required this.title,
    required this.count,
    required this.books,
    required this.onBookTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title ($count)', style: OmnigramTypography.titleMedium(context)),
            if (onViewAll != null) TextButton(onPressed: onViewAll, child: const Text('查看全部')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 110,
              child: BookGridItem(book: books[i], onTap: () => onBookTap(books[i])),
            ),
          ),
        ),
      ],
    );
  }
}

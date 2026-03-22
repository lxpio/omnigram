import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/typography.dart';

class BookGridItem extends StatelessWidget {
  final Book book;
  final List<String> tags;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookGridItem({super.key, required this.book, this.tags = const [], required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(book.coverFullPath),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, e, s) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(book.title, textAlign: TextAlign.center, style: OmnigramTypography.caption(context)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(book.title, style: OmnigramTypography.caption(context), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

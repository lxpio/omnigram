import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class HeroBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onContinueReading;

  const HeroBookCard({super.key, required this.book, required this.onContinueReading});

  @override
  Widget build(BuildContext context) {
    final progress = (book.readingPercentage * 100).toInt();

    return OmnigramCard(
      backgroundColor: OmnigramColors.cardGreen.withValues(alpha: 0.5),
      onTap: onContinueReading,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(book.coverFullPath),
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 100,
                height: 150,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    book.title.isNotEmpty ? book.title.substring(0, 1) : '?',
                    style: OmnigramTypography.displayLarge(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: OmnigramTypography.titleLarge(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(book.author, style: OmnigramTypography.bodyMedium(context)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.readingPercentage,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$progress% 已读', style: OmnigramTypography.caption(context)),
                const SizedBox(height: 16),
                FilledButton(onPressed: onContinueReading, child: const Text('继续阅读')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

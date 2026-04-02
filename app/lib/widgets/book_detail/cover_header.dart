// app/lib/widgets/book_detail/cover_header.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Cover area with gradient background, book cover, title, author, and progress bar.
class CoverHeader extends StatelessWidget {
  final String title;
  final String author;
  final double progress;
  final Widget coverWidget;
  final Color dominantColor;

  const CoverHeader({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    required this.coverWidget,
    required this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dominantColor.withValues(alpha: 0.6),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverWidget,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: OmnigramTypography.titleLarge(context),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: OmnigramTypography.bodyMedium(context).copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$pct%', style: OmnigramTypography.caption(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

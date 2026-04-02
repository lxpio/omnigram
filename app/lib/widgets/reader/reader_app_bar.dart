// app/lib/widgets/reader/reader_app_bar.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader top bar.
/// Semi-transparent with rounded bottom corners.
class ReaderAppBar extends StatelessWidget {
  final String chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowCompanion;
  final VoidCallback onShowMenu;

  const ReaderAppBar({
    super.key,
    required this.chapterTitle,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
    required this.onShowCompanion,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                iconSize: 22,
              ),
              Expanded(
                child: Text(
                  chapterTitle,
                  style: OmnigramTypography.titleMedium(context),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: onToggleBookmark,
                iconSize: 22,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: onShowCompanion,
                iconSize: 22,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onShowMenu,
                iconSize: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

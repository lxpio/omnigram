// app/lib/widgets/reader/reader_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_icon_button.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader top bar — iOS 26 "discrete floating chrome".
///
/// Reference: Apple Mail inbox header (iOS 26) — back button, title and
/// trailing actions are not packed into one big bar but float over the
/// page as separate circular glass blobs. The page content shows
/// through between them.
///
/// Layout (left → right):
///   • [back] circle
///   • chapter title (floating text, no background — relies on contrast)
///   • [bookmark] [chat] [menu] circles, evenly spaced
///
/// Quality auto-steps-down inside the Reader for smooth page-turns.
class ReaderAppBar extends ConsumerWidget {
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

  static const double _btn = 40.0;
  static const double _icon = 20.0;
  static const double _gap = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(readerGlassQualityProvider);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _btn,
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.arrow_back,
            onPressed: onBack,
            quality: quality,
            size: _btn,
            iconSize: _icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              chapterTitle,
              style: OmnigramTypography.titleMedium(context).copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: scheme.surface.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          GlassIconButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            onPressed: onToggleBookmark,
            quality: quality,
            size: _btn,
            iconSize: _icon,
          ),
          const SizedBox(width: _gap),
          GlassIconButton(
            icon: Icons.chat_bubble_outline,
            onPressed: onShowCompanion,
            quality: quality,
            size: _btn,
            iconSize: _icon,
          ),
          const SizedBox(width: _gap),
          GlassIconButton(
            icon: Icons.more_vert,
            onPressed: onShowMenu,
            quality: quality,
            size: _btn,
            iconSize: _icon,
          ),
        ],
      ),
    );
  }
}

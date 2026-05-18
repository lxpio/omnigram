// app/lib/widgets/reader/reader_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader top bar.
/// Glass-tinted with rounded bottom corners. Quality auto-steps-down
/// one tier inside the Reader to keep page-turn smooth.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(readerGlassQualityProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: GlassSurface(
        quality: quality,
        borderRadius: 0,
        blurSigma: GlassTokens.blurSigmaThick,
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
      ),
    );
  }
}

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

    final scheme = Theme.of(context).colorScheme;
    const r = GlassTokens.radiusBar; // 22 — iOS 26 squircle
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(r)),
      child: GlassSurface(
        quality: quality,
        borderRadius: 0,
        blurSigma: GlassTokens.blurSigmaThick,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              _BarIcon(
                  icon: Icons.arrow_back, onTap: onBack, tint: scheme.onSurface),
              Expanded(
                child: Text(
                  chapterTitle,
                  style: OmnigramTypography.titleMedium(context),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              _BarIcon(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  onTap: onToggleBookmark,
                  tint: scheme.onSurface),
              _BarIcon(
                  icon: Icons.chat_bubble_outline,
                  onTap: onShowCompanion,
                  tint: scheme.onSurface),
              _BarIcon(
                  icon: Icons.more_vert,
                  onTap: onShowMenu,
                  tint: scheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thin, ripple-free icon row entry — iOS 26 tap target.
class _BarIcon extends StatelessWidget {
  const _BarIcon({required this.icon, required this.onTap, required this.tint});
  final IconData icon;
  final VoidCallback onTap;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 22, color: tint),
      ),
    );
  }
}

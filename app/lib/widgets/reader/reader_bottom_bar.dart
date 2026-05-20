// app/lib/widgets/reader/reader_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader bottom bar — iOS 26 floating glass pill.
/// Two layers: progress indicator on top, action buttons below.
/// Renders on GlassSurface using readerGlassQualityProvider (auto step-down).
///
/// When [attachedTop] is true the top corners are square so the bar can
/// connect to a sub-panel sitting on top of it; otherwise all corners are
/// rounded into a squircle pill that floats over the page.
class ReaderBottomBar extends ConsumerWidget {
  final double progress;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;
  final bool hideProgress;
  final bool attachedTop;

  const ReaderBottomBar({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.onSeek,
    required this.onShowToc,
    required this.onShowNotes,
    required this.onShowProgress,
    required this.onShowStyle,
    required this.onShowTts,
    this.hideProgress = false,
    this.attachedTop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = (progress * 100).round();
    final quality = ref.watch(readerGlassQualityProvider);
    final scheme = Theme.of(context).colorScheme;
    const r = GlassTokens.radiusBar; // 22 — iOS 26 squircle
    final shape = BorderRadius.only(
      topLeft: Radius.circular(attachedTop ? 0 : r),
      topRight: Radius.circular(attachedTop ? 0 : r),
      bottomLeft: const Radius.circular(r),
      bottomRight: const Radius.circular(r),
    );

    return ClipRRect(
      borderRadius: shape,
      child: GlassSurface(
        quality: quality,
        borderRadius: 0,
        blurSigma: GlassTokens.blurSigmaThick,
        chrome: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hideProgress) ...[
                _ProgressLayer(
                  progress: progress,
                  percentText: '$pct%',
                  pageText: '$currentPage / $totalPages',
                  onSeek: onSeek,
                ),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BarIcon(
                      icon: Icons.list_outlined,
                      onTap: onShowToc,
                      tint: scheme.onSurface),
                  _BarIcon(
                      icon: Icons.edit_note_outlined,
                      onTap: onShowNotes,
                      tint: scheme.onSurface),
                  _BarIcon(
                      icon: Icons.data_usage_outlined,
                      onTap: onShowProgress,
                      tint: scheme.onSurface),
                  _BarIcon(
                      icon: Icons.palette_outlined,
                      onTap: onShowStyle,
                      tint: scheme.onSurface),
                  _BarIcon(
                      icon: Icons.headphones_outlined,
                      onTap: onShowTts,
                      tint: scheme.onSurface),
                ],
              ),
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
        height: 40,
        child: Icon(icon, size: 22, color: tint),
      ),
    );
  }
}

class _ProgressLayer extends StatelessWidget {
  final double progress;
  final String percentText;
  final String pageText;
  final ValueChanged<double>? onSeek;

  const _ProgressLayer({
    required this.progress,
    required this.percentText,
    required this.pageText,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onHorizontalDragUpdate: onSeek != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              final localX = details.localPosition.dx;
              final pct = (localX / box.size.width).clamp(0.0, 1.0);
              onSeek!(pct);
            }
          : null,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(percentText, style: OmnigramTypography.caption(context)),
          const SizedBox(width: 8),
          Text(pageText, style: OmnigramTypography.caption(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}

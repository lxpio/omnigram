import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

/// Contextual action pill that sits next to the GlassTabBar.
///
/// Each tab page can supply its own pill (e.g. "继续阅读" on Desk,
/// "搜索" on Library). Glass-styled, icon + optional label, with
/// the same press/haptic feel as GlassTabBar tabs.
class GlassActionPill extends StatefulWidget {
  const GlassActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.quality,
    this.tinted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final GlassQuality quality;

  /// When true, fill with primary-container color (CTA emphasis).
  final bool tinted;

  @override
  State<GlassActionPill> createState() => _GlassActionPillState();
}

class _GlassActionPillState extends State<GlassActionPill> {
  bool _pressed = false;

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final contentColor = widget.tinted ? scheme.onPrimaryContainer : scheme.onSurface;
    final tintLayer = widget.tinted
        ? Container(
            color: scheme.primaryContainer.withValues(alpha: 0.55),
          )
        : null;

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: contentColor),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );

    final pill = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GlassTokens.radiusCapsule * 2.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GlassSurface(
        quality: widget.quality,
        borderRadius: GlassTokens.radiusCapsule,
        blurSigma: GlassTokens.blurSigmaThick,
        child: Stack(
          children: [
            if (tintLayer != null) Positioned.fill(child: tintLayer),
            body,
          ],
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: widget.quality.hasMotion
          ? AnimatedScale(
              scale: _pressed ? 0.94 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: pill,
            )
          : pill,
    );
  }
}

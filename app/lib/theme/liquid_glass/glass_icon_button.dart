import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

/// Circular glass IconButton — iOS 26 / GitHub-style header action.
///
/// Sits as a small floating circle on top of content. Use for header
/// trailing actions (import, add, edit) and leading back buttons.
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.quality,
    this.tooltip,
    this.size = 36.0,
    this.iconSize = 18.0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final GlassQuality quality;
  final String? tooltip;
  final double size;
  final double iconSize;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.selectionClick();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? GlassTokens.tintDark() : GlassTokens.tintLight();
    final highlight = isDark ? GlassTokens.highlightDark : GlassTokens.highlightLight;

    final circleColor = widget.quality.hasBlur
        ? tint
        : tint.withValues(alpha: (tint.a + 0.15).clamp(0.0, 1.0));

    final core = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: Border.all(color: highlight, width: GlassTokens.highlightWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: widget.iconSize,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    final clipped = ClipOval(
      child: widget.quality.hasBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassTokens.blurSigmaThin,
                sigmaY: GlassTokens.blurSigmaThin,
              ),
              child: core,
            )
          : core,
    );

    final pressable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: widget.quality.hasMotion
          ? AnimatedScale(
              scale: _pressed ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: clipped,
            )
          : clipped,
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: pressable);
    }
    return pressable;
  }
}

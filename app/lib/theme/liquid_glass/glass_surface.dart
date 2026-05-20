import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.quality,
    this.borderRadius = GlassTokens.radiusBar,
    this.blurSigma = GlassTokens.blurSigmaThick,
    this.padding = EdgeInsets.zero,
    this.chrome = false,
  });

  final Widget child;
  final GlassQuality quality;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;

  /// When true, use the low-alpha "chrome" tint instead of the heavy
  /// surface tint. Pick this for floating toolbars / pills sitting on
  /// top of page content where you WANT the backdrop blur to show
  /// through — Apple Mail / Safari iOS 26 idiom. Leave false for
  /// settings cards / app bar containers where opacity is the point.
  final bool chrome;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = chrome
        ? (isDark ? GlassTokens.chromeTintDark() : GlassTokens.chromeTintLight())
        : (isDark ? GlassTokens.tintDark() : GlassTokens.tintLight());
    final highlight = isDark ? GlassTokens.highlightDark : GlassTokens.highlightLight;
    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius * 2.2),
    );

    final tinted = Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: quality.hasBlur ? tint : tint.withValues(alpha: (tint.a + 0.15).clamp(0.0, 1.0)),
        shape: shape,
      ),
      child: child,
    );

    final highlighted = DecoratedBox(
      decoration: ShapeDecoration(
        shape: ContinuousRectangleBorder(
          side: BorderSide(color: highlight, width: GlassTokens.highlightWidth),
          borderRadius: BorderRadius.circular(borderRadius * 2.2),
        ),
      ),
      child: tinted,
    );

    if (!quality.hasBlur) {
      return ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: highlighted,
      );
    }

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: highlighted,
      ),
    );
  }
}

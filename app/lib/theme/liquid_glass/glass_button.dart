import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.quality,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderRadius = GlassTokens.radiusButton,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final GlassQuality quality;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  void _handleTapDown(_) => setState(() => _pressed = true);
  void _handleTapUp(_) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final surface = GlassSurface(
      quality: widget.quality,
      borderRadius: widget.borderRadius,
      blurSigma: GlassTokens.blurSigmaThin,
      padding: widget.padding,
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelLarge ?? const TextStyle(),
        child: widget.child,
      ),
    );

    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: surface,
    );

    if (!widget.quality.hasMotion) return tappable;

    return AnimatedScale(
      scale: _pressed ? GlassTokens.pressedScale : 1.0,
      duration: _pressed ? GlassTokens.morphPressIn : GlassTokens.morphPressOut,
      curve: _pressed ? Curves.easeOut : GlassTokens.springOut,
      child: tappable,
    );
  }
}

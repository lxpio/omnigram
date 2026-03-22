import 'package:flutter/material.dart';
import 'package:omnigram/theme/omnigram_theme.dart';

/// Soft rounded card — the core visual building block of Omnigram.
/// Matches reference UI: large border-radius, generous padding, optional pastel background.
class OmnigramCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;

  const OmnigramCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(OmnigramTheme.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius ?? OmnigramTheme.cardRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

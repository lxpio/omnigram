import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/theme/typography.dart';

/// Reusable empty state — personality-adapted text and visuals.
/// Used across Desk, Bookshelf, Insights, Companion.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? visual;

  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.visual,
  });

  /// Build from EmptyStateData (returned by EmptyStateConfig).
  factory EmptyState.fromData(
    EmptyStateData data, {
    Key? key,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      message: data.message,
      actionLabel: data.actionLabel,
      onAction: onAction,
      visual: _buildVisual(data.visualType),
    );
  }

  static Widget _buildVisual(EmptyVisualType type) {
    return switch (type) {
      EmptyVisualLottie(:final assetPath) => Lottie.asset(
          assetPath,
          width: 160,
          height: 160,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      EmptyVisualSvg(:final assetPath) => SvgPicture.asset(
          assetPath,
          width: 120,
          height: 120,
          placeholderBuilder: (_) => const SizedBox.shrink(),
        ),
      EmptyVisualIcon(:final iconData) => Icon(iconData, size: 64),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (visual != null) ...[
              IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.outlineVariant),
                child: visual!,
              ),
              const SizedBox(height: 16),
            ],
            Text(message, style: OmnigramTypography.bodyLarge(context), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Reusable empty state — warm or concise text, optional action button.
/// Used across Desk, Bookshelf, Insights, Stealth.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyState({super.key, required this.message, this.actionLabel, this.onAction, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
            if (icon != null) const SizedBox(height: 16),
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

// app/lib/widgets/book_detail/ai_summary_section.dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/typography.dart';

/// Shows AI-generated one-line summary or book description.
/// Hides entirely if no content available.
class AiSummarySection extends StatelessWidget {
  final String? aiSummary;
  final String? description;

  const AiSummarySection({
    super.key,
    this.aiSummary,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final text = aiSummary ?? description;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final isAi = aiSummary != null && aiSummary!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(L10n.of(context).bookDetailAbout,
                  style: OmnigramTypography.titleMedium(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: OmnigramTypography.bodyLarge(context).copyWith(
              fontStyle: isAi ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

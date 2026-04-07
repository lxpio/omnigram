import 'package:flutter/material.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class ThoughtCard extends StatelessWidget {
  final Thought thought;
  const ThoughtCard({super.key, required this.thought});

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thought.conceptName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                thought.conceptName!,
                style: OmnigramTypography.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(thought.content, style: OmnigramTypography.bodyMedium(context)),
          const SizedBox(height: 6),
          Text(
            _formatDate(thought.createdAt),
            style: OmnigramTypography.caption(context).copyWith(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}

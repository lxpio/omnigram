import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class CrossBookDiscovery {
  final int edgeId;
  final String sourceBookTitle;
  final String targetBookTitle;
  final String sourceConcept;
  final String targetConcept;
  final String reason;
  final double weight;

  const CrossBookDiscovery({
    required this.edgeId,
    required this.sourceBookTitle,
    required this.targetBookTitle,
    required this.sourceConcept,
    required this.targetConcept,
    required this.reason,
    required this.weight,
  });
}

class CrossBookCard extends StatelessWidget {
  final CrossBookDiscovery discovery;
  final VoidCallback onRecordThought;

  const CrossBookCard({
    super.key,
    required this.discovery,
    required this.onRecordThought,
  });

  @override
  Widget build(BuildContext context) {
    final d = discovery;
    return OmnigramCard(
      backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, size: 14, color: OmnigramColors.accentLavender),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${d.sourceBookTitle}  ↔  ${d.targetBookTitle}',
                  style: OmnigramTypography.caption(context).copyWith(
                    color: OmnigramColors.accentLavender,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${d.sourceConcept}" ↔ "${d.targetConcept}"',
            style: OmnigramTypography.titleMedium(context),
          ),
          const SizedBox(height: 4),
          Text(
            d.reason,
            style: OmnigramTypography.bodyMedium(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: i < (d.weight * 5).round()
                      ? OmnigramColors.accentLavender
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              )),
              const Spacer(),
              TextButton.icon(
                onPressed: onRecordThought,
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(L10n.of(context).insightsRecordThought, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

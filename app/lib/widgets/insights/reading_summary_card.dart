import 'package:flutter/material.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class ReadingSummaryCard extends StatelessWidget {
  final int booksRead;
  final int totalHours;
  final int totalNotes;

  const ReadingSummaryCard({super.key, required this.booksRead, required this.totalHours, required this.totalNotes});

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '$booksRead', label: '本书'),
          _Stat(value: '$totalHours', label: '小时'),
          _Stat(value: '$totalNotes', label: '条笔记'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: OmnigramTypography.displayMedium(context)),
        const SizedBox(height: 4),
        Text(label, style: OmnigramTypography.caption(context)),
      ],
    );
  }
}

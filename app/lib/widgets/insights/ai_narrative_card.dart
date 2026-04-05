import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class AiNarrativeCard extends ConsumerStatefulWidget {
  final List<String> bookTitles;
  final int totalMinutes;
  final int totalNotes;
  final String timePeriod;

  const AiNarrativeCard({
    super.key,
    required this.bookTitles,
    required this.totalMinutes,
    required this.totalNotes,
    required this.timePeriod,
  });

  @override
  ConsumerState<AiNarrativeCard> createState() => _AiNarrativeCardState();
}

class _AiNarrativeCardState extends ConsumerState<AiNarrativeCard> {
  String? _narrative;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNarrative();
  }

  @override
  void didUpdateWidget(AiNarrativeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timePeriod != widget.timePeriod) {
      _fetchNarrative();
    }
  }

  Future<void> _fetchNarrative() async {
    setState(() => _loading = true);

    if (!AiAvailability.isAvailable(ref) || widget.bookTitles.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await AmbientTasks.readingNarrative(
      ref: ref,
      bookTitles: widget.bookTitles,
      totalMinutes: widget.totalMinutes,
      totalNotes: widget.totalNotes,
      timePeriod: widget.timePeriod,
    );

    if (mounted) {
      setState(() {
        _narrative = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _narrative == null) return const SizedBox.shrink();
    if (_loading) return const SizedBox.shrink();

    return OmnigramCard(
      backgroundColor: OmnigramColors.accentLavender.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, size: 18, color: OmnigramColors.accentLavender),
              const SizedBox(width: 8),
              Text(L10n.of(context).insightsReadingJourney, style: OmnigramTypography.titleMedium(context)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _narrative!,
            style: OmnigramTypography.bodyMedium(context).copyWith(height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

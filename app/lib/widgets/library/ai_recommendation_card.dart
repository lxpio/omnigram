import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class AiRecommendationCard extends ConsumerStatefulWidget {
  final List<String> recentBookTitles;
  const AiRecommendationCard({super.key, required this.recentBookTitles});

  @override
  ConsumerState<AiRecommendationCard> createState() =>
      _AiRecommendationCardState();
}

class _AiRecommendationCardState extends ConsumerState<AiRecommendationCard> {
  String? _recommendation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendation();
  }

  Future<void> _fetchRecommendation() async {
    if (!AiAvailability.isAvailable(ref) || widget.recentBookTitles.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final titles = widget.recentBookTitles.take(5).join(', ');
    final prompt = 'The reader\'s recent books include: $titles. '
        'Based on their reading interests, write ONE sentence (under 30 words) '
        'suggesting what kind of book they might enjoy next. '
        'Be warm and specific, referencing their taste. Do not recommend a specific title.';

    final result = await AmbientAiPipeline.execute(
      type: AmbientTaskType.recommendation,
      prompt: prompt,
      ref: ref,
      cacheParams: {'recommendation': titles},
    );

    if (mounted) {
      setState(() {
        _recommendation = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _recommendation == null) return const SizedBox.shrink();
    if (_loading) return const SizedBox.shrink();

    return OmnigramCard(
      backgroundColor: OmnigramColors.accentLavender.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.auto_awesome,
              size: 20, color: OmnigramColors.accentLavender),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _recommendation!,
              style: OmnigramTypography.bodyMedium(context).copyWith(
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

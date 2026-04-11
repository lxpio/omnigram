import 'package:flutter/material.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/widgets/settings/voice_card.dart';

class VoiceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TaggedVoice> voices;
  final String? selectedFullId;
  final String? playingFullId;
  final ValueChanged<TaggedVoice> onSelect;
  final ValueChanged<TaggedVoice> onPreview;
  final Widget? emptyState;

  const VoiceSection({
    super.key,
    required this.title,
    required this.icon,
    required this.voices,
    this.selectedFullId,
    this.playingFullId,
    required this.onSelect,
    required this.onPreview,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (voices.isEmpty && emptyState != null)
          emptyState!
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: voices.map((tv) => SizedBox(
              width: 110,
              child: VoiceCard(
                taggedVoice: tv,
                isSelected: tv.fullId == selectedFullId,
                isPlaying: tv.fullId == playingFullId,
                onSelect: () => onSelect(tv),
                onPreview: () => onPreview(tv),
              ),
            )).toList(),
          ),
      ],
    );
  }
}

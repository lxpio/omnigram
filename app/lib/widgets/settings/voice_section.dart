import 'package:flutter/material.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/widgets/settings/voice_card.dart';

class VoiceSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<TaggedVoice> voices;
  final String? selectedFullId;
  final String? playingFullId;
  final ValueChanged<TaggedVoice> onSelect;
  final ValueChanged<TaggedVoice> onPreview;
  final Widget? emptyState;

  /// Initial number of voices shown before the user expands the section.
  /// Roughly 2 rows on a phone-width grid (3 cards/row).
  final int previewCount;

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
    this.previewCount = 6,
  });

  @override
  State<VoiceSection> createState() => _VoiceSectionState();
}

class _VoiceSectionState extends State<VoiceSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _resolveVisibleVoices();
    final hidden = widget.voices.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (widget.voices.isNotEmpty)
                Text(
                  '${widget.voices.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
            ],
          ),
        ),
        if (widget.voices.isEmpty && widget.emptyState != null)
          widget.emptyState!
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visible
                .map(
                  (tv) => SizedBox(
                    width: 110,
                    child: VoiceCard(
                      taggedVoice: tv,
                      isSelected: tv.fullId == widget.selectedFullId,
                      isPlaying: tv.fullId == widget.playingFullId,
                      onSelect: () => widget.onSelect(tv),
                      onPreview: () => widget.onPreview(tv),
                    ),
                  ),
                )
                .toList(),
          ),
        if (hidden > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(_expanded ? '收起' : '更多 ($hidden)'),
            ),
          ),
      ],
    );
  }

  List<TaggedVoice> _resolveVisibleVoices() {
    if (_expanded || widget.voices.length <= widget.previewCount) {
      return widget.voices;
    }
    // Surface the currently selected voice even in collapsed mode.
    final preview = widget.voices.take(widget.previewCount).toList();
    final selectedId = widget.selectedFullId;
    if (selectedId == null || selectedId.isEmpty) return preview;
    if (preview.any((v) => v.fullId == selectedId)) return preview;
    final selected = widget.voices.firstWhere(
      (v) => v.fullId == selectedId,
      orElse: () => preview.first,
    );
    if (selected.fullId != selectedId) return preview;
    return [...preview.take(preview.length - 1), selected];
  }
}

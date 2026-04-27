import 'package:flutter/material.dart';
import 'package:omnigram/service/tts/tts_router.dart';

/// Compact ●/◐/○/◌ status indicator paired with a short label, used
/// across the AudiobookPage chapter list and the reader chapter drawer.
class ChapterStatusDot extends StatelessWidget {
  const ChapterStatusDot({super.key, required this.status, this.percent});

  final ChapterAudioStatus status;
  final int? percent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, glyph, label) = switch (status) {
      ChapterAudioStatus.notGenerated => (scheme.outline, '○', '未生成'),
      ChapterAudioStatus.generating => (scheme.primary, '◐', '生成中 ${percent ?? 0}%'),
      ChapterAudioStatus.ready => (Colors.green, '●', '已就绪'),
      ChapterAudioStatus.localCached => (Colors.amber.shade700, '◌', '本地'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          glyph,
          style: TextStyle(color: color, fontSize: 14, fontFamily: 'monospace'),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }
}

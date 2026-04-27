import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';

class PillDetailSheet extends ConsumerWidget {
  const PillDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final pct = s.serverProgressPercent;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('你正在听本地声音', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              '我们的服务器现在合成跟不上你的播放速度，所以先用手机内置的声音陪你听着。'
              '同时服务器在后台准备一份更自然的版本，下一章自动切过去。',
            ),
            if (pct > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: pct / 100),
              const SizedBox(height: 4),
              Text('服务器进度：$pct%'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Prefs().ttsDefaultMode = TtsDefaultMode.alwaysLocal.prefValue;
                    Navigator.pop(context);
                  },
                  child: const Text('我不要服务器版'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('好'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

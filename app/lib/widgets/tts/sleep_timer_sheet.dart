import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

/// Holds a single shared timer so users can cancel from anywhere.
class _SleepTimerHolder {
  static Timer? _timer;
  static void arm(Duration d, void Function() onFire) {
    _timer?.cancel();
    _timer = Timer(d, onFire);
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  void _arm(Duration d) {
    _SleepTimerHolder.arm(d, () {
      ref.read(ttsPlayerSessionControllerProvider.notifier).pause();
    });
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('${d.inMinutes} 分钟后停止')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in const [10, 15, 30, 45, 60])
              ListTile(
                title: Text('$m 分钟'),
                onTap: () => _arm(Duration(minutes: m)),
              ),
            ListTile(
              title: const Text('取消定时'),
              onTap: () {
                _SleepTimerHolder.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

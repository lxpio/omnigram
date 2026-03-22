import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/ai_providers.dart';
import 'package:omnigram/service/ai/ai_key_rotator.dart';

enum AiStatus { available, unconfigured, noProvider, error }

class AiAvailability {
  AiAvailability._();

  /// Check if AI is ready to use
  static AiStatus check(WidgetRef ref) {
    try {
      final notifier = ref.read(aiProvidersProvider.notifier);
      final selected = notifier.getSelectedProvider();
      if (selected == null) return AiStatus.noProvider;
      if (!AiKeyRotator.hasValidKey(selected)) return AiStatus.unconfigured;
      return AiStatus.available;
    } catch (_) {
      return AiStatus.error;
    }
  }

  /// Quick bool check
  static bool isAvailable(WidgetRef ref) => check(ref) == AiStatus.available;
}

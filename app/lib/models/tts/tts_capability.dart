import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_capability.freezed.dart';
part 'tts_capability.g.dart';

enum TtsCapabilityTier { green, yellow, red, na }

@freezed
abstract class TtsCapability with _$TtsCapability {
  const TtsCapability._();
  const factory TtsCapability({
    required String serverUrl,
    required String voiceFullId,
    required TtsCapabilityTier tier,
    required int firstByteMs,
    required double rtf,
    required String serverBuild,
    required DateTime probedAt,
  }) = _TtsCapability;

  factory TtsCapability.fromJson(Map<String, dynamic> json) => _$TtsCapabilityFromJson(json);

  bool get isExpired => DateTime.now().difference(probedAt) > const Duration(days: 7);

  /// Spec §5.1 thresholds: GREEN < 1.5s/0.6, RED ≥ 3s/0.9, YELLOW between.
  static TtsCapabilityTier classify({required int firstByteMs, required double rtf}) {
    if (firstByteMs < 1500 && rtf < 0.6) return TtsCapabilityTier.green;
    if (firstByteMs >= 3000 || rtf >= 0.9) return TtsCapabilityTier.red;
    return TtsCapabilityTier.yellow;
  }
}

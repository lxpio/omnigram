import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

/// Central place to interact with both the vibration plugin and the haptic
/// feedback plugin so the rest of the codebase can just ask for a
/// [VibrationType] and not worry about platform differences.
class VibrationService {
  const VibrationService._();

  /// Main entry point. Pick a [VibrationType] and this will route it to either
  /// the platform haptics API or a vibration preset.
  static Future<void> vibrate(VibrationType type) async {
    if (_shouldSuppressFeedback()) {
      return;
    }

    if (_hapticsTypeMap.containsKey(type)) {
      await _playHaptics(
        _hapticsTypeMap[type]!,
        fallbackPreset: _hapticsFallbackPreset[type],
      );
      return;
    }

    final preset = _presetMap[type];
    if (preset != null) {
      await _playPreset(
        preset,
        fallbackHaptics: _presetFallbackHaptics[type],
      );
    }
  }

  /// Convenience helpers so callers can write `VibrationService.success()` etc.
  static Future<void> success() => vibrate(VibrationType.success);
  static Future<void> warning() => vibrate(VibrationType.warning);
  static Future<void> error() => vibrate(VibrationType.error);
  static Future<void> light() => vibrate(VibrationType.light);
  static Future<void> medium() => vibrate(VibrationType.medium);
  static Future<void> heavy() => vibrate(VibrationType.heavy);
  static Future<void> rigid() => vibrate(VibrationType.rigid);
  static Future<void> soft() => vibrate(VibrationType.soft);
  static Future<void> selection() => vibrate(VibrationType.selection);
  static Future<void> singleShortBuzz() =>
      vibrate(VibrationType.singleShortBuzz);
  static Future<void> doubleBuzz() => vibrate(VibrationType.doubleBuzz);
  static Future<void> tripleBuzz() => vibrate(VibrationType.tripleBuzz);
  static Future<void> longAlarmBuzz() => vibrate(VibrationType.longAlarmBuzz);
  static Future<void> pulseWave() => vibrate(VibrationType.pulseWave);
  static Future<void> progressiveBuzz() =>
      vibrate(VibrationType.progressiveBuzz);
  static Future<void> rhythmicBuzz() => vibrate(VibrationType.rhythmicBuzz);
  static Future<void> gentleReminder() => vibrate(VibrationType.gentleReminder);
  static Future<void> quickSuccessAlert() =>
      vibrate(VibrationType.quickSuccessAlert);
  static Future<void> zigZagAlert() => vibrate(VibrationType.zigZagAlert);
  static Future<void> softPulse() => vibrate(VibrationType.softPulse);
  static Future<void> emergencyAlert() => vibrate(VibrationType.emergencyAlert);
  static Future<void> heartbeatVibration() =>
      vibrate(VibrationType.heartbeatVibration);
  static Future<void> countdownTimerAlert() =>
      vibrate(VibrationType.countdownTimerAlert);
  static Future<void> rapidTapFeedback() =>
      vibrate(VibrationType.rapidTapFeedback);
  static Future<void> dramaticNotification() =>
      vibrate(VibrationType.dramaticNotification);
  static Future<void> urgentBuzzWave() => vibrate(VibrationType.urgentBuzzWave);

  /// Wrapper for the underlying preset call so test pages can still request a
  /// specific [VibrationPreset].
  static Future<void> vibrateWithPreset(VibrationPreset preset) async {
    if (_shouldSuppressFeedback()) {
      return;
    }
    await _playPreset(preset);
  }

  /// Allows the UI to pass a fully custom vibration pattern.
  static Future<void> vibratePattern(
    List<int> pattern, {
    List<int> intensities = const [],
    int repeat = -1,
    int amplitude = -1,
  }) async {
    if (_shouldSuppressFeedback()) {
      return;
    }

    if (pattern.isEmpty) {
      await _fallbackPulse();
      return;
    }

    if (!await _safeHasVibrator()) {
      await _fallbackHaptics();
      return;
    }

    final supportsCustom = await _safeHasCustomSupport();
    if (!supportsCustom) {
      final fallbackDuration = pattern.firstWhere(
        (value) => value > 0,
        orElse: () => 60,
      );
      await Vibration.vibrate(duration: fallbackDuration);
      return;
    }

    try {
      await Vibration.vibrate(
        pattern: pattern,
        intensities: intensities,
        repeat: repeat,
        amplitude: amplitude,
      );
    } catch (_) {
      await _fallbackPulse();
    }
  }

  static Future<void> cancel() => Vibration.cancel();

  /// Expose platform capabilities so the UI can enable/disable buttons.
  static Future<VibrationCapabilities> getCapabilities() async {
    final hasVibrator = await _safeHasVibrator();
    final hasAmplitudeControl = await _safeHasAmplitudeControl();
    final hasCustomVibrationsSupport = await _safeHasCustomSupport();
    final canUseHaptics = await _safeCanUseHaptics();

    return VibrationCapabilities(
      hasVibrator: hasVibrator,
      hasAmplitudeControl: hasAmplitudeControl,
      hasCustomVibrationsSupport: hasCustomVibrationsSupport,
      canUseHaptics: canUseHaptics,
    );
  }

  static Future<void> _playHaptics(
    HapticsType type, {
    VibrationPreset? fallbackPreset,
  }) async {
    final canUseHaptics = await _safeCanUseHaptics();
    if (canUseHaptics) {
      try {
        await Haptics.vibrate(type, usage: HapticsUsage.media);
        return;
      } catch (_) {
        // Fall through to vibration fallback.
      }
    }

    if (fallbackPreset != null) {
      await _playPreset(fallbackPreset);
      return;
    }

    await _fallbackPulse();
  }

  static Future<void> _playPreset(
    VibrationPreset preset, {
    HapticsType? fallbackHaptics,
  }) async {
    final hasVibrator = await _safeHasVibrator();
    if (hasVibrator) {
      try {
        await Vibration.vibrate(preset: preset);
        return;
      } catch (_) {
        // If preset playback fails we will fallback to haptics.
      }
    }

    if (fallbackHaptics != null) {
      await _playHaptics(fallbackHaptics);
      return;
    }

    await _fallbackHaptics();
  }

  static Future<void> _fallbackHaptics() async {
    if (await _safeCanUseHaptics()) {
      try {
        await Haptics.vibrate(HapticsType.selection);
        return;
      } catch (_) {
        // Ignore and try final fallback.
      }
    }

    await _fallbackPulse();
  }

  static Future<void> _fallbackPulse({int duration = 60}) async {
    if (await _safeHasVibrator()) {
      await Vibration.vibrate(duration: duration);
    }
  }

  static Future<bool> _safeHasVibrator() async {
    try {
      return await Vibration.hasVibrator();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _safeHasAmplitudeControl() async {
    try {
      return await Vibration.hasAmplitudeControl();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _safeHasCustomSupport() async {
    try {
      return await Vibration.hasCustomVibrationsSupport();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _safeCanUseHaptics() async {
    try {
      return await Haptics.canVibrate();
    } catch (_) {
      return false;
    }
  }

  static bool _shouldSuppressFeedback() {
    return Prefs().reduceVibrationFeedback;
  }

  static const Map<VibrationType, HapticsType> _hapticsTypeMap = {
    VibrationType.success: HapticsType.success,
    VibrationType.warning: HapticsType.warning,
    VibrationType.error: HapticsType.error,
    VibrationType.light: HapticsType.light,
    VibrationType.medium: HapticsType.medium,
    VibrationType.heavy: HapticsType.heavy,
    VibrationType.rigid: HapticsType.rigid,
    VibrationType.soft: HapticsType.soft,
    VibrationType.selection: HapticsType.selection,
  };

  static const Map<VibrationType, VibrationPreset> _hapticsFallbackPreset = {
    VibrationType.success: VibrationPreset.quickSuccessAlert,
    VibrationType.warning: VibrationPreset.zigZagAlert,
    VibrationType.error: VibrationPreset.emergencyAlert,
    VibrationType.light: VibrationPreset.singleShortBuzz,
    VibrationType.medium: VibrationPreset.doubleBuzz,
    VibrationType.heavy: VibrationPreset.longAlarmBuzz,
    VibrationType.rigid: VibrationPreset.pulseWave,
    VibrationType.soft: VibrationPreset.softPulse,
    VibrationType.selection: VibrationPreset.rapidTapFeedback,
  };

  static const Map<VibrationType, VibrationPreset> _presetMap = {
    VibrationType.singleShortBuzz: VibrationPreset.singleShortBuzz,
    VibrationType.doubleBuzz: VibrationPreset.doubleBuzz,
    VibrationType.tripleBuzz: VibrationPreset.tripleBuzz,
    VibrationType.longAlarmBuzz: VibrationPreset.longAlarmBuzz,
    VibrationType.pulseWave: VibrationPreset.pulseWave,
    VibrationType.progressiveBuzz: VibrationPreset.progressiveBuzz,
    VibrationType.rhythmicBuzz: VibrationPreset.rhythmicBuzz,
    VibrationType.gentleReminder: VibrationPreset.gentleReminder,
    VibrationType.quickSuccessAlert: VibrationPreset.quickSuccessAlert,
    VibrationType.zigZagAlert: VibrationPreset.zigZagAlert,
    VibrationType.softPulse: VibrationPreset.softPulse,
    VibrationType.emergencyAlert: VibrationPreset.emergencyAlert,
    VibrationType.heartbeatVibration: VibrationPreset.heartbeatVibration,
    VibrationType.countdownTimerAlert: VibrationPreset.countdownTimerAlert,
    VibrationType.rapidTapFeedback: VibrationPreset.rapidTapFeedback,
    VibrationType.dramaticNotification: VibrationPreset.dramaticNotification,
    VibrationType.urgentBuzzWave: VibrationPreset.urgentBuzzWave,
  };

  static const Map<VibrationType, HapticsType> _presetFallbackHaptics = {
    VibrationType.singleShortBuzz: HapticsType.selection,
    VibrationType.doubleBuzz: HapticsType.light,
    VibrationType.tripleBuzz: HapticsType.medium,
    VibrationType.longAlarmBuzz: HapticsType.heavy,
    VibrationType.pulseWave: HapticsType.rigid,
    VibrationType.progressiveBuzz: HapticsType.medium,
    VibrationType.rhythmicBuzz: HapticsType.rigid,
    VibrationType.gentleReminder: HapticsType.soft,
    VibrationType.quickSuccessAlert: HapticsType.success,
    VibrationType.zigZagAlert: HapticsType.warning,
    VibrationType.softPulse: HapticsType.soft,
    VibrationType.emergencyAlert: HapticsType.error,
    VibrationType.heartbeatVibration: HapticsType.soft,
    VibrationType.countdownTimerAlert: HapticsType.medium,
    VibrationType.rapidTapFeedback: HapticsType.selection,
    VibrationType.dramaticNotification: HapticsType.heavy,
    VibrationType.urgentBuzzWave: HapticsType.heavy,
  };
}

/// Snapshot of the vibration features that the device reports.
class VibrationCapabilities {
  final bool hasVibrator;
  final bool hasAmplitudeControl;
  final bool hasCustomVibrationsSupport;
  final bool canUseHaptics;

  const VibrationCapabilities({
    required this.hasVibrator,
    required this.hasAmplitudeControl,
    required this.hasCustomVibrationsSupport,
    required this.canUseHaptics,
  });

  bool get hasAnyVibration => hasVibrator || canUseHaptics;
}

enum VibrationType {
  success,
  warning,
  error,
  light,
  medium,
  heavy,
  rigid,
  soft,
  selection,
  singleShortBuzz,
  doubleBuzz,
  tripleBuzz,
  longAlarmBuzz,
  pulseWave,
  progressiveBuzz,
  rhythmicBuzz,
  gentleReminder,
  quickSuccessAlert,
  zigZagAlert,
  softPulse,
  emergencyAlert,
  heartbeatVibration,
  countdownTimerAlert,
  rapidTapFeedback,
  dramaticNotification,
  urgentBuzzWave,
}

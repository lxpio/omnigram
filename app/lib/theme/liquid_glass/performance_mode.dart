import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'performance_mode.g.dart';

enum GlassQuality {
  high,
  medium,
  low;

  bool get hasBlur => this == GlassQuality.high;
  bool get hasMotion => this != GlassQuality.low;

  GlassQuality steppedDownForReader() => switch (this) {
        GlassQuality.high => GlassQuality.medium,
        GlassQuality.medium => GlassQuality.low,
        GlassQuality.low => GlassQuality.low,
      };
}

enum GlassQualityOverride { auto, high, medium, low }

enum GlassPlatform { iOS, macOS, android, windows, other }

GlassQuality resolveAutoQuality({
  required GlassPlatform platform,
  required int totalRamMb,
  required int sdkInt,
}) {
  switch (platform) {
    case GlassPlatform.iOS:
    case GlassPlatform.macOS:
    case GlassPlatform.windows:
      return GlassQuality.high;
    case GlassPlatform.android:
      if (sdkInt < 31) return GlassQuality.low;
      if (totalRamMb >= 6 * 1024) return GlassQuality.high;
      if (totalRamMb >= 4 * 1024) return GlassQuality.medium;
      return GlassQuality.low;
    case GlassPlatform.other:
      return GlassQuality.medium;
  }
}

const _kOverrideKey = 'glass_quality_override';
const _kCachedAutoKey = 'glass_quality_auto_cache';

@Riverpod(keepAlive: true)
class GlassQualityController extends _$GlassQualityController {
  @override
  Future<GlassQuality> build() async {
    final prefs = await SharedPreferences.getInstance();
    final overrideName = prefs.getString(_kOverrideKey) ?? GlassQualityOverride.auto.name;
    final override = GlassQualityOverride.values.firstWhere(
      (e) => e.name == overrideName,
      orElse: () => GlassQualityOverride.auto,
    );
    if (override != GlassQualityOverride.auto) {
      return GlassQuality.values.byName(override.name);
    }
    final cached = prefs.getString(_kCachedAutoKey);
    if (cached != null) {
      return GlassQuality.values.byName(cached);
    }
    final auto = await _detect();
    await prefs.setString(_kCachedAutoKey, auto.name);
    return auto;
  }

  Future<void> setOverride(GlassQualityOverride override) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOverrideKey, override.name);
    ref.invalidateSelf();
  }

  Future<GlassQuality> _detect() async {
    final info = DeviceInfoPlugin();
    if (Platform.isIOS) {
      return resolveAutoQuality(platform: GlassPlatform.iOS, totalRamMb: 0, sdkInt: 0);
    }
    if (Platform.isMacOS) {
      return resolveAutoQuality(platform: GlassPlatform.macOS, totalRamMb: 0, sdkInt: 0);
    }
    if (Platform.isWindows) {
      return resolveAutoQuality(platform: GlassPlatform.windows, totalRamMb: 0, sdkInt: 0);
    }
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      final isHighEnd = a.version.sdkInt >= 31 && a.supported64BitAbis.isNotEmpty;
      return resolveAutoQuality(
        platform: GlassPlatform.android,
        totalRamMb: isHighEnd ? 6 * 1024 : 2 * 1024,
        sdkInt: a.version.sdkInt,
      );
    }
    return GlassQuality.medium;
  }
}

@riverpod
GlassQuality readerGlassQuality(Ref ref) {
  final globalAsync = ref.watch(glassQualityControllerProvider);
  return globalAsync.maybeWhen(
    data: (q) => q.steppedDownForReader(),
    orElse: () => GlassQuality.low,
  );
}

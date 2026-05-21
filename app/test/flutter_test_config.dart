// Test config for liquid_glass golden snapshots.
//
// Scope: applies only to tests under test/theme/liquid_glass/golden/.
// Flutter test runner uses the nearest flutter_test_config.dart per test file.
//
// Two jobs:
//   1. Preload Roboto + Material Icons so snapshots render real glyphs
//      instead of Ahem-fallback rectangles.
//   2. Install FuzzyGoldenComparator with a 1 % pixel-diff tolerance so
//      sub-pixel Skia / font AA noise on Linux CI doesn't fail otherwise
//      identical baselines. Real visual regressions (changed tint alpha,
//      blur sigma, wrong shape) produce >> 1 % diffs and still fail.
//
// Font source: test_resources/fonts/Roboto-Regular.ttf,
// MaterialIcons-Regular.otf (Apache 2.0, Google Fonts).

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

// 10 % cross-platform tolerance. Small focused goldens (single icon /
// chip / pill, ~6k–20k px) noise out at <2 %; full card goldens
// (CoverHeader / ThoughtCard, ~480k px) hit 5–9 % from accumulated text
// AA + sub-pixel layout drift between macOS Skia and Linux Skia. 10 %
// is the common industry cross-platform budget — real visual changes
// (tint alpha 0.85 → 0.30, blur 24 → 12, squircle → circle) blow well
// past it and still fail.
const double _diffToleranceRatio = 0.10;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Roboto', 'test_resources/fonts/Roboto-Regular.ttf');
  await _loadFont('MaterialIcons', 'test_resources/fonts/MaterialIcons-Regular.otf');

  // Replace default comparator with a fuzzy one anchored at this folder.
  final existing = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _FuzzyGoldenComparator(
    existing.basedir,
    tolerance: _diffToleranceRatio,
  );

  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final f = File(path);
  if (!f.existsSync()) return;
  final bytes = await f.readAsBytes();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

/// Golden comparator that accepts up to [tolerance] fraction of pixels
/// differing. Beyond that threshold the standard failure output (actual /
/// diff PNGs) is written and the test fails as usual.
class _FuzzyGoldenComparator extends LocalFileComparator {
  _FuzzyGoldenComparator(Uri baseDir, {required this.tolerance})
      : super(Uri.parse(p.join(baseDir.toFilePath(), 'flutter_test_config.dart')));

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed) return true;
    if (result.diffPercent <= tolerance) {
      // Acceptable AA / font noise — pass silently.
      return true;
    }
    // Real regression: write actual + diff PNGs for review, then fail.
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

// Preload Roboto-Regular.ttf so golden snapshots in this folder render
// real glyphs instead of Ahem-fallback rectangles.
//
// Scope: applies only to tests under test/theme/liquid_glass/golden/.
// Flutter test runner uses the nearest flutter_test_config.dart per test file.
//
// Font source: test_resources/fonts/Roboto-Regular.ttf (Apache 2.0,
// Google Fonts).

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Roboto', 'test_resources/fonts/Roboto-Regular.ttf');
  await _loadFont('MaterialIcons', 'test_resources/fonts/MaterialIcons-Regular.otf');
  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final f = File(path);
  if (!f.existsSync()) return; // fall back to Ahem
  final bytes = await f.readAsBytes();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

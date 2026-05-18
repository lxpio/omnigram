import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('high quality includes BackdropFilter', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.high, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('medium quality omits BackdropFilter', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.medium, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('low quality omits BackdropFilter', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.low, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}

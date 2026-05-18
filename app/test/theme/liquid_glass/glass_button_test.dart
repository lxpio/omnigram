import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_button.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('tap fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () => taps++,
      child: const Text('Hi'),
    )));
    await tester.tap(find.text('Hi'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('low quality does not animate scale', (tester) async {
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.low,
      onPressed: () {},
      child: const Text('Hi'),
    )));
    expect(find.byType(AnimatedScale), findsNothing);
  });

  testWidgets('high quality wraps with AnimatedScale', (tester) async {
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () {},
      child: const Text('Hi'),
    )));
    expect(find.byType(AnimatedScale), findsOneWidget);
  });

  testWidgets('press calls HapticFeedback.lightImpact', (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });

    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () {},
      child: const Text('Hi'),
    )));
    await tester.tap(find.text('Hi'));
    await tester.pumpAndSettle();

    expect(
      calls.any((c) =>
          c.method == 'HapticFeedback.vibrate' &&
          c.arguments == 'HapticFeedbackType.lightImpact'),
      isTrue,
    );
  });
}

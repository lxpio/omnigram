import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  testWidgets('GlassAppBar fade layer starts at low opacity and increases on scroll',
      (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          quality: GlassQuality.high,
          title: const Text('T'),
          scrollController: controller,
        ),
        body: ListView.builder(
          controller: controller,
          itemCount: 40,
          itemBuilder: (_, i) => SizedBox(height: 50, child: Text('$i')),
        ),
      ),
    ));

    final initial =
        tester.widget<Opacity>(find.byKey(const Key('glass_app_bar_layer'))).opacity;
    expect(initial, lessThan(0.2));

    controller.jumpTo(200);
    await tester.pump();
    final after =
        tester.widget<Opacity>(find.byKey(const Key('glass_app_bar_layer'))).opacity;
    expect(after, greaterThan(0.8));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'glass_app_bar.dart';
import 'performance_mode.dart';

/// Drop-in replacement for `AppBar` that reads the current GlassQuality
/// from the provider scope. Use this for sub-page migration:
///
///   appBar: AppGlassAppBar(title: Text('Foo'), actions: [...]),
class AppGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppGlassAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.height = kToolbarHeight,
  });

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final q =
          ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium;
      return GlassAppBar(
        quality: q,
        title: title,
        actions: actions,
        leading: leading,
        height: height,
      );
    });
  }
}

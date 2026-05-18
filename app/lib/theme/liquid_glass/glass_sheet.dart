import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required GlassQuality quality,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: GlassSurface(
        quality: quality,
        borderRadius: GlassTokens.radiusSheet,
        blurSigma: GlassTokens.blurSigmaThick,
        padding: const EdgeInsets.all(16),
        child: SafeArea(top: false, child: builder(ctx)),
      ),
    ),
  );
}

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required GlassQuality quality,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    pageBuilder: (ctx, _, _) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassSurface(
          quality: quality,
          borderRadius: GlassTokens.radiusSheet,
          blurSigma: GlassTokens.blurSigmaUltra,
          padding: const EdgeInsets.all(20),
          child: builder(ctx),
        ),
      ),
    ),
  );
}

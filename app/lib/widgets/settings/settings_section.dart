import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';
import 'package:flutter/material.dart';

abstract class AbstractSettingsSection extends StatelessWidget {
  const AbstractSettingsSection({super.key});
}

class SettingsSection extends AbstractSettingsSection {
  const SettingsSection({
    super.key,
    required this.tiles,
    this.margin,
    this.title,
  });

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return buildSectionBody(context);
  }

  Widget buildSectionBody(BuildContext context) {
    final tileList = buildTileList();
    final scheme = Theme.of(context).colorScheme;

    if (title == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _glassWrap(tileList),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 22,
            bottom: 10,
            start: 24,
            end: 24,
          ),
          child: DefaultTextStyle(
            style: OmnigramTypography.titleMedium(context).copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            child: title!,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _glassWrap(tileList),
        ),
      ],
    );
  }

  Widget _glassWrap(Widget child) {
    return Consumer(builder: (context, ref, _) {
      final q = ref.watch(glassQualityControllerProvider).valueOrNull ??
          GlassQuality.medium;
      return GlassSurface(
        quality: q,
        borderRadius: GlassTokens.radiusBar,
        blurSigma: GlassTokens.blurSigmaThin,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        ),
      );
    });
  }

  Widget buildTileList() {
    return Column(
      children: tiles,
    );
  }
}

class CustomSettingsSection extends AbstractSettingsSection {
  const CustomSettingsSection({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

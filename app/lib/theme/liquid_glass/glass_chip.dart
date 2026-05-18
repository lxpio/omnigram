import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.quality,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final GlassQuality quality;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        quality: quality,
        borderRadius: GlassTokens.radiusButton,
        blurSigma: GlassTokens.blurSigmaThin,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius:
                        BorderRadius.circular(GlassTokens.radiusButton * 2.2),
                  ),
                ),
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

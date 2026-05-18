import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassPopupMenuItem<T> {
  const GlassPopupMenuItem({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

Future<T?> showGlassPopupMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<GlassPopupMenuItem<T>> items,
  required GlassQuality quality,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final rect = RelativeRect.fromRect(
    Rect.fromPoints(position, position),
    Offset.zero & overlay.size,
  );

  return showMenu<T>(
    context: context,
    position: rect,
    color: Colors.transparent,
    elevation: 0,
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(GlassTokens.radiusMenu * 2.2),
    ),
    items: [
      PopupMenuItem<T>(
        padding: EdgeInsets.zero,
        enabled: false,
        child: GlassSurface(
          quality: quality,
          borderRadius: GlassTokens.radiusMenu,
          blurSigma: GlassTokens.blurSigmaThick,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items)
                InkWell(
                  onTap: () => Navigator.of(context).pop(item.value),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 18),
                          const SizedBox(width: 12),
                        ],
                        Text(item.label),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassTabItem {
  const GlassTabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class GlassTabBarController extends ChangeNotifier {
  bool _collapsed = false;
  Timer? _debounce;
  double _accumDown = 0.0;

  bool get collapsed => _collapsed;

  void handleScrollDelta(double delta) {
    if (delta < 0) {
      _debounce?.cancel();
      _accumDown = 0;
      if (_collapsed) {
        _collapsed = false;
        notifyListeners();
      }
      return;
    }
    _accumDown += delta;
    if (_accumDown < GlassTokens.tabCollapseScrollThreshold) return;
    _debounce?.cancel();
    _debounce = Timer(GlassTokens.tabCollapseDebounce, () {
      if (!_collapsed) {
        _collapsed = true;
        notifyListeners();
      }
    });
  }

  void expand() {
    if (_collapsed) {
      _collapsed = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.quality,
    required this.controller,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final GlassQuality quality;
  final GlassTabBarController controller;
  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collapsed = quality.hasMotion && controller.collapsed;
        return SafeArea(
          top: false,
          child: AnimatedAlign(
            duration: GlassTokens.tabCollapse,
            curve: Curves.easeOutCubic,
            alignment: collapsed ? Alignment.bottomRight : Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: GlassTokens.tabCollapse,
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(
                left: collapsed ? 0 : 16,
                right: 16,
                bottom: collapsed ? 24 : 16,
              ),
              child: GlassSurface(
                quality: quality,
                borderRadius: collapsed ? GlassTokens.radiusCapsule : GlassTokens.radiusBar,
                blurSigma: GlassTokens.blurSigmaThick,
                child: collapsed
                    ? _CollapsedCapsule(
                        item: items[currentIndex],
                        onTap: controller.expand,
                      )
                    : _ExpandedRow(
                        items: items,
                        currentIndex: currentIndex,
                        onTap: onTap,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  const _ExpandedRow({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkResponse(
              onTap: () => onTap(i),
              radius: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      color: i == currentIndex
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: i == currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollapsedCapsule extends StatelessWidget {
  const _CollapsedCapsule({required this.item, required this.onTap});

  final GlassTabItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(item.icon, size: 24, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        // Fixed total height = bar content + bottom margin + safe area inset.
        // Without this, Align in the bottomNavigationBar slot expands
        // unbounded and produces a giant blank area below the icons.
        const barContentHeight = 56.0;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        return SizedBox(
          height: barContentHeight + 16 + safeBottom,
          child: SafeArea(
            top: false,
            child: Align(
              alignment: collapsed ? Alignment.bottomRight : Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: GlassTokens.tabCollapse,
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(
                  left: collapsed ? 0 : 16,
                  right: 16,
                  bottom: collapsed ? 8 : 16,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      (collapsed ? GlassTokens.radiusCapsule : GlassTokens.radiusBar) * 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: GlassSurface(
                    quality: quality,
                    borderRadius:
                        collapsed ? GlassTokens.radiusCapsule : GlassTokens.radiusBar,
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
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / items.length;
        return SizedBox(
          height: 56,
          child: Stack(
            children: [
              // Sliding indicator pill — soft, low-contrast, drifts between tabs.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: tabWidth * currentIndex + 6,
                top: 6,
                bottom: 6,
                width: tabWidth - 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(GlassTokens.radiusButton * 1.6),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _TabButton(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _pressed = false;

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      label: widget.item.label,
      selected: widget.selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Center(
            child: Icon(widget.item.icon, size: 26, color: color),
          ),
        ),
      ),
    );
  }
}

class _CollapsedCapsule extends StatefulWidget {
  const _CollapsedCapsule({required this.item, required this.onTap});

  final GlassTabItem item;
  final VoidCallback onTap;

  @override
  State<_CollapsedCapsule> createState() => _CollapsedCapsuleState();
}

class _CollapsedCapsuleState extends State<_CollapsedCapsule> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            widget.item.icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

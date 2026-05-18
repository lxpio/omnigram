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
    this.trailing,
  });

  final GlassQuality quality;
  final GlassTabBarController controller;
  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional contextual capsule rendered to the right of the tab bar
  /// (e.g. GlassActionPill). Hidden when the bar is collapsed.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collapsed = quality.hasMotion && controller.collapsed;
        // Fixed total height = bar content + bottom margin + safe area inset.
        // Without this, Align in the bottomNavigationBar slot expands
        // unbounded and produces a giant blank area below the icons.
        const barContentHeight = 60.0;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        final tabCapsule = DecoratedBox(
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
        );

        return SizedBox(
          height: barContentHeight + 16 + safeBottom,
          child: SafeArea(
            top: false,
            child: Align(
              alignment: collapsed ? Alignment.bottomRight : Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  right: collapsed ? 16 : 0,
                  bottom: collapsed ? 8 : 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    tabCapsule,
                    if (!collapsed && trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
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

  // Compact tab: cell holds icon + small label, bar wraps content.
  static const double _tabWidth = 60.0;
  static const double _barHeight = 60.0;
  static const double _innerPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _tabWidth * items.length + _innerPadding * 2,
      height: _barHeight,
      child: Padding(
        padding: const EdgeInsets.all(_innerPadding),
        child: Stack(
          children: [
            // Sliding indicator pill — drifts between tab cells.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: _tabWidth * currentIndex,
              top: 0,
              bottom: 0,
              width: _tabWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GlassTokens.radiusButton * 1.6),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                    width: _tabWidth,
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
      ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.item.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
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

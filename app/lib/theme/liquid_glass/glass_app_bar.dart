import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

/// AppBar with iOS 26 scroll-edge fade.
///
/// Designed for `Scaffold.appBar`. Pair with `Scaffold.extendBodyBehindAppBar: true`
/// so content scrolls beneath the glass. Attaches to the enclosing
/// `PrimaryScrollController` (or any passed `scrollController`).
class GlassAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.quality,
    required this.title,
    this.actions = const [],
    this.leading,
    this.scrollController,
    this.height = kToolbarHeight,
    this.fadeOverPixels = 80.0,
  });

  final GlassQuality quality;
  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final ScrollController? scrollController;
  final double height;
  final double fadeOverPixels;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<GlassAppBar> createState() => _GlassAppBarState();
}

class _GlassAppBarState extends State<GlassAppBar> {
  double _scrolledFraction = 0.0;
  ScrollController? _attached;

  void _onScroll() {
    final c = _attached;
    if (c == null || !c.hasClients) return;
    final f = (c.offset / widget.fadeOverPixels).clamp(0.0, 1.0);
    if ((f - _scrolledFraction).abs() > 0.02) {
      setState(() => _scrolledFraction = f);
    }
  }

  void _attach(ScrollController? c) {
    if (identical(c, _attached)) return;
    _attached?.removeListener(_onScroll);
    _attached = c;
    _attached?.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach(widget.scrollController ?? PrimaryScrollController.maybeOf(context));
  }

  @override
  void didUpdateWidget(covariant GlassAppBar old) {
    super.didUpdateWidget(old);
    if (old.scrollController != widget.scrollController) {
      _attach(widget.scrollController ?? PrimaryScrollController.maybeOf(context));
    }
  }

  @override
  void dispose() {
    _attached?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Opacity(
      key: const Key('glass_app_bar_layer'),
      opacity: _scrolledFraction,
      child: GlassSurface(
        quality: widget.quality,
        borderRadius: 0,
        blurSigma: GlassTokens.blurSigmaThick,
        child: const SizedBox.expand(),
      ),
    );

    final bar = SafeArea(
      bottom: false,
      child: SizedBox(
        height: widget.height,
        child: NavigationToolbar(
          leading: widget.leading,
          middle: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.titleLarge!,
            child: widget.title,
          ),
          trailing: widget.actions.isEmpty
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: widget.actions),
        ),
      ),
    );

    return SizedBox(
      height: widget.height + MediaQuery.of(context).padding.top,
      child: Stack(children: [Positioned.fill(child: glass), bar]),
    );
  }
}

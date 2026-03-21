import 'dart:ui';

import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';

class DashboardTileDetailView extends ConsumerStatefulWidget {
  const DashboardTileDetailView({
    super.key,
    required this.tile,
    required this.heroTag,
    this.animationValue = 1.0,
  });

  final StatisticsDashboardTileBase tile;
  final String heroTag;
  final double animationValue;

  @override
  ConsumerState<DashboardTileDetailView> createState() =>
      _DashboardTileDetailViewState();
}

class _DashboardTileDetailViewState
    extends ConsumerState<DashboardTileDetailView> {
  Offset _dragOffset = Offset.zero;
  double _blurSigma = 10.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Initialize blur based on animation value
    _blurSigma = widget.animationValue * 10.0;
  }

  @override
  void didUpdateWidget(DashboardTileDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update blur when animation value changes
    if (oldWidget.animationValue != widget.animationValue) {
      setState(() {
        _blurSigma = widget.animationValue * 10.0;
      });
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;

      // Calculate blur based on drag distance from center, but also consider the animation value
      final distance = _dragOffset.distance;
      const maxDistance = 200.0;
      final dragBlurFactor = (1.0 - (distance / maxDistance).clamp(0.0, 1.0));
      _blurSigma = dragBlurFactor * widget.animationValue * 10.0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final shouldDismiss = velocity.distance > 500 || _dragOffset.distance > 100;

    if (shouldDismiss) {
      Navigator.of(context).pop();
    } else {
      // Spring back to center
      setState(() {
        _dragOffset = Offset.zero;
        _blurSigma = widget.animationValue * 10.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop with blur
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                  alpha: 0.4 * (widget.animationValue * _blurSigma / 10.0)),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurSigma,
                sigmaY: _blurSigma,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),

        // Draggable card
        AnimatedPositioned(
          duration:
              _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          left: MediaQuery.of(context).size.width / 2 -
              widget.tile.flipSize(context).width / 2 +
              _dragOffset.dx,
          top: MediaQuery.of(context).size.height / 2 -
              widget.tile.flipSize(context).height / 2 +
              _dragOffset.dy,
          child: GestureDetector(
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            child: Heroine(
              tag: widget.heroTag,
              child: widget.tile.buildFlipSide(context, ref),
            ),
          ),
        ),
      ],
    );
  }
}

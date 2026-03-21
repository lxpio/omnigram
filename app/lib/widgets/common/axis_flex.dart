import 'package:flutter/widgets.dart';

/// A lightweight wrapper that switches between [Row] and [Column]
/// based on the provided [axis].
class AxisFlex extends StatelessWidget {
  const AxisFlex({
    super.key,
    required this.axis,
    required this.children,
    this.reverse = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  });

  /// The direction in which the children should be laid out.
  final Axis axis;

  /// Whether to display the children in reverse order.
  final bool reverse;

  /// The widgets below this widget in the tree.
  final List<Widget> children;

  /// {@macro flutter.rendering.flex.mainAxisAlignment}
  final MainAxisAlignment mainAxisAlignment;

  /// {@macro flutter.rendering.flex.mainAxisSize}
  final MainAxisSize mainAxisSize;

  /// {@macro flutter.rendering.flex.crossAxisAlignment}
  final CrossAxisAlignment crossAxisAlignment;

  /// {@macro flutter.rendering.flex.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.rendering.flex.verticalDirection}
  final VerticalDirection verticalDirection;

  /// {@macro flutter.rendering.flex.textBaseline}
  final TextBaseline? textBaseline;

  List<Widget> get _effectiveChildren =>
      reverse ? children.reversed.toList(growable: false) : children;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: _effectiveChildren,
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: _effectiveChildren,
    );
  }
}

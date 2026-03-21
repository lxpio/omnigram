import 'package:omnigram/widgets/common/container/base_rounded_container.dart';
import 'package:flutter/material.dart';

class OutlinedContainer extends BaseRoundedContainer {
  const OutlinedContainer({
    super.key,
    required super.child,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.radius,
    super.constraints,
    super.animationDuration,
    super.animationCurve,
    this.color,
    this.outlineColor,
  });

  final Color? color;
  final Color? outlineColor;

  @override
  ShapeDecoration decoration(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    return buildShapeDecoration(
      color: color ?? Theme.of(context).colorScheme.surface,
      borderSide: BorderSide(
          color: outlineColor ?? Theme.of(context).colorScheme.outline,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside),
      borderRadius: borderRadius,
    );
  }
}

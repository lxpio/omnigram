import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/widgets/common/container/base_rounded_container.dart';
import 'package:omnigram/widgets/common/container/outlined_container.dart';
import 'package:flutter/material.dart';

class FilledContainer extends BaseRoundedContainer {
  const FilledContainer({
    super.key,
    required super.child,
    super.width,
    super.height,
    super.padding,
    super.margin,
    this.color,
    this.fill = false,
    super.radius,
    super.constraints,
    super.animationDuration,
    super.animationCurve,
  });

  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    if (Prefs().eInkMode && !fill) {
      return OutlinedContainer(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        radius: radius,
        constraints: constraints,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        child: child,
      );
    }

    return super.build(context);
  }

  @override
  ShapeDecoration decoration(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    final Color effectiveColor =
        color ?? Theme.of(context).colorScheme.surfaceContainer;

    return buildShapeDecoration(
      color: effectiveColor,
      borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside),
      borderRadius: borderRadius,
    );
  }
}

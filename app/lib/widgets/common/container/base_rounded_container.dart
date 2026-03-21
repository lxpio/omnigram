import 'package:flutter/material.dart';

abstract class BaseRoundedContainer extends StatelessWidget {
  const BaseRoundedContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.radius,
    this.constraints,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOut,
  });

  static const double _defaultRadius = 30;

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final BoxConstraints? constraints;
  final Duration animationDuration;
  final Curve animationCurve;

  BorderRadiusGeometry get _borderRadius =>
      BorderRadiusGeometry.circular(radius ?? _defaultRadius);

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry borderRadius = _borderRadius;

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      margin: margin?.add(const EdgeInsets.all(1)) ?? const EdgeInsets.all(1),
      width: width,
      height: height,
      constraints: constraints,
      decoration: decoration(context, borderRadius),
      child: ClipRSuperellipse(
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  ShapeDecoration decoration(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  );

  @protected
  ShapeDecoration buildShapeDecoration({
    Color? color,
    required BorderSide borderSide,
    required BorderRadiusGeometry borderRadius,
  }) {
    return ShapeDecoration(
      color: color,
      shape: RoundedSuperellipseBorder(
        borderRadius: borderRadius,
        side: borderSide,
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A widget that wraps [Text] with [FittedBox] to automatically scale text
/// to fit within specified constraints.
class FittedText extends StatelessWidget {
  const FittedText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    this.clipBehavior = Clip.hardEdge,
    this.maxHeight,
    this.maxWidth,
  });

  /// The text to display.
  final String data;

  /// If non-null, the style to use for this text.
  final TextStyle? style;

  /// {@macro flutter.widgets.text.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The font scaling strategy to use.
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// An alternative semantics label for this text.
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.painting.textPainter.textHeightBehavior}
  final ui.TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  /// How to inscribe the child into the space allocated during layout.
  final BoxFit fit;

  /// How to align the child within its parent's bounds.
  final AlignmentGeometry alignment;

  /// The content will be clipped (or not) according to this option.
  final Clip clipBehavior;

  /// The maximum height constraint for the fitted text.
  /// If provided, the widget will be wrapped in a [ConstrainedBox] with [maxHeight].
  final double? maxHeight;

  /// The maximum width constraint for the fitted text.
  /// If provided, the widget will be wrapped in a [ConstrainedBox] with [maxWidth].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = FittedBox(
      fit: fit,
      alignment: alignment,
      clipBehavior: clipBehavior,
      child: Text(
        data,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );

    // Apply constraints if maxHeight or maxWidth is provided
    if (maxHeight != null || maxWidth != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? double.infinity,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }

    return child;
  }
}

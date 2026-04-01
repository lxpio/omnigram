import 'package:flutter/material.dart';

enum EmptyPageType { desk, library, insights, companion }

sealed class EmptyVisualType {
  const EmptyVisualType();
}

class EmptyVisualLottie extends EmptyVisualType {
  final String assetPath;
  const EmptyVisualLottie(this.assetPath);
}

class EmptyVisualSvg extends EmptyVisualType {
  final String assetPath;
  const EmptyVisualSvg(this.assetPath);
}

class EmptyVisualIcon extends EmptyVisualType {
  final IconData iconData;
  const EmptyVisualIcon(this.iconData);
}

class EmptyStateData {
  final String message;
  final EmptyVisualType visualType;
  final String? actionLabel;

  const EmptyStateData({
    required this.message,
    required this.visualType,
    this.actionLabel,
  });
}

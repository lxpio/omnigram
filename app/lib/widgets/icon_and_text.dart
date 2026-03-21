import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:flutter/material.dart';

class IconAndText extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback? onTap;
  final double? fontSize;
  final bool compact;

  const IconAndText({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.fontSize,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double width = compact ? 42 : 48;
    final double height = compact ? 50 : 60;

    if (!Prefs().showActionLabels) {
      if (onTap == null) {
        return SizedBox(
          width: width,
          height: height,
          child: Center(child: icon),
        );
      }

      return IconButton(
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: icon,
        tooltip: text,
      );
    }

    Widget content = SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: compact ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              constraints: BoxConstraints(maxWidth: compact ? 72 : 96),
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}

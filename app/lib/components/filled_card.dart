import 'package:flutter/material.dart';

class OutlinedCard extends StatefulWidget {
  const OutlinedCard({
    super.key,
    required this.child,
    this.clickable = true,
  });

  final Widget child;
  final bool clickable;

  @override
  State<OutlinedCard> createState() => _OutlinedCardState();
}

class _OutlinedCardState extends State<OutlinedCard> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.clickable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,

          // boxShadow: [],
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.outline,
          //   width: 1,
          // ),
        ),
        child: widget.child,
      ),
    );
  }
}

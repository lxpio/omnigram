import 'package:omnigram/widgets/common/container/outlined_container.dart';
import 'package:flutter/material.dart';

class ToolTileBase extends StatefulWidget {
  const ToolTileBase({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.statusColor,
    this.initiallyExpanded = false,
    this.contentBuilder,
  });

  final String title;
  final IconData leadingIcon;
  final Color statusColor;
  final bool initiallyExpanded;
  final WidgetBuilder? contentBuilder;

  bool get expandable => contentBuilder != null;

  static Color statusColorFor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  State<ToolTileBase> createState() => _ToolTileBaseState();
}

class _ToolTileBaseState extends State<ToolTileBase> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    if (!widget.expandable) {
      return;
    }
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedContainer(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      radius: 14,
      child: InkWell(
        onTap: widget.expandable ? _toggle : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.leadingIcon, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            if (widget.expandable && _expanded) ...[
              const SizedBox(height: 8),
              widget.contentBuilder!(context),
            ],
          ],
        ),
      ),
    );
  }
}

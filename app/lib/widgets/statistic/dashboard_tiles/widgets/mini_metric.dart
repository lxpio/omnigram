import 'package:flutter/material.dart';

class DashboardMiniMetric extends StatelessWidget {
  const DashboardMiniMetric({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

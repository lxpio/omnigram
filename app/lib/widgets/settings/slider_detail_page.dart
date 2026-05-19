import 'package:flutter/material.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';

/// Generic detail page for editing a single double value via a slider.
/// Pushed from a SettingsTile.navigation row.
class SliderDetailPage extends StatefulWidget {
  const SliderDetailPage({
    super.key,
    required this.title,
    required this.initial,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.helpText,
    this.unitSuffix = '',
    this.valueFormatter,
  });

  final String title;
  final String? helpText;
  final double initial;
  final double min;
  final double max;
  final int divisions;
  final String unitSuffix;
  final ValueChanged<double> onChanged;

  /// Optional formatter — defaults to `value.toInt() + unitSuffix`.
  final String Function(double)? valueFormatter;

  @override
  State<SliderDetailPage> createState() => _SliderDetailPageState();
}

class _SliderDetailPageState extends State<SliderDetailPage> {
  late double _value = widget.initial;

  String _label(double v) =>
      widget.valueFormatter?.call(v) ?? '${v.toInt()}${widget.unitSuffix}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppGlassAppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(_value),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: _label(_value),
                onChanged: (v) {
                  setState(() => _value = v);
                  widget.onChanged(v);
                },
              ),
              if (widget.helpText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.helpText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/widgets/common/axis_flex.dart';

class GlossaryTooltip extends ConsumerStatefulWidget {
  const GlossaryTooltip({
    super.key,
    required this.content,
    required this.decoration,
    required this.axis,
    this.contextText,
    required this.onClose,
  });

  final String content;
  final BoxDecoration decoration;
  final Axis axis;
  final String? contextText;
  final VoidCallback onClose;

  @override
  ConsumerState<GlossaryTooltip> createState() => _GlossaryTooltipState();
}

class _GlossaryTooltipState extends ConsumerState<GlossaryTooltip> {
  String? _explanation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchExplanation();
  }

  Future<void> _fetchExplanation() async {
    if (!AiAvailability.isAvailable(ref)) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await AmbientTasks.glossary(
      ref: ref,
      selectedText: widget.content,
      contextText: (widget.contextText?.trim().isEmpty ?? true) ? null : widget.contextText,
    );

    if (mounted) {
      setState(() {
        _explanation = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          height: widget.axis == Axis.vertical ? double.infinity : 150,
          width: widget.axis == Axis.vertical ? 100 : double.infinity,
          decoration: widget.decoration,
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AxisFlex(
                  axis: widget.axis,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.content,
                        style: const TextStyle(
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const SizedBox(height: 20, child: Center(child: Text('...')))
                else if (_explanation != null)
                  Text(
                    _explanation!,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  )
                else
                  Text(
                    'AI unavailable',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/utils/ai_reasoning_parser.dart';
import 'package:omnigram/widgets/ai/tool_tiles/tool_tile_base.dart';
import 'package:omnigram/widgets/common/container/filled_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class MindmapStepTile extends StatefulWidget {
  const MindmapStepTile({
    super.key,
    required this.step,
  });

  final ParsedToolStep step;

  @override
  State<MindmapStepTile> createState() => _MindmapStepTileState();
}

class _MindmapStepTileState extends State<MindmapStepTile> {
  static const double _minScale = 0.4;
  static const double _maxScale = 3.5;

  MindmapGraphBundle? _bundle;
  String? _error;
  final GlobalKey _viewportKey = GlobalKey(debugLabel: 'mindmapViewport');
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _refreshBundle();
  }

  @override
  void didUpdateWidget(covariant MindmapStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.output != oldWidget.step.output) {
      _refreshBundle();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _refreshBundle() {
    final output = widget.step.output;
    if (output == null || output.trim().isEmpty) {
      setState(() {
        _bundle = null;
        _error = L10n.of(context).mindmapWaitingForOutput;
      });
      return;
    }

    try {
      final decoded = jsonDecode(output);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Tool output is not a JSON object');
      }

      final status = decoded['status'];
      if (status != 'ok') {
        final message =
            decoded['message']?.toString() ?? L10n.of(context).mindmapToolError;
        throw FormatException(message);
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Mindmap payload missing data object');
      }

      // If there's only one child under root, the root node is redundant
      // because it duplicates the title. Promote the child as new root.
      if (data['root']['children'].length == 1) {
        data['root'] = data['root']['children'][0];
      }

      final payload = MindmapPayload.fromJson(data, context);
      setState(() {
        _bundle = MindmapGraphBundle.fromPayload(payload);
        _error = null;
        _transformController.value = Matrix4.identity();
      });
    } catch (error) {
      setState(() {
        _bundle = null;
        _error = L10n.of(context).mindmapParseFailed(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = ToolTileBase.statusColorFor(widget.step.status);

    return ToolTileBase(
      title: widget.step.name,
      leadingIcon: Icons.account_tree,
      statusColor: statusColor,
      initiallyExpanded: true,
      contentBuilder: (context) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) {
      return Text(_error!, style: theme.textTheme.bodyMedium);
    }

    final bundle = _bundle;
    if (bundle == null) {
      return Text(L10n.of(context).mindmapGenerating,
          style: theme.textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledContainer(
          width: double.infinity,
          height: 360,
          radius: 12,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
              final height = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 320.0;
              return Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    GestureBinding.instance.pointerSignalResolver.register(
                      event,
                      (resolvedEvent) => _handlePointerScroll(
                        resolvedEvent as PointerScrollEvent,
                      ),
                    );
                  }
                },
                child: InteractiveViewer(
                  key: _viewportKey,
                  transformationController: _transformController,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: GraphView.builder(
                      graph: bundle.graph,
                      algorithm: bundle.algorithm,
                      paint: Paint()
                        ..color = theme.colorScheme.onSurface
                        ..strokeWidth = 2
                        ..style = PaintingStyle.stroke,
                      autoZoomToFit: true,
                      builder: (node) {
                        final id = node.key?.value?.toString() ?? '';
                        final data = bundle.lookup[id];
                        final level = bundle.levels[id] ?? 0;
                        final style = _resolveLevelStyle(theme, level);
                        return _MindmapNodeCard(
                          label: data?.label ?? id,
                          backgroundColor: style.background,
                          foregroundColor: style.foreground,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (bundle.stats != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              L10n.of(context).mindmapStats(
                bundle.stats!.depth,
                bundle.stats!.nodeCount,
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  void _handlePointerScroll(PointerScrollEvent event) {
    if (_bundle == null) {
      return;
    }

    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }

    final focalPoint = renderObject.globalToLocal(event.position);
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    final scaleDelta = (-event.scrollDelta.dy / 400).clamp(-0.5, 0.5);
    if (scaleDelta.abs() < 1e-4) {
      return;
    }

    final desiredScale =
        (currentScale * (1 + scaleDelta)).clamp(_minScale, _maxScale);
    final zoomFactor = desiredScale / currentScale;
    if (zoomFactor == 1) {
      return;
    }

    final nextMatrix = currentMatrix.clone()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(zoomFactor)
      ..translate(-focalPoint.dx, -focalPoint.dy);

    _transformController.value = nextMatrix;
  }
}

class _MindmapNodeCard extends StatelessWidget {
  const _MindmapNodeCard({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: FilledContainer(
        fill: true,
        margin: EdgeInsets.zero,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

class _LevelStyle {
  const _LevelStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

_LevelStyle _resolveLevelStyle(ThemeData theme, int level) {
  final base = HSVColor.fromColor(theme.colorScheme.primary);
  final hue = (base.hue + (level * 32)) % 360;
  final saturation = (0.35 + (level % 5) * 0.08).clamp(0.2, 0.85);
  final value = (0.9 - (level % 6) * 0.06).clamp(0.3, 0.95);
  final background = HSVColor.fromAHSV(1, hue, saturation, value).toColor();
  final foreground =
      background.computeLuminance() > 0.55 ? Colors.black : Colors.white;
  return _LevelStyle(background: background, foreground: foreground);
}

class MindmapGraphBundle {
  MindmapGraphBundle({
    required this.graph,
    required this.algorithm,
    required this.lookup,
    required this.stats,
    required this.levels,
  });

  factory MindmapGraphBundle.fromPayload(MindmapPayload payload) {
    final graph = Graph()..isTree = true;
    final lookup = <String, MindmapNodeData>{};
    final nodeCache = <String, Node>{};
    final levels = <String, int>{};

    Node ensureNode(MindmapNodeData data) {
      lookup[data.id] = data;
      return nodeCache.putIfAbsent(data.id, () => Node.Id(data.id));
    }

    void visit(MindmapNodeData node, int level) {
      final parentNode = ensureNode(node);
      graph.addNode(parentNode);
      levels[node.id] = level;
      for (final child in node.children) {
        final childNode = ensureNode(child);
        graph.addEdge(parentNode, childNode);
        visit(child, level + 1);
      }
    }

    visit(payload.root, 0);

    final config = BuchheimWalkerConfiguration()
      ..siblingSeparation = 10
      ..levelSeparation = 200
      ..subtreeSeparation = 20
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;

    final algorithm = MindmapAlgorithm(
      config,
      MindmapEdgeRenderer(config),
    );

    return MindmapGraphBundle(
      graph: graph,
      algorithm: algorithm,
      lookup: lookup,
      stats: payload.stats,
      levels: levels,
    );
  }

  final Graph graph;
  final Algorithm algorithm;
  final Map<String, MindmapNodeData> lookup;
  final MindmapStats? stats;
  final Map<String, int> levels;
}

class MindmapPayload {
  MindmapPayload({
    required this.title,
    required this.outline,
    required this.root,
    this.stats,
  });

  factory MindmapPayload.fromJson(
      Map<String, dynamic> json, BuildContext context) {
    final rootJson = json['root'];
    if (rootJson is! Map<String, dynamic>) {
      throw const FormatException('Mindmap payload is missing root node');
    }

    return MindmapPayload(
      title: json['title']?.toString() ?? L10n.of(context).mindmapDefaultTitle,
      outline: json['outline']?.toString() ?? '',
      root: MindmapNodeData.fromJson(rootJson, context),
      stats: json['stats'] is Map<String, dynamic>
          ? MindmapStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  final String title;
  final String outline;
  final MindmapNodeData root;
  final MindmapStats? stats;
}

class MindmapNodeData {
  MindmapNodeData({
    required this.id,
    required this.label,
    required this.children,
  });

  factory MindmapNodeData.fromJson(
      Map<String, dynamic> json, BuildContext context) {
    final children = (json['children'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((child) => MindmapNodeData.fromJson(child, context))
        .toList(growable: false);

    return MindmapNodeData(
      id: json['id']?.toString() ?? L10n.of(context).mindmapDefaultNodeId,
      label:
          json['label']?.toString() ?? L10n.of(context).mindmapDefaultNodeLabel,
      children: children,
    );
  }

  final String id;
  final String label;
  final List<MindmapNodeData> children;
}

class MindmapStats {
  MindmapStats({required this.nodeCount, required this.depth});

  factory MindmapStats.fromJson(Map<String, dynamic> json) {
    return MindmapStats(
      nodeCount: int.tryParse(json['nodeCount']?.toString() ?? '') ?? 0,
      depth: int.tryParse(json['depth']?.toString() ?? '') ?? 0,
    );
  }

  final int nodeCount;
  final int depth;
}

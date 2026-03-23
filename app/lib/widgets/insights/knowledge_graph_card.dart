import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

/// AI narrative-driven knowledge graph card.
/// The graph is a visual footnote to AI narrative — not an exploration tool.
class KnowledgeGraphCard extends ConsumerStatefulWidget {
  const KnowledgeGraphCard({super.key});

  @override
  ConsumerState<KnowledgeGraphCard> createState() => _KnowledgeGraphCardState();
}

class _KnowledgeGraphCardState extends ConsumerState<KnowledgeGraphCard> {
  String? _narrative;
  List<ConceptTag> _tags = [];
  List<ConceptEdge> _edges = [];
  Set<String> _highlightedConcepts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dao = ConceptTagDao();
    final tags = await dao.getAll();
    final edges = await dao.getAllEdges();

    if (tags.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // Generate AI narrative about knowledge connections
    String? narrative;
    Set<String> highlighted = {};
    if (AiAvailability.isAvailable(ref)) {
      final tagNames = tags.map((t) => t.name).toSet().toList();
      final edgeDescriptions = <String>[];
      for (final edge in edges) {
        final source = tags.where((t) => t.id == edge.sourceTagId).firstOrNull;
        final target = tags.where((t) => t.id == edge.targetTagId).firstOrNull;
        if (source != null && target != null) {
          edgeDescriptions.add('${source.name} ↔ ${target.name}: ${edge.reason ?? ""}');
        }
      }

      final prompt =
          '''基于以下知识概念和它们的关联，用2-3句话描述阅读者的知识网络特征。
语气像一个聪明的朋友在总结你的阅读收获。突出跨书的有趣连接。

概念: ${tagNames.join(', ')}
${edgeDescriptions.isNotEmpty ? '关联:\n${edgeDescriptions.join('\n')}' : ''}

请用自然的中文叙述:''';

      narrative = await AmbientAiPipeline.execute(
        type: AmbientTaskType.knowledgeNarrative,
        prompt: prompt,
        ref: ref,
        cacheParams: {'tags': tagNames.join(',')},
      );

      // Extract mentioned concept names for highlighting
      if (narrative != null) {
        for (final name in tagNames) {
          if (narrative.contains(name)) {
            highlighted.add(name);
          }
        }
        // If nothing highlighted, highlight connected ones
        if (highlighted.isEmpty && edges.isNotEmpty) {
          for (final edge in edges.take(3)) {
            final source = tags.where((t) => t.id == edge.sourceTagId).firstOrNull;
            final target = tags.where((t) => t.id == edge.targetTagId).firstOrNull;
            if (source != null) highlighted.add(source.name);
            if (target != null) highlighted.add(target.name);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _tags = tags;
        _edges = edges;
        _narrative = narrative;
        _highlightedConcepts = highlighted;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_tags.isEmpty) return const SizedBox.shrink();

    return OmnigramCard(
      backgroundColor: OmnigramColors.cardMint.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub, size: 18, color: OmnigramColors.accentMint),
              const SizedBox(width: 8),
              Text('知识网络', style: OmnigramTypography.titleMedium(context)),
              const Spacer(),
              Text('${_tags.length} 个概念', style: OmnigramTypography.caption(context)),
            ],
          ),
          if (_narrative != null) ...[
            const SizedBox(height: 12),
            Text(
              _narrative!,
              style: OmnigramTypography.bodyMedium(context).copyWith(height: 1.6, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _SimpleGraphView(tags: _tags, edges: _edges, highlightedConcepts: _highlightedConcepts),
          ),
        ],
      ),
    );
  }
}

/// Simple force-directed-like graph visualization.
/// Highlighted nodes (mentioned in AI narrative) are colored; others are dimmed.
class _SimpleGraphView extends StatelessWidget {
  final List<ConceptTag> tags;
  final List<ConceptEdge> edges;
  final Set<String> highlightedConcepts;

  const _SimpleGraphView({required this.tags, required this.edges, required this.highlightedConcepts});

  @override
  Widget build(BuildContext context) {
    // Deduplicate tags by name for display
    final uniqueNames = <String, ConceptTag>{};
    for (final tag in tags) {
      uniqueNames.putIfAbsent(tag.name, () => tag);
    }
    final displayTags = uniqueNames.values.toList();
    if (displayTags.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: _GraphPainter(
        tags: displayTags,
        edges: edges,
        allTags: tags,
        highlighted: highlightedConcepts,
        textDirection: Directionality.of(context),
      ),
      size: Size.infinite,
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<ConceptTag> tags;
  final List<ConceptEdge> edges;
  final List<ConceptTag> allTags;
  final Set<String> highlighted;
  final TextDirection textDirection;

  _GraphPainter({
    required this.tags,
    required this.edges,
    required this.allTags,
    required this.highlighted,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tags.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;
    final positions = <int, Offset>{};

    // Layout nodes in a circle
    for (var i = 0; i < tags.length; i++) {
      final angle = (2 * pi * i / tags.length) - pi / 2;
      positions[tags[i].id ?? i] = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    }

    // Draw edges
    final edgePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final sourceTag = allTags.where((t) => t.id == edge.sourceTagId).firstOrNull;
      final targetTag = allTags.where((t) => t.id == edge.targetTagId).firstOrNull;
      if (sourceTag == null || targetTag == null) continue;

      // Find position by name match since displayed tags are deduplicated
      final sourcePos = _findPosByName(positions, sourceTag.name);
      final targetPos = _findPosByName(positions, targetTag.name);
      if (sourcePos == null || targetPos == null) continue;

      final isHighlighted = highlighted.contains(sourceTag.name) || highlighted.contains(targetTag.name);
      edgePaint.color = isHighlighted
          ? OmnigramColors.accentMint.withValues(alpha: 0.6)
          : Colors.grey.withValues(alpha: 0.2);
      canvas.drawLine(sourcePos, targetPos, edgePaint);
    }

    // Draw nodes
    for (var i = 0; i < tags.length; i++) {
      final tag = tags[i];
      final pos = positions[tag.id ?? i]!;
      final isHighlighted = highlighted.contains(tag.name);
      final nodeRadius = isHighlighted ? 6.0 : 4.0;

      final nodePaint = Paint()..color = isHighlighted ? OmnigramColors.accentMint : Colors.grey.withValues(alpha: 0.4);
      canvas.drawCircle(pos, nodeRadius, nodePaint);

      // Draw label
      if (isHighlighted || tags.length <= 8) {
        final textSpan = TextSpan(
          text: tag.name,
          style: TextStyle(
            color: isHighlighted ? OmnigramColors.accentMint : Colors.grey,
            fontSize: isHighlighted ? 11 : 9,
          ),
        );
        final textPainter = TextPainter(text: textSpan, textDirection: textDirection);
        textPainter.layout();
        textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + nodeRadius + 2));
      }
    }
  }

  Offset? _findPosByName(Map<int, Offset> positions, String name) {
    for (var i = 0; i < tags.length; i++) {
      if (tags[i].name == name) return positions[tags[i].id ?? i];
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

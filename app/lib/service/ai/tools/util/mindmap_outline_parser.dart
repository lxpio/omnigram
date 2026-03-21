class MindmapOutlineParser {
  MindmapOutlineParser();

  MindmapParseResult parse({required String title, required String outline}) {
    final normalizedLines = outline
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);

    if (normalizedLines.isEmpty) {
      throw ArgumentError('Mindmap outline cannot be empty.');
    }

    _nodeIdCounter = 0;
    final sanitizedTitle = title.trim().isEmpty ? 'Mindmap' : title.trim();
    final root = _MindmapNode._(
      id: _nextId(),
      label: sanitizedTitle,
      level: -1,
    );

    final stack = <_Context>[_Context(indent: -1, node: root)];
    var maxDepth = 0;
    var totalNodes = 0;

    for (final rawLine in normalizedLines) {
      final normalized = rawLine.replaceAll('\t', '  ');
      final match = _linePattern.firstMatch(normalized);
      if (match == null) {
        throw FormatException(
          'Invalid bullet item: "$rawLine". Start each line with "-" or "*".',
        );
      }

      final indentString = match.group(1)!;
      final text = match.group(3)!.trim();
      if (text.isEmpty) {
        throw FormatException('Bullet text cannot be empty.');
      }

      final indentWidth = indentString.length;

      while (stack.isNotEmpty && indentWidth <= stack.last.indent) {
        stack.removeLast();
      }

      if (stack.isEmpty) {
        throw FormatException('Indentation error detected in the outline.');
      }

      final parent = stack.last.node;
      final node = _MindmapNode._(
        id: _nextId(),
        label: text,
        level: parent.level + 1,
      );
      parent.children.add(node);
      totalNodes += 1;
      if (node.level > maxDepth) {
        maxDepth = node.level;
      }

      stack.add(_Context(indent: indentWidth, node: node));
    }

    return MindmapParseResult(
      title: sanitizedTitle,
      outline: normalizedLines.join('\n'),
      root: root.toJson(includeChildren: true),
      stats: MindmapParseStats(
        nodeCount: totalNodes,
        depth: maxDepth,
      ),
    );
  }
}

final RegExp _linePattern = RegExp(r'^(\s*)([-*•+]\s+)(.+)$');
int _nodeIdCounter = 0;

String _nextId() => 'mindmapNode${_nodeIdCounter++}';

class MindmapParseResult {
  MindmapParseResult({
    required this.title,
    required this.outline,
    required Map<String, Object?> root,
    required this.stats,
  }) : root = Map<String, Object?>.unmodifiable(root);

  final String title;
  final String outline;
  final Map<String, Object?> root;
  final MindmapParseStats stats;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'outline': outline,
      'root': root,
      'stats': stats.toJson(),
    };
  }
}

class MindmapParseStats {
  MindmapParseStats({required this.nodeCount, required this.depth});

  final int nodeCount;
  final int depth;

  Map<String, Object?> toJson() => {
        'nodeCount': nodeCount,
        'depth': depth,
      };
}

class _MindmapNode {
  _MindmapNode._({
    required this.id,
    required this.label,
    required this.level,
  });

  final String id;
  final String label;
  final int level;
  final List<_MindmapNode> children = [];

  Map<String, Object?> toJson({required bool includeChildren}) {
    return {
      'id': id,
      'label': label,
      'children': includeChildren
          ? children
              .map((child) => child.toJson(includeChildren: true))
              .toList(growable: false)
          : const [],
    };
  }
}

class _Context {
  _Context({required this.indent, required this.node});

  final int indent;
  final _MindmapNode node;
}

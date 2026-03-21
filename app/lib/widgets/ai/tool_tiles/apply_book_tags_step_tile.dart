import 'dart:convert';

import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/tag.dart';
import 'package:omnigram/service/ai/tools/repository/tag_repository.dart';
import 'package:omnigram/utils/ai_reasoning_parser.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/utils/color/hash_color.dart';
import 'package:omnigram/utils/color/rgb.dart';
import 'package:omnigram/widgets/ai/tool_tiles/tool_tile_base.dart';
import 'package:omnigram/widgets/common/container/filled_container.dart';
import 'package:omnigram/widgets/common/tag_chip.dart';
import 'package:flutter/material.dart';

class ApplyBookTagsStepTile extends StatefulWidget {
  const ApplyBookTagsStepTile({super.key, required this.step});

  final ParsedToolStep step;

  @override
  State<ApplyBookTagsStepTile> createState() => _ApplyBookTagsStepTileState();
}

class _ApplyBookTagsStepTileState extends State<ApplyBookTagsStepTile> {
  Map<String, dynamic>? _plan;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _conflicts = [];
  bool _requiresConfirmation = false;
  String? _parseError;
  bool _isApplying = false;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _syncFromStep();
  }

  @override
  void didUpdateWidget(covariant ApplyBookTagsStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.output != oldWidget.step.output) {
      _syncFromStep();
    }
  }

  void _syncFromStep() {
    final output = widget.step.output;
    Map<String, dynamic>? plan;
    List<Map<String, dynamic>> books = [];
    List<Map<String, dynamic>> conflicts = [];
    bool requires = false;
    String? parseError;

    if (output == null || output.trim().isEmpty) {
      parseError = 'Waiting for tool output';
    } else {
      try {
        final decoded = jsonDecode(output);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            requires = data['requiresConfirmation'] == true ||
                data['requires_confirmation'] == true;
            plan = Map<String, dynamic>.from(data['plan'] ?? {});
            books = (plan['books'] as List?)
                    ?.map((e) => Map<String, dynamic>.from(e))
                    .toList() ??
                const [];
            conflicts = (data['conflicts'] as List?)
                    ?.map((e) => Map<String, dynamic>.from(e))
                    .toList() ??
                const [];
            parseError = null;
          } else {
            parseError = 'Unexpected data payload';
          }
        } else {
          parseError = 'Unexpected output format';
        }
      } catch (e) {
        parseError = 'Failed to parse output: $e';
      }
    }

    setState(() {
      _plan = plan;
      _books = books;
      _conflicts = conflicts;
      _requiresConfirmation = requires;
      _parseError = parseError;
      _applied = false;
      _isApplying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = ToolTileBase.statusColorFor(widget.step.status);
    return ToolTileBase(
      title: widget.step.name,
      leadingIcon: Icons.label_important,
      statusColor: statusColor,
      initiallyExpanded: true,
      contentBuilder: (_) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    if (_parseError != null) {
      return Text(_parseError!, style: theme.textTheme.bodyMedium);
    }
    if (_plan == null) {
      return Text('No plan found', style: theme.textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_conflicts.isNotEmpty) _buildConflicts(theme),
        if (_books.isNotEmpty) _buildBooks(theme),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: (_requiresConfirmation && !_isApplying && !_applied)
                  ? _applyPlan
                  : null,
              child: _isApplying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_applied ? 'Applied' : 'Apply'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBooks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _books
          .map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                radius: 10,
                color: theme.colorScheme.surfaceContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['bookTitle']?.toString() ?? '',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (book['finalTags'] as List? ?? [])
                          .map((tag) {
                            final name = tag['name']?.toString() ?? '';
                            final rgb = _parseRgb(tag['rgb']) ??
                                rgbFromColor(hashColor(name));
                            return TagChip(
                              label: name,
                              color: colorFromRgb(rgb),
                              dense: true,
                              selected: true,
                            );
                          })
                          .whereType<TagChip>()
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConflicts(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conflicts', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ..._conflicts.map(
            (c) => Text(
              c.toString(),
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _applyPlan() async {
    if (_plan == null) return;
    setState(() {
      _isApplying = true;
    });

    try {
      final tagRepo = TagRepository();

      // merges
      for (final merge in (_plan!['mergeTags'] as List? ?? [])) {
        final sourceId = (merge['sourceId'] as num?)?.toInt();
        final targetId = (merge['targetId'] as num?)?.toInt();
        if (sourceId == null || targetId == null) continue;
        final source = await tagRepo.fetchTagById(sourceId);
        final target = await tagRepo.fetchTagById(targetId);
        if (source != null && target != null && source.id != target.id) {
          await tagRepo.mergeTags(source: source, target: target);
        }
      }

      // updates
      for (final update in (_plan!['updateTags'] as List? ?? [])) {
        final id = (update['id'] as num?)?.toInt();
        if (id == null || id <= 0) continue;
        await tagRepo.updateTag(
          id: id,
          newName: update['name'] as String?,
          color: _colorFromPlan(update['rgb']),
        );
      }

      // creates
      for (final create in (_plan!['createTags'] as List? ?? [])) {
        final name = (create['name'] ?? '').toString();
        if (name.isEmpty) continue;
        final rgb = _colorFromPlan(create['rgb']);
        await tagRepo.ensureTag(name, color: rgb);
      }

      // book changes
      for (final change in (_plan!['bookChanges'] as List? ?? [])) {
        final bookId = (change['bookId'] as num?)?.toInt();
        if (bookId == null || bookId <= 0) continue;
        final book = await bookDao.selectBookById(bookId);
        final addNames = (change['add'] as List? ?? [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty);
        final removeNames = (change['remove'] as List? ?? [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty);

        for (final name in addNames) {
          final tag = await tagRepo.ensureTag(name);
          await bookTagDao.addRelation(bookId: book.id, tagId: tag.id);
        }
        for (final name in removeNames) {
          final tag = await tagRepo.fetchTagByName(name);
          if (tag != null) {
            await bookTagDao.removeRelation(bookId: book.id, tagId: tag.id);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isApplying = false;
        _applied = true;
      });
      AnxToast.show('Tags updated');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isApplying = false;
      });
      AnxToast.show('Failed to apply tag changes: $e');
    }
  }
}

Color? _colorFromPlan(dynamic value) {
  final rgb = _parseRgb(value);
  if (rgb == null) return null;
  return colorFromRgb(rgb);
}

int? _parseRgb(dynamic value) {
  if (value == null) return null;
  if (value is Color) return rgbFromColor(value);
  if (value is num) return (value.toInt()) & 0x00FFFFFF;
  if (value is String) {
    var v = value.trim();
    if (v.startsWith('0x')) v = v.substring(2);
    if (v.startsWith('#')) v = v.substring(1);
    try {
      return int.parse(v, radix: 16) & 0x00FFFFFF;
    } catch (_) {
      return null;
    }
  }
  return null;
}

import 'dart:convert';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/tb_groups.dart';
import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan.dart';
import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan_group.dart';
import 'package:omnigram/service/bookshelf/bookshelf_organize_service.dart';
import 'package:omnigram/utils/ai_reasoning_parser.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/widgets/ai/tool_tiles/tool_tile_base.dart';
import 'package:omnigram/widgets/common/container/filled_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

typedef _GroupNameLookup = Map<int, String>;

class OrganizeBookshelfStepTile extends ConsumerStatefulWidget {
  const OrganizeBookshelfStepTile({
    super.key,
    required this.step,
  });

  final ParsedToolStep step;

  @override
  ConsumerState<OrganizeBookshelfStepTile> createState() =>
      _OrganizeBookshelfStepTileState();
}

class _OrganizeBookshelfStepTileState
    extends ConsumerState<OrganizeBookshelfStepTile> {
  bool _isApplying = false;
  bool _applied = false;
  bool _requiresConfirmation = false;
  BookshelfOrganizePlan? _plan;
  String? _parseError;
  bool _didInitialSync = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialSync) {
      _didInitialSync = true;
      _syncFromStep(initial: true, useSetState: true);
    }
  }

  @override
  void didUpdateWidget(covariant OrganizeBookshelfStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.output != oldWidget.step.output) {
      _syncFromStep(initial: false, useSetState: true);
    }
  }

  void _syncFromStep({required bool initial, bool useSetState = false}) {
    final output = widget.step.output;
    BookshelfOrganizePlan? plan;
    String? parseError;
    var requiresConfirmation = false;

    if (output == null || output.trim().isEmpty) {
      parseError = L10n.of(context).waitingForToolOutput;
    } else {
      try {
        final decoded = jsonDecode(output);
        if (decoded is! Map<String, dynamic>) {
          parseError = L10n.of(context).unexpectedToolOutputFormat;
        } else {
          final data = decoded['data'];
          if (data is! Map<String, dynamic>) {
            parseError = L10n.of(context).missingPlanPayload;
          } else {
            requiresConfirmation = data['requiresConfirmation'] == true ||
                data['requires_confirmation'] == true;
            final planJson = data['plan'];
            if (planJson is! Map) {
              parseError = L10n.of(context).planDetailsMissing;
            } else {
              plan = BookshelfOrganizePlan.fromJson(
                Map<String, dynamic>.from(planJson),
              );
              parseError = null;
            }
          }
        }
      } catch (error) {
        parseError = L10n.of(context).failedToParsePlan(error);
      }
    }

    void assign() {
      _plan = plan;
      _parseError = parseError;
      _requiresConfirmation = requiresConfirmation;
      if (!initial) {
        _applied = false;
        _isApplying = false;
      }
    }

    if (useSetState) {
      setState(assign);
    } else {
      assign();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = ToolTileBase.statusColorFor(widget.step.status);

    return ToolTileBase(
      title: widget.step.name,
      leadingIcon: Icons.auto_awesome_mosaic,
      statusColor: statusColor,
      initiallyExpanded: true,
      contentBuilder: (_) => _buildExpandedContent(theme),
    );
  }

  Widget _buildExpandedContent(ThemeData theme) {
    if (_parseError != null) {
      return Text(_parseError!, style: theme.textTheme.bodyMedium);
    }

    if (_plan == null) {
      return Text(L10n.of(context).noReorganizationPlanGenerated,
          style: theme.textTheme.bodyMedium);
    }

    final groupLookup = _resolveGroupNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_plan!.summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(_plan!.summary!, style: theme.textTheme.bodyMedium),
          ),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ..._plan!.groups.map(
                    (group) => _buildGroupBlock(group, groupLookup, theme)),
              ],
            ),
          ),
        ),
        if (_plan!.groups.isNotEmpty) const SizedBox(height: 8),
        if (_plan!.ungroupedBooks.isNotEmpty) _buildUngroupedBlock(theme),
        if (_plan!.cleanupGroupIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildCleanupSection(groupLookup, theme),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: widget.step.output == null
                  ? null
                  : () {
                      Clipboard.setData(
                          ClipboardData(text: widget.step.output!));
                      AnxToast.show(L10n.of(context).planCopied);
                    },
              icon: const Icon(Icons.copy, size: 14),
              label: Text(L10n.of(context).copyJson),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _canApplyPlan ? _applyPlan : null,
              child: _isApplying
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      _applied
                          ? L10n.of(context).completed
                          : L10n.of(context).applyToBookshelf,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  bool get _canApplyPlan =>
      !_isApplying && !_applied && _plan != null && _requiresConfirmation;

  Widget _buildGroupBlock(
    BookshelfOrganizePlanGroup group,
    _GroupNameLookup groupLookup,
    ThemeData theme,
  ) {
    final title = group.proposedName ?? group.currentName;
    final chips = <Widget>[];
    if (group.createNew) {
      chips.add(_buildChip(theme, L10n.of(context).newGroup));
    }
    if (group.willRename) {
      final current = group.currentName ??
          groupLookup[group.groupId] ??
          L10n.of(context).unnamed;
      chips.add(_buildChip(theme, L10n.of(context).renameFrom(current)));
    }

    return FilledContainer(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      radius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? L10n.of(context).groupWithId(group.groupId),
            style: theme.textTheme.titleSmall,
          ),
          if (chips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: chips,
              ),
            ),
          if (group.books.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: group.books
                    .map(
                      (book) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '• ${book.title}${book.author != null ? ' — ${book.author}' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (group.books.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                L10n.of(context).noBooksAssignedInThisPlan,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUngroupedBlock(ThemeData theme) {
    return FilledContainer(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(8),
      radius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.of(context).booksToUngroup,
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ..._plan!.ungroupedBooks.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '• ${book.title}${book.author != null ? ' — ${book.author}' : ''}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanupSection(
    _GroupNameLookup lookup,
    ThemeData theme,
  ) {
    return FilledContainer(
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(8),
      radius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.of(context).groupsToRemove,
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ..._plan!.cleanupGroupIds.map((id) {
            final name = lookup[id];
            return Text(
              name != null
                  ? '• $name (ID $id)'
                  : '• ${L10n.of(context).groupId(id)}',
              style: theme.textTheme.bodySmall,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Future<void> _applyPlan() async {
    if (_plan == null) {
      return;
    }
    setState(() {
      _isApplying = true;
    });

    try {
      await ref.read(bookshelfOrganizeServiceProvider).applyPlan(_plan!);
      if (!mounted) return;
      setState(() {
        _isApplying = false;
        _applied = true;
      });
      AnxToast.show(L10n.of(context).bookshelfUpdated);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isApplying = false;
      });
      AnxToast.show(L10n.of(context).failedToApplyPlan(error));
    }
  }

  _GroupNameLookup _resolveGroupNames() {
    final groups = ref.watch(groupDaoProvider);
    return groups.maybeWhen(
      data: (items) => {
        for (final group in items) group.id: group.name,
      },
      orElse: () => const {},
    );
  }
}

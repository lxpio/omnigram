import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/models/sync_state_model.dart';
import 'package:omnigram/providers/sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showSyncStatusBottomSheet(BuildContext context) async {
  showModalBottomSheet(
    useSafeArea: true,
    context: navigatorKey.currentContext!,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const SyncStatusBottomSheet(),
  );
}

class SyncStatusBottomSheet extends ConsumerWidget {
  const SyncStatusBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSyncingIndicator(syncState, theme, l10n),
            const SizedBox(height: 10),
            _buildActionButtons(context, ref, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncingIndicator(
    SyncStateModel syncState,
    ThemeData theme,
    L10n l10n,
  ) {
    if (!syncState.isSyncing) {
      return Text(
        l10n.bookSyncStatusNotSyncing,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(syncState.fileName, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: syncState.total > 0 ? syncState.count / syncState.total : 0,
        ),
        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.restore),
                label: Text(L10n.of(context).restoreBackup),
                onPressed: () {
                  ref.read(syncProvider.notifier).showBackupManagementDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

import '../../service/sync/sync_manager.dart';

/// Compact sync status indicator for app bar or settings.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key, this.showLabel = true});

  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncManagerProvider);

    return GestureDetector(
      onTap: () {
        if (syncState.status != SyncStatus.syncing) {
          ref.read(syncManagerProvider.notifier).sync();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(context, syncState.status),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              _statusText(context, syncState),
              style: TextStyle(fontSize: 12, color: _statusColor(context, syncState.status)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
        );
      case SyncStatus.success:
        return Icon(Icons.cloud_done, size: 18, color: Theme.of(context).colorScheme.primary);
      case SyncStatus.error:
        return Icon(Icons.cloud_off, size: 18, color: Theme.of(context).colorScheme.error);
      case SyncStatus.offline:
        return Icon(Icons.cloud_off, size: 18, color: Theme.of(context).colorScheme.outline);
      case SyncStatus.idle:
        return Icon(Icons.cloud_queue, size: 18, color: Theme.of(context).colorScheme.outline);
    }
  }

  String _statusText(BuildContext context, SyncState syncState) {
    if (syncState.message != null) return syncState.message!;
    switch (syncState.status) {
      case SyncStatus.idle:
        return syncState.lastSyncTime != null
            ? L10n.of(context).syncLastSync(_formatTime(context, syncState.lastSyncTime!))
            : L10n.of(context).syncNotSynced;
      case SyncStatus.syncing:
        return L10n.of(context).syncSyncing;
      case SyncStatus.success:
        return L10n.of(context).syncSynced;
      case SyncStatus.error:
        return L10n.of(context).syncFailed;
      case SyncStatus.offline:
        return L10n.of(context).syncOffline;
    }
  }

  Color _statusColor(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.error:
        return Theme.of(context).colorScheme.error;
      case SyncStatus.success:
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return L10n.of(context).syncTimeJustNow;
    if (diff.inHours < 1) return L10n.of(context).syncTimeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return L10n.of(context).syncTimeHoursAgo(diff.inHours);
    return L10n.of(context).syncTimeDaysAgo(diff.inDays);
  }
}

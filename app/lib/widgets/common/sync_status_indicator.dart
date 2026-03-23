import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              _statusText(syncState),
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

  String _statusText(SyncState syncState) {
    if (syncState.message != null) return syncState.message!;
    switch (syncState.status) {
      case SyncStatus.idle:
        return syncState.lastSyncTime != null ? '上次同步: ${_formatTime(syncState.lastSyncTime!)}' : '未同步';
      case SyncStatus.syncing:
        return '同步中...';
      case SyncStatus.success:
        return '已同步';
      case SyncStatus.error:
        return '同步失败';
      case SyncStatus.offline:
        return '离线';
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

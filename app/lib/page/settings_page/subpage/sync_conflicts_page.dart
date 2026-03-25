import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/sync/sync_manager.dart';

/// Manual conflict resolution page (U-3).
///
/// Shows conflicts detected during last sync and lets users
/// choose which version to keep (local or server).
class SyncConflictsPage extends ConsumerWidget {
  const SyncConflictsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncManagerProvider);
    final conflicts = syncState.conflicts;

    return Scaffold(
      appBar: AppBar(title: const Text('同步冲突')),
      body: conflicts.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('没有冲突', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('所有数据已同步一致', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conflicts.length,
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                return _ConflictCard(conflict: conflict);
              },
            ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({required this.conflict});
  final SyncConflict conflict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text('书籍 #${conflict.bookId}', style: theme.textTheme.titleSmall),
                const Spacer(),
                Chip(
                  label: Text(conflict.field, style: const TextStyle(fontSize: 12)),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 16),
            _VersionRow(label: '本地版本', value: conflict.localValue, icon: Icons.phone_android),
            const SizedBox(height: 8),
            _VersionRow(label: '服务端版本', value: conflict.serverValue, icon: Icons.cloud),
            const SizedBox(height: 12),
            Text('已自动使用服务端版本（Last-Write-Wins）', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

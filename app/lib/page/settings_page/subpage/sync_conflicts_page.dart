import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/sync/sync_manager.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';

/// Manual conflict resolution page (U-3).
///
/// Liquid Glass polish per Phase 5 of
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md.
class SyncConflictsPage extends ConsumerWidget {
  const SyncConflictsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncManagerProvider);
    final conflicts = syncState.conflicts;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('同步冲突')),
      body: conflicts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 56, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text('没有冲突',
                      style: OmnigramTypography.titleMedium(context)),
                  const SizedBox(height: 8),
                  Text('所有数据已同步一致',
                      style: OmnigramTypography.caption(context)
                          .copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: conflicts.length,
              itemBuilder: (context, i) =>
                  _ConflictCard(conflict: conflicts[i]),
            ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict});
  final SyncConflict conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final q = ref.watch(glassQualityControllerProvider).valueOrNull ??
        GlassQuality.medium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassSurface(
        quality: q,
        borderRadius: GlassTokens.radiusBar,
        blurSigma: GlassTokens.blurSigmaThin,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: scheme.error, size: 20),
                const SizedBox(width: 8),
                Text('书籍 #${conflict.bookId}',
                    style: OmnigramTypography.titleMedium(context)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(conflict.field,
                      style: OmnigramTypography.caption(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _VersionRow(
              label: '本地版本',
              value: conflict.localValue,
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 6),
            _VersionRow(
              label: '服务端版本',
              value: conflict.serverValue,
              icon: Icons.cloud_outlined,
            ),
            const SizedBox(height: 10),
            Text(
              '已自动使用服务端版本（Last-Write-Wins）',
              style: OmnigramTypography.caption(context)
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label: ',
            style: OmnigramTypography.caption(context)
                .copyWith(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value,
              style: OmnigramTypography.caption(context),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

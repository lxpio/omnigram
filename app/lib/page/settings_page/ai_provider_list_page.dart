import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/ai_provider.dart';
import 'package:omnigram/page/settings_page/ai_provider_detail_page.dart';
import 'package:omnigram/providers/ai_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class AiProviderListPage extends ConsumerWidget {
  const AiProviderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final providers = ref.watch(aiProvidersProvider);
    final selectedId =
        ref.watch(aiProvidersProvider.notifier).getSelectedProvider()?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAiProviders),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addProvider(context, ref),
            tooltip: l10n.settingsAiProvidersAdd,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          final isSelected = provider.id == selectedId;
          final hasValidKey = provider.hasValidKey;

          return ListTile(
            leading: _buildProviderLogo(provider),
            title: Text(provider.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.url,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!hasValidKey)
                  Text(
                    l10n.settingsAiProviderNoValidKeys,
                    style: TextTheme.of(context).bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Chip(
                    label: Text(l10n.settingsAiProviderDefault),
                    labelStyle: TextTheme.of(context).labelSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  )
                else
                  TextButton(
                    onPressed: () {
                      ref
                          .read(aiProvidersProvider.notifier)
                          .setSelectedProvider(provider.id);
                    },
                    child: Text(l10n.settingsAiProviderSetDefault),
                  ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.enabled,
                  onChanged: (value) {
                    ref
                        .read(aiProvidersProvider.notifier)
                        .toggleProvider(provider.id, value);
                  },
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AiProviderDetailPage(providerId: provider.id),
                ),
              );
            },
            onLongPress: provider.isBuiltin
                ? null
                : () => _deleteProvider(context, ref, provider),
          );
        },
      ),
    );
  }

  Widget _buildProviderLogo(AiProvider provider) {
    if (provider.logoAsset != null) {
      return Image.asset(
        provider.logoAsset!,
        width: 32,
        height: 32,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackAvatar(provider),
      );
    }
    return _buildFallbackAvatar(provider);
  }

  Widget _buildFallbackAvatar(AiProvider provider) {
    return CircleAvatar(
      child: Text(
        provider.title.isNotEmpty ? provider.title[0].toUpperCase() : '?',
      ),
    );
  }

  Future<void> _addProvider(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AiProviderDetailPage(providerId: null),
      ),
    );
  }

  Future<void> _deleteProvider(
    BuildContext context,
    WidgetRef ref,
    AiProvider provider,
  ) async {
    final l10n = L10n.of(context);
    bool confirmed = false;

    await SmartDialog.show(
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.commonConfirm),
        content: Text(l10n.settingsAiProviderDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              SmartDialog.dismiss();
            },
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              SmartDialog.dismiss();
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (confirmed && context.mounted) {
      ref.read(aiProvidersProvider.notifier).deleteProvider(provider.id);
    }
  }
}

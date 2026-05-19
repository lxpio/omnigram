import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/ai_provider.dart';
import 'package:omnigram/page/settings_page/ai_provider_detail_page.dart';
import 'package:omnigram/providers/ai_providers.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart'
    show AbstractSettingsTile, SettingsTile;

/// AI provider list — Liquid Glass layout per Phase 4 of
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md.
///
/// Each provider is one SettingsTile row with leading logo, title,
/// inline URL as subtitle, enable switch on the right. Tap to edit,
/// long-press to delete (built-ins not deletable). Default provider
/// gets a check mark; tap any inactive provider trailing icon to
/// promote it as default.
class AiProviderListPage extends ConsumerWidget {
  const AiProviderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final providers = ref.watch(aiProvidersProvider);
    final selectedId =
        ref.watch(aiProvidersProvider.notifier).getSelectedProvider()?.id;

    return Scaffold(
      appBar: AppGlassAppBar(
        title: Text(l10n.settingsAiProviders),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addProvider(context),
            tooltip: l10n.settingsAiProvidersAdd,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            SettingsSection(
              title: Text(l10n.settingsAiProviders),
              tiles: [
                for (final p in providers)
                  _ProviderTile(
                    provider: p,
                    isDefault: p.id == selectedId,
                    onSetDefault: () => ref
                        .read(aiProvidersProvider.notifier)
                        .setSelectedProvider(p.id),
                    onToggle: (v) => ref
                        .read(aiProvidersProvider.notifier)
                        .toggleProvider(p.id, v),
                    onDelete: p.isBuiltin
                        ? null
                        : () => _deleteProvider(context, ref, p),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProvider(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiProviderDetailPage(providerId: null),
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
      builder: (_) => AlertDialog(
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

class _ProviderTile extends AbstractSettingsTile {
  const _ProviderTile({
    required this.provider,
    required this.isDefault,
    required this.onSetDefault,
    required this.onToggle,
    required this.onDelete,
  });

  final AiProvider provider;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final hasValidKey = provider.hasValidKey;
    final scheme = Theme.of(context).colorScheme;

    return SettingsTile.navigation(
      leading: _logo(),
      title: Text(provider.title),
      description: Text(
        hasValidKey ? provider.url : l10n.settingsAiProviderNoValidKeys,
        style: TextStyle(
          color: hasValidKey ? scheme.onSurfaceVariant : scheme.error,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDefault)
            Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20)
          else
            IconButton(
              icon: Icon(Icons.circle_outlined,
                  color: scheme.outlineVariant, size: 20),
              tooltip: l10n.settingsAiProviderSetDefault,
              onPressed: onSetDefault,
            ),
          const SizedBox(width: 4),
          Switch(value: provider.enabled, onChanged: onToggle),
        ],
      ),
      onPressed: (_) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiProviderDetailPage(providerId: provider.id),
        ),
      ),
      onLongPress: onDelete,
    );
  }

  Widget _logo() {
    if (provider.logoAsset != null) {
      return Image.asset(
        provider.logoAsset!,
        width: 22,
        height: 22,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Text(
      provider.title.isNotEmpty ? provider.title[0].toUpperCase() : '?',
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

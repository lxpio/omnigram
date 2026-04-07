import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';
import 'package:omnigram/page/settings_page/companion_settings_page.dart';
import 'package:omnigram/page/settings_page/reading.dart';
import 'package:omnigram/page/settings_page/server_connection_page.dart';
import 'package:omnigram/page/settings_page/sync.dart';
import 'package:omnigram/page/settings_page/more_settings_page.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/export/data_export.dart';
import 'package:omnigram/service/import/kindle_import.dart';
import 'package:omnigram/service/stealth/biometric_auth_service.dart';
import 'package:omnigram/page/stealth/stealth_home.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          const SizedBox(height: 16),
          Text(L10n.of(context).settingsTitle, style: OmnigramTypography.displayLarge(context)),
          const SizedBox(height: 24),
          _ServerConnectionSection(),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.person_outline,
            title: L10n.of(context).settingsReadingIdentity,
            subtitle: L10n.of(context).settingsReadingIdentityDesc,
            onTap: () {
              // TODO Sprint 2
            },
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.smart_toy_outlined,
            title: L10n.of(context).settingsCompanion,
            subtitle: L10n.of(context).settingsCompanionDesc,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompanionSettingsPage(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.text_format,
            title: L10n.of(context).settingsReadingExperience,
            subtitle: L10n.of(context).settingsReadingExperienceDesc,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReadingSettings(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.sync,
            title: L10n.of(context).settingsSyncStorage,
            subtitle: L10n.of(context).settingsSyncStorageDesc,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SyncSetting(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.download_outlined,
            title: L10n.of(context).exportData,
            subtitle: L10n.of(context).exportAllNotesDesc,
            onTap: () => _showExportSheet(context),
          ),
          const SizedBox(height: 12),
          const _AiBudgetSection(),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.build_outlined,
            title: L10n.of(context).settingsAdvanced,
            subtitle: L10n.of(context).settingsAdvancedDesc,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubMoreSettings(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.info_outline,
            title: L10n.of(context).settingsAbout,
            subtitle: L10n.of(context).settingsAboutDesc,
            onTap: () {
              // TODO: about page
            },
            onLongPress: () => _enterStealth(context),
          ),
        ],
      ),
    );
  }
}

void _showExportSheet(BuildContext context) {
  final l10n = L10n.of(context);
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.exportAllNotes),
            subtitle: Text(l10n.exportAllNotesDesc),
            onTap: () async {
              Navigator.pop(ctx);
              final path = await DataExport.exportAllNotes();
              if (context.mounted) {
                if (path != null) {
                  AnxToast.show(l10n.exportSuccess(path));
                } else {
                  AnxToast.show(l10n.exportNoNotes);
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.hub_outlined),
            title: Text(l10n.exportKnowledge),
            subtitle: Text(l10n.exportKnowledgeDesc),
            onTap: () async {
              Navigator.pop(ctx);
              final path = await DataExport.exportKnowledge();
              if (context.mounted) {
                if (path != null) {
                  AnxToast.show(l10n.exportSuccess(path));
                } else {
                  AnxToast.show(l10n.exportNoKnowledge);
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: Text(l10n.importKindleHighlights),
            subtitle: Text(l10n.importKindleDesc),
            onTap: () async {
              Navigator.pop(ctx);
              await _importKindle(context);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _enterStealth(BuildContext context) async {
  final l10n = L10n.of(context);

  final available = await BiometricAuthService.isAvailable();
  if (!available) return;

  final authenticated = await BiometricAuthService.authenticate(
    l10n.stealthAuthRequired,
  );
  if (!authenticated) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.stealthAuthFailed)),
      );
    }
    return;
  }

  final key = await BiometricAuthService.getOrCreateKey();
  if (key == null) return;

  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StealthHome(encryptionKey: key)),
    );
  }
}

Future<void> _importKindle(BuildContext context) async {
  final l10n = L10n.of(context);
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt'],
  );
  if (result == null || result.files.isEmpty) return;

  final file = File(result.files.first.path!);
  final content = await file.readAsString();

  final clippings = KindleImport.parseClippings(content);
  if (clippings.isEmpty) {
    if (context.mounted) AnxToast.show(l10n.importKindleEmpty);
    return;
  }

  final books = await BookDao().selectNotDeleteBooks();
  final importResult = await KindleImport.importToLibrary(clippings, books);

  if (context.mounted) {
    if (importResult.importedCount > 0) {
      AnxToast.show(l10n.importKindleSuccess(
          importResult.importedCount, importResult.matchedBooks));
    }
    if (importResult.skippedCount > 0) {
      AnxToast.show(l10n.importKindleNoMatch(importResult.skippedCount));
    }
  }
}

class _ServerConnectionSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(serverConnectionProvider);
    final isConnected = connectionState.isConnected;

    return OmnigramCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServerConnectionPage()),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.cloud_done : Icons.cloud_off_outlined,
            size: 28,
            color: isConnected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.of(context).settingsServerTitle,
                    style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 2),
                Text(
                  isConnected
                      ? L10n.of(context).settingsServerConnected(connectionState.user?.name ?? "")
                      : L10n.of(context).settingsServerNotConnected,
                  style: OmnigramTypography.caption(context),
                ),
              ],
            ),
          ),
          if (isConnected)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

class _AiBudgetSection extends ConsumerStatefulWidget {
  const _AiBudgetSection();

  @override
  ConsumerState<_AiBudgetSection> createState() => _AiBudgetSectionState();
}

class _AiBudgetSectionState extends ConsumerState<_AiBudgetSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return OmnigramCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Text(l10n.aiBudgetTitle, style: OmnigramTypography.titleMedium(context)),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.aiBudgetBackgroundAi),
            subtitle: Text(l10n.aiBudgetBackgroundAiDesc, style: OmnigramTypography.caption(context)),
            value: Prefs().backgroundAiEnabled,
            onChanged: (v) => setState(() => Prefs().backgroundAiEnabled = v),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: Text(l10n.aiBudgetConcurrency),
            subtitle: Text(l10n.aiBudgetConcurrencyDesc, style: OmnigramTypography.caption(context)),
            trailing: DropdownButton<int>(
              value: Prefs().maxConcurrentAiTasks,
              items: [1, 2, 3, 5].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => Prefs().maxConcurrentAiTasks = v);
              },
              underline: const SizedBox(),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: OmnigramTypography.caption(context)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

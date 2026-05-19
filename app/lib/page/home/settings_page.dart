import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/settings_page/companion_settings_page.dart';
import 'package:omnigram/page/settings_page/more_settings_page.dart';
import 'package:omnigram/page/settings_page/reading.dart';
import 'package:omnigram/page/settings_page/server_connection_page.dart';
import 'package:omnigram/page/settings_page/sync.dart';
import 'package:omnigram/page/stealth/stealth_home.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/export/data_export.dart';
import 'package:omnigram/service/import/kindle_import.dart';
import 'package:omnigram/service/stealth/biometric_auth_service.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/widgets/settings/choice_picker_page.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

/// Tab landing for "设置" — Liquid Glass layout, 3 grouped glass cards:
/// 账户与连接 / 阅读 / 应用. Follows
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: OmnigramTheme.pageHorizontalPadding,
        ),
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(l10n.settingsTitle,
                style: OmnigramTypography.displayLarge(context)),
          ),
          _AccountSection(),
          const SizedBox(height: 12),
          _ReadingSection(),
          const SizedBox(height: 12),
          const _AppSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------
// Section: 账户与连接
// --------------------------------------------------------------------

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final conn = ref.watch(serverConnectionProvider);
    final connected = conn.isConnected;

    return SettingsSection(
      title: Text(l10n.settingsServerTitle),
      tiles: [
        SettingsTile.navigation(
          leading: Icon(connected ? Icons.cloud_done : Icons.cloud_off_outlined),
          title: Text(l10n.settingsServerTitle),
          value: Text(
            connected
                ? l10n.settingsServerConnected(conn.user?.name ?? '')
                : l10n.settingsServerNotConnected,
          ),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServerConnectionPage()),
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.sync),
          title: Text(l10n.settingsSyncStorage),
          value: Text(l10n.settingsSyncStorageDesc),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SyncSetting()),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------
// Section: 阅读
// --------------------------------------------------------------------

class _ReadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SettingsSection(
      title: Text(l10n.readingPageReading),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.settingsReadingIdentity),
          value: Text(l10n.settingsReadingIdentityDesc),
          onPressed: (_) {
            // TODO Sprint 2
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.smart_toy_outlined),
          title: Text(l10n.settingsCompanion),
          value: Text(l10n.settingsCompanionDesc),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CompanionSettingsPage()),
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.text_format),
          title: Text(l10n.settingsReadingExperience),
          value: Text(l10n.settingsReadingExperienceDesc),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReadingSettings()),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------
// Section: 应用
// --------------------------------------------------------------------

class _AppSection extends ConsumerStatefulWidget {
  const _AppSection();

  @override
  ConsumerState<_AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends ConsumerState<_AppSection> {
  static const _concurrencyOptions = [1, 2, 3, 5];

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SettingsSection(
      title: Text(l10n.settingsAbout),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.exportData),
          value: Text(l10n.exportAllNotesDesc),
          onPressed: (_) => _showExportSheet(context),
        ),
        SettingsTile.switchTile(
          leading: const Icon(Icons.memory),
          title: Text(l10n.aiBudgetBackgroundAi),
          description: Text(l10n.aiBudgetBackgroundAiDesc),
          initialValue: Prefs().backgroundAiEnabled,
          onToggle: (v) => setState(() => Prefs().backgroundAiEnabled = v),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.bolt_outlined),
          title: Text(l10n.aiBudgetConcurrency),
          value: Text('${Prefs().maxConcurrentAiTasks}'),
          onPressed: (_) async {
            final picked = await pushChoicePicker<int>(
              context,
              title: l10n.aiBudgetConcurrency,
              current: Prefs().maxConcurrentAiTasks,
              options: _concurrencyOptions
                  .map((n) => ChoiceOption(value: n, label: '$n'))
                  .toList(),
            );
            if (picked != null) {
              setState(() => Prefs().maxConcurrentAiTasks = picked);
            }
          },
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.build_outlined),
          title: Text(l10n.settingsAdvanced),
          value: Text(l10n.settingsAdvancedDesc),
          onPressed: (_) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubMoreSettings()),
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.settingsAbout),
          value: Text(l10n.settingsAboutDesc),
          onPressed: (_) {
            // TODO: about page
          },
          onLongPress: () => _enterStealth(context),
        ),
      ],
    );
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
    final importResult =
        await KindleImport.importToLibrary(clippings, books);

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
}

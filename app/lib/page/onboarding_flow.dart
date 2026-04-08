import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/omnigram_home.dart';
import 'package:omnigram/page/settings_page/appearance.dart';
import 'package:omnigram/page/settings_page/server_connection_page.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/book.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingFlow({super.key, this.onComplete});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Track selected language tag; null = system default
  String? _selectedLanguageTag;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Pre-select current locale if set
    final locale = Prefs().locale;
    if (locale != null) {
      final tag = locale.languageCode +
          (locale.countryCode != null ? '-${locale.countryCode}' : '');
      _selectedLanguageTag = tag;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = index);
  }

  Future<void> _complete() async {
    Prefs().lastAppVersion = '1.0.0';
    if (!mounted) return;
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OmnigramHome()),
      );
    }
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowBookExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    final files = result.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();

    if (!mounted) return;
    importBookList(files, context, ref);

    await _complete();
  }

  Future<void> _connectServer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServerConnectionPage()),
    );
    if (!mounted) return;

    final isConnected = ref.read(serverConnectionProvider).isConnected;
    if (isConnected) {
      await _complete();
    }
    // If not connected, user can still choose another option or skip
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Dot indicator
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _DotIndicator(count: 2, current: _currentPage),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _LanguagePage(
                    selectedTag: _selectedLanguageTag,
                    onTagChanged: (tag) {
                      setState(() => _selectedLanguageTag = tag);
                      if (tag == 'System' || tag == null) {
                        Prefs().saveLocaleToPrefs('system');
                      } else {
                        Prefs().saveLocaleToPrefs(tag);
                      }
                    },
                    onNext: () => _goToPage(1),
                  ),
                  _ImportPage(
                    onImport: _importBooks,
                    onConnect: _connectServer,
                    onSkip: _complete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dot page indicator
// ---------------------------------------------------------------------------

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final muted = primary.withValues(alpha: 0.25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? primary : muted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1: Language selection
// ---------------------------------------------------------------------------

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.selectedTag,
    required this.onTagChanged,
    required this.onNext,
  });

  final String? selectedTag;
  final ValueChanged<String?> onTagChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    // Build dropdown items from languageOptions
    final items = languageOptions.map((entry) {
      final displayName = entry.keys.first;
      final tag = entry.values.first;
      return DropdownMenuItem<String>(
        value: tag,
        child: Text(displayName),
      );
    }).toList();

    // Determine current value; default to 'System' (matches languageOptions[0])
    final currentValue = selectedTag ?? 'System';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 44,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 28),

          // Welcome text
          Text(
            l10n.onboardingWelcome,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingChooseLanguage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Language dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: currentValue,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: items,
              onChanged: onTagChanged,
            ),
          ),
          const SizedBox(height: 48),

          // Next button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.onboardingNext,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2: Import or connect
// ---------------------------------------------------------------------------

class _ImportPage extends StatelessWidget {
  const _ImportPage({
    required this.onImport,
    required this.onConnect,
    required this.onSkip,
  });

  final VoidCallback onImport;
  final VoidCallback onConnect;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.library_books_rounded,
              size: 44,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            l10n.onboardingStartJourney,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Import local books — filled button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.onboardingImportBooks),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Connect to server — outlined button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: Text(l10n.onboardingConnectServer),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Skip — text button
          TextButton(
            onPressed: onSkip,
            child: Text(
              l10n.onboardingSkip,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

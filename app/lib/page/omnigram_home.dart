import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/home/desk_page.dart';
import 'package:omnigram/page/home/library_page.dart';
import 'package:omnigram/page/home/insights_page.dart';
import 'package:omnigram/page/home/settings_page.dart' as omnigram;
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/page/onboarding_flow.dart';

enum OmnigramTab { reading, bookshelf, insights, settings }

class OmnigramHome extends ConsumerStatefulWidget {
  const OmnigramHome({super.key});

  @override
  ConsumerState<OmnigramHome> createState() => _OmnigramHomeState();
}

class _OmnigramHomeState extends ConsumerState<OmnigramHome> {
  OmnigramTab _currentTab = OmnigramTab.reading;
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = Prefs().lastAppVersion == null;
  }

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  // Pages built lazily on first visit, then kept alive across tab switches.
  final List<Widget?> _pageCache = List.filled(OmnigramTab.values.length, null);

  Widget _pageAt(int index) {
    var page = _pageCache[index];
    if (page == null) {
      switch (OmnigramTab.values[index]) {
        case OmnigramTab.reading:
          page = const DeskPage();
          break;
        case OmnigramTab.bookshelf:
          page = const LibraryPage();
          break;
        case OmnigramTab.insights:
          page = const InsightsPage();
          break;
        case OmnigramTab.settings:
          page = const omnigram.SettingsPage();
          break;
      }
      _pageCache[index] = page;
    }
    return page;
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentTab.index,
      children: [
        for (int i = 0; i < OmnigramTab.values.length; i++)
          // Offstage avoids laying out / painting un-visited tabs until they are activated.
          _pageCache[i] == null && i != _currentTab.index
              ? const SizedBox.shrink()
              : _pageAt(i),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingFlow(onComplete: _onOnboardingComplete);
    }

    final l10n = L10n.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 600;

    final destinations = [
      _NavItem(icon: Icons.auto_stories_outlined, selectedIcon: Icons.auto_stories, label: l10n.reading),
      _NavItem(icon: Icons.library_books_outlined, selectedIcon: Icons.library_books, label: l10n.bookshelf),
      _NavItem(icon: Icons.insights_outlined, selectedIcon: Icons.insights, label: l10n.insights),
      _NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: l10n.settings),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentTab.index,
              onDestinationSelected: (i) => setState(() => _currentTab = OmnigramTab.values[i]),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      );
    }

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (i) => setState(() => _currentTab = OmnigramTab.values[i]),
        destinations: destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label});
}

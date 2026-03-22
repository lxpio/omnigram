import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/home/desk_page.dart';
import 'package:omnigram/page/home/library_page.dart';
import 'package:omnigram/page/home/insights_page.dart';
import 'package:omnigram/page/home/settings_page.dart' as omnigram;

enum OmnigramTab { reading, bookshelf, insights, settings }

class OmnigramHome extends ConsumerStatefulWidget {
  const OmnigramHome({super.key});

  @override
  ConsumerState<OmnigramHome> createState() => _OmnigramHomeState();
}

class _OmnigramHomeState extends ConsumerState<OmnigramHome> {
  OmnigramTab _currentTab = OmnigramTab.reading;

  Widget _buildPage() {
    switch (_currentTab) {
      case OmnigramTab.reading:
        return const DeskPage();
      case OmnigramTab.bookshelf:
        return const LibraryPage();
      case OmnigramTab.insights:
        return const InsightsPage();
      case OmnigramTab.settings:
        return const omnigram.SettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: _buildPage()),
          ],
        ),
      );
    }

    return Scaffold(
      body: _buildPage(),
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

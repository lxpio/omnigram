import 'dart:ui';

import 'package:omnigram/dao/database.dart';
import 'package:omnigram/enums/sync_direction.dart';
import 'package:omnigram/enums/sync_trigger.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/home_page/ai_page.dart';
import 'package:omnigram/service/initialization_check.dart';
import 'package:omnigram/page/home_page/bookshelf_page.dart';
import 'package:omnigram/page/home_page/notes_page.dart';
import 'package:omnigram/page/home_page/settings_page.dart';
import 'package:omnigram/page/home_page/statistics_page.dart';
import 'package:omnigram/service/receive_file/receive_share.dart';
import 'package:omnigram/service/vibration_service.dart';
import 'package:omnigram/utils/check_update.dart';
import 'package:omnigram/utils/env_var.dart';
import 'package:omnigram/utils/get_path/get_temp_dir.dart';
import 'package:omnigram/utils/load_default_font.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:omnigram/providers/sync.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/widgets/ai/ai_chat_stream.dart';
import 'package:omnigram/widgets/common/container/filled_container.dart';
import 'package:omnigram/widgets/settings/about.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

WebViewEnvironment? webViewEnvironment;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _currentTab = 'bookshelf';

  bool? _expanded;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAnx());
  }

  Future<void> _checkWindowsWebview() async {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    AnxLog.info('WebView2 version: $availableVersion');

    if (availableVersion == null) {
      SmartDialog.show(
        builder: (context) => AlertDialog(
          title: const Icon(Icons.error),
          content: Text(L10n.of(context).webview2NotInstalled),
          actions: [
            TextButton(
              onPressed: () => {
                launchUrl(
                  Uri.parse('https://developer.microsoft.com/en-us/microsoft-edge/webview2'),
                  mode: LaunchMode.externalApplication,
                ),
              },
              child: Text(L10n.of(context).webview2Install),
            ),
          ],
        ),
      );
    } else {
      webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(userDataFolder: (await getAnxTempDir()).path),
      );
    }
  }

  void _showDbUpdatedDialog() {
    SmartDialog.show(
      clickMaskDismiss: false,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context).commonAttention),
        content: Text(L10n.of(context).dbUpdatedTip),
        actions: [
          TextButton(
            onPressed: () {
              SmartDialog.dismiss();
            },
            child: Text(L10n.of(context).commonOk),
          ),
        ],
      ),
    );
  }

  Future<void> initAnx() async {
    AnxToast.init(context);
    checkUpdate(false);
    InitializationCheck.check();
    if (Prefs().webdavStatus) {
      await Sync().init();
      await Sync().syncData(SyncDirection.both, ref, trigger: SyncTrigger.auto);
    }
    loadDefaultFont();

    if (AnxPlatform.isWindows) {
      await _checkWindowsWebview();
    }

    if (AnxPlatform.isAndroid || AnxPlatform.isIOS || AnxPlatform.isOhos) {
      receiveShareIntent(ref);
    }

    if (DBHelper.updatedDB) {
      _showDbUpdatedDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> navBarItems = [
      {'icon': EvaIcons.book_open, 'label': L10n.of(context).navBarBookshelf, 'identifier': 'bookshelf'},
      if (Prefs().bottomNavigatorShowStatistics)
        {'icon': Icons.show_chart, 'label': L10n.of(context).navBarStatistics, 'identifier': 'statistics'},
      if (Prefs().bottomNavigatorShowAI && EnvVar.enableAIFeature)
        {'icon': Icons.auto_awesome, 'label': L10n.of(context).navBarAI, 'identifier': 'ai'},
      if (Prefs().bottomNavigatorShowNote)
        {'icon': Icons.note, 'label': L10n.of(context).navBarNotes, 'identifier': 'notes'},
      {'icon': EvaIcons.settings_2, 'label': L10n.of(context).navBarSettings, 'identifier': 'settings'},
    ];

    int currentIndex = navBarItems.indexWhere((element) => element['identifier'] == _currentTab);
    if (currentIndex == -1) {
      currentIndex = 0;
      _currentTab = 'bookshelf';
    }

    Widget pages(int index, BoxConstraints constraints, ScrollController? controller) {
      final page = [
        BookshelfPage(controller: controller),
        if (Prefs().bottomNavigatorShowStatistics) StatisticPage(controller: controller),
        if (Prefs().bottomNavigatorShowAI && EnvVar.enableAIFeature) AiChatStream(),
        if (Prefs().bottomNavigatorShowNote) NotesPage(controller: controller),
        SettingsPage(controller: controller),
      ];
      return page[index];
    }

    void onBottomTap(int index, bool fromRail) {
      VibrationService.heavy();
      if (navBarItems[index]['identifier'] == 'ai' && !fromRail) {
        showCupertinoSheet(context: context, builder: (context) => const AiPage());
        return;
      }
      setState(() {
        _currentTab = navBarItems[index]['identifier'];
      });
    }

    List<NavigationRailDestination> railBarItems = navBarItems.map((item) {
      return NavigationRailDestination(icon: Icon(item['icon'] as IconData), label: Text(item['label'] as String));
    }).toList();

    List<BottomNavigationBarItem> bottomBarItems = navBarItems.map((item) {
      return BottomNavigationBarItem(icon: Icon(item['icon'] as IconData), label: item['label'] as String);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        _expanded ??= constraints.maxWidth > 1000;
        if (constraints.maxWidth > 600) {
          return Scaffold(
            extendBody: true,
            body: Row(
              children: [
                SafeArea(
                  bottom: false,
                  child: FilledContainer(
                    margin: const EdgeInsets.all(16),
                    color: ElevationOverlay.applySurfaceTint(
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.primary,
                      3,
                    ),
                    radius: 20,
                    child: SafeArea(
                      child: NavigationRail(
                        leading: InkWell(
                          onTap: () => openAboutDialog(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Image.asset(
                              width: 32,
                              height: 32,
                              'assets/icon/Anx-logo-tined.png',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        groupAlignment: 1,
                        extended: false,
                        selectedIndex: currentIndex,
                        onDestinationSelected: (int index) => onBottomTap(index, true),
                        destinations: railBarItems,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: Colors.transparent,
                        // elevation: 0,
                      ),
                    ),
                  ),
                ),
                Expanded(child: pages(currentIndex, constraints, null)),
              ],
            ),
          );
        } else {
          if (navBarItems[currentIndex]['identifier'] == 'ai') {
            currentIndex = 0;
          }
          return Scaffold(
            extendBody: true,
            body: BottomBar(
              width: 330,
              body: (_, controller) => pages(currentIndex, constraints, controller),
              hideOnScroll: Prefs().autoHideBottomBar,
              scrollOpposite: false,
              curve: Curves.easeIn,
              barColor: Colors.transparent,
              iconDecoration: BoxDecoration(
                color: Prefs().autoHideBottomBar ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(500),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(123),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                    ),
                    child: BottomNavigationBar(
                      selectedFontSize: 12,
                      enableFeedback: true,
                      type: BottomNavigationBarType.fixed,
                      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
                      currentIndex: currentIndex,
                      onTap: (int index) => onBottomTap(index, false),
                      items: bottomBarItems,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      // height: 64,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

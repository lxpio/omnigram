import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/providers/server_info.provider.dart';
import 'package:omnigram/providers/theme.provider.dart';

import 'views/about_view.dart';
import 'views/logout_listtile_view.dart';
import 'views/scan_status_view.dart';
import 'views/theme_select_dialog_view.dart';
import 'views/unauthorized_view.dart';

class ProfileSmallScreen extends HookConsumerWidget {
  const ProfileSmallScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      debugPrint("User is un authenticated");
      return const UnauthorizedView();
    }

    final scrollController = useScrollController();

    final isScrolled = useState(false);

    useEffect(() {
      someCallback() {
        if (scrollController.offset >= 100.0) {
          isScrolled.value = true;
        } else {
          isScrolled.value = false;
        }
      }

      scrollController.addListener(someCallback);
      return () => scrollController.removeListener(someCallback);
    }, [scrollController]);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          elevation: 0,
          pinned: true,
          floating: true,
          stretch: true,
          leading: AnimatedOpacity(
            opacity: isScrolled.value ? 1.0 : 0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[400],
                  // backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/81.jpg'),
                ),
              ),
            ),
          ),
          // backgroundColor: Colors.grey.shade50,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,

            // titlePadding:
            //     const EdgeInsets.only(left: 20, right: 30, bottom: 100),
            stretchModes: const [
              StretchMode.zoomBackground,
              // StretchMode.fadeTitle,
              StretchMode.blurBackground,
            ],
            centerTitle: false,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[200],
                        // backgroundImage: NetworkImage(
                        //     'https://randomuser.me/api/portraits/men/81.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    authState.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(authState.userEmail),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            if (authState.isAdmin) const SizedBox(height: 16),
            if (authState.isAdmin) const ScanStatusView(),
            const SizedBox(height: 32),
            const _SettingsWidget(),
            const SizedBox(height: 16),
            const AboutView(),
            const SizedBox(height: 32),
            const LogoutListTileView(),
          ]),
        ),
      ],
      controller: scrollController,
    );
  }
}

class _SettingsWidget extends ConsumerWidget {
  const _SettingsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeStateProvider);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("settings".tr()),
          const SizedBox(height: 8),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text("settings_theme_mode".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.primary.withAlpha(20)),
                  child: Text(
                    getThemeModeLangTag(mode).tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      // color: Color(
                      //     int.parse("0xff${job.experienceLevelColor}")),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () async {
              final result = await showDialog(
                  builder: (context) {
                    return ThemeSelectDialogView(mode);
                  },
                  context: context);

              final themeMode = result as ThemeMode?;

              if (themeMode != null && themeMode != mode) {
                debugPrint("themeMode: $themeMode");
                ref.read(themeStateProvider.notifier).setTheme(themeMode);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language
                // size: 64,
                ),
            title: Text("setting_language".tr()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.primary.withAlpha(20)),
                  child: const Text(
                    '中文',
                    style: TextStyle(
                      fontSize: 14,
                      // color: Color(
                      //     int.parse("0xff${job.experienceLevelColor}")),
                    ),
                  ),
                ),
                // Text("中文", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          // ListTile(
          //   leading: const Icon(
          //     Icons.headphones,
          //     // size: 64,
          //   ),
          //   title: const Text("听书"),
          //   subtitle: const Text("开启听书功能"),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Switch(
          //         value: data.m4tSupport,
          //         onChanged: (bool value) {},
          //       ),
          //       // Text("中文", style: TextStyle(fontSize: 16)),
          //       const SizedBox(width: 8),
          //       const Icon(Icons.arrow_forward_ios),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

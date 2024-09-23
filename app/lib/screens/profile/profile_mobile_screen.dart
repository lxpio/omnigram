import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/providers/server_info.provider.dart';
import 'package:omnigram/screens/profile/views/unauthorized_view.dart';



import 'views/scan_status_view.dart';

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
            // title: isScrolled.value ? const Text("Profile") : null,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.2),
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.2),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
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
          actions: isScrolled.value
              ? [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 12),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                authState.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                authState.userEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(64),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            // backgroundImage: NetworkImage(
                            //     'https://randomuser.me/api/portraits/men/81.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : null,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            const ScanStatusView(),
            const SizedBox(height: 32),
            const _SettingsWidget(),
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


    final info = ref.watch(serverInfoProvider);


    return info.when(data: (data) => Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings"),
          const SizedBox(height: 8),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.color_lens_outlined),
            title: Text("主题"),
            subtitle: Text("选择深色或者浅色主题"),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            leading: const Icon(Icons.language
                // size: 64,
                ),
            title: const Text("语言"),
            // subtitle: Text("您首选语言"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(20)),
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
          ListTile(
            leading: const Icon(
              Icons.headphones,
              // size: 64,
            ),
            title: const Text("听书"),
            subtitle: const Text("开启听书功能"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: data.m4tSupport,
                  onChanged: (bool value) {},
                ),
                // Text("中文", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              // size: 64,
            ),
            title: const Text("登出"),
            // subtitle: Text("开启听书功能"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Switch(
                //   value: true,
                //   onChanged: (bool value) {},
                // ),
                // // Text("中文", style: TextStyle(fontSize: 16)),
                // const SizedBox(width: 8),
                IconButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            ),
          )
        ],
      ),
    ),
        loading: () => const CircularProgressIndicator(),
        error: (error, stackTrace) => Text(error.toString()));


    
  }

  // void showChapterBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     showDragHandle: true,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
  //     ),
  //     constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width,
  //         MediaQuery.of(context).size.height * .4)),
  //     builder: (BuildContext context) {
  //       return ChapterSheetView(controller: controller);
  //     },
  //   );
  // }
}



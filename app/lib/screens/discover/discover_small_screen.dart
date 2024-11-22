import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/utils/constants.dart';

import 'views/epub_index_view.dart';

import '../../providers/select_book.dart';

import '../views/stackbar.dart';

class DiscoverSmallScreen extends HookConsumerWidget {
  const DiscoverSmallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final selected = ref.watch(selectBookProvider);

    final buttonFocusNode = useFocusNode(debugLabel: 'More Button');

    final scrollController = useScrollController();

    final isScrolled = useState(false);

    useEffect(() {
      someCallback() {
        if (scrollController.offset >= 30.0) {
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
          expandedHeight: 150.0,
          elevation: 0,
          pinned: true,
          floating: true,
          stretch: true,
          centerTitle: true,
          title: isScrolled.value ? const Text("发现") : null,
          // backgroundColor: Colors.grey.shade50,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            titlePadding: const EdgeInsets.only(left: 20, right: 30, bottom: 100),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
              StretchMode.blurBackground,
            ],
            title: isScrolled.value ? null : const Text("Profile"),
            centerTitle: true,
            // title: const Text("Profile"),
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
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CircleAvatar(
                        radius: 24,
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
                    "发现",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          // actions: isScrolled.value
          //     ? [
          //         Padding(
          //           padding: const EdgeInsets.only(left: 8, right: 12),
          //           child: Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.only(left: 8, right: 8),
          //                 child: Text(
          //                   "TEST",
          //                   style: const TextStyle(
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //               ClipRRect(
          //                 borderRadius: BorderRadius.circular(64),
          //                 child: CircleAvatar(
          //                   radius: 48,
          //                   backgroundColor: Colors.grey[200],
          //                   // backgroundImage: NetworkImage(
          //                   //     'https://randomuser.me/api/portraits/men/81.jpg'),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ]
          //     : null,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            // const Stackbar(child: EpubIndexView()),
            const SizedBox(height: 32),
            // const _SettingsWidget(),
            const SizedBox(height: 2000),
          ]),
        ),
      ],
      controller: scrollController,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        actions: [
          IconButton(
            // onPressed: ,
            icon: const Icon(
              Icons.search,
              size: 24,
            ),
            onPressed: () {
              print("press search");
            },
          ),
          MenuAnchor(
            menuChildren: MoreMenus(context, authState.isAdmin),
            builder: (context, controller, child) {
              return IconButton(
                focusNode: buttonFocusNode,
                // onPressed: ,
                icon: const Icon(
                  Icons.more_vert,
                  size: 24,
                ),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
          ),
          // ),
          // const SizedBox(width: 16),
        ],
      ),
      body: const Stackbar(child: EpubIndexView()),
    );
  }

  List<MenuItemButton> MoreMenus(BuildContext context, bool admin) {
    //init base menu

    final menus = [
      MenuItemButton(
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.logout),
            ),
            Text('logout'.tr()),
          ],
        ),
        onPressed: () {
          context.pushNamed(kManagerPage);
        },
      ),
    ];

    if (admin) {
      menus.insert(
        0,
        MenuItemButton(
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.settings),
              ),
              Text('settings'.tr()),
            ],
          ),
          onPressed: () {
            context.pushNamed(kManagerPage);
          },
        ),
      );
    }

    return menus;
  }
}

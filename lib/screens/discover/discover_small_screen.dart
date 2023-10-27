import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';

import '../reader/views/epub_index_view.dart';

class DiscoverSmallScreen extends StatefulHookConsumerWidget {
  const DiscoverSmallScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DiscoverSmallScreenState();
}

class _DiscoverSmallScreenState extends ConsumerState<DiscoverSmallScreen> {
  final buttonFocusNode = FocusNode(debugLabel: 'More Button');

  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   final userInfo = ref.read(userProvider);
    //   print(userInfo.toString());
    // }

    final isAdmin = ref.watch(userProvider).roleId == 1;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // leading: Builder(builder: (context) {
        //   return IconButton(
        //     onPressed: () {
        //       Scaffold.of(context).openDrawer();
        //       // controller.focusNode.unfocus();
        //     },
        //     icon: const Icon(Icons.menu),
        //   );
        // }),
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

          // IconButton(
          //   // onPressed: ,
          //   icon: const Icon(
          //     Icons.more_vert,
          //     size: 24,
          //   ),
          //   onPressed: () {
          //     print("press person");
          //   },
          // ),
          MenuAnchor(
            menuChildren: MoreMenus(context, isAdmin),
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
      body: const EpubIndexView(),
    );
  }

  @override
  void dispose() {
    buttonFocusNode.dispose();
    super.dispose();
  }

  List<MenuItemButton> MoreMenus(BuildContext context, bool admin) {
    //init base menu

    final menus = [
      MenuItemButton(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: const Icon(Icons.logout),
            ),
            Text(context.l10n.logout),
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
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.settings),
              ),
              Text(context.l10n.settings),
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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';

import '../reader/providers/select_book.dart';
import '../reader/views/epub_index_view.dart';
import '../views/stackbar.dart';

class DiscoverSmallScreen extends HookConsumerWidget {
  const DiscoverSmallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(userProvider).roleId == 1;
    final selected = ref.watch(selectBookProvider);

    final buttonFocusNode = useFocusNode(debugLabel: 'More Button');

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
      body: const Stackbar(child: EpubIndexView()),
    );
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

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';

import '../reader/views/epub_index_view.dart';
import '../views/stackbar.dart';

class HomeSmallScreen extends HookConsumerWidget {
  const HomeSmallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectBookProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
              // controller.focusNode.unfocus();
            },
            icon: const Icon(Icons.menu),
          );
        }),
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
          IconButton(
            // onPressed: ,
            icon: const Icon(
              Icons.person,
              size: 24,
            ),
            onPressed: () {
              ref.read(userProvider.notifier).logout();

              print("press person");
            },
          ),
          // const SizedBox(width: 16),
        ],
      ),
      body: const Stackbar(child: EpubIndexView()),
    );
  }
}

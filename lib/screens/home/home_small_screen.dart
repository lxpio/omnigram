import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';

import '../reader/views/epub_index_view.dart';

class ReaderSmallScreen extends StatefulHookConsumerWidget {
  const ReaderSmallScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReaderSmallScreenState();
}

class _ReaderSmallScreenState extends ConsumerState<ReaderSmallScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: const EpubIndexView(),
    );
  }
}

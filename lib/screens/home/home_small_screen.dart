import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/destinations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adaptive_components/adaptive_components.dart';
import 'epub_body.dart';

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
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(0),
        //   child: Container(
        //     height: 2,
        //   ),
        // ),
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
        // title: Text(

        //   // controller.currentConversation?.displayName ?? 'new_chat'.tr,
        //   overflow: TextOverflow.ellipsis,
        //   maxLines: 1,
        // ),
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
              print("press person");
            },
          ),
          // const SizedBox(width: 16),
        ],
      ),
      body: const EpubPageBody(),
    );
  }
}

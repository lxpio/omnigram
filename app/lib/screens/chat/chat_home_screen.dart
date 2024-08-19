import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:omnigram/screens/chat/views/conversation_list_view.dart';
import 'package:omnigram/utils/constants.dart';

class ChatHomeScreen extends HookConsumerWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              print("press person");
            },
          ),
          // const SizedBox(width: 16),
        ],
      ),
      body: const ConversationListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        onPressed: () {
          // context.push('$kReaderPage/$kReaderDetailPage');
          context.pushNamed(
            kChatPagePath,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

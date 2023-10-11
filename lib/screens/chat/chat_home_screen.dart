import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:omnigram/screens/chat/views/conversation_list_view.dart';
import 'package:omnigram/utils/constants.dart';

class ChatHomeScreen extends StatefulHookConsumerWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  late final colorScheme = Theme.of(context).colorScheme;
  late final backgroundColor = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.14), colorScheme.surface);

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
              print("press person");
            },
          ),
          // const SizedBox(width: 16),
        ],
      ),
      body: const ConversationListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
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

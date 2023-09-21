import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';
import 'package:omnigram/utils/constants.dart';

import 'conversation_view.dart';

class ConversationListView extends StatefulHookConsumerWidget {
  const ConversationListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversationListViewState();
}

class _ConversationListViewState extends ConsumerState<ConversationListView> {
  final ScrollController _controller = ScrollController();
  int selectedIndex = 0;
  ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationProvider).query(max: 20);

    return Scrollbar(
      controller: _controller,
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const SearchBar(leading: Icon(Icons.search)),
          const SizedBox(height: 8),
          ...List.generate(
            conversations.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ConversationWidget(
                  conversation: conversations[index],
                  onSelected: () {
                    context.pushNamed(kChatPagePath,
                        extra: conversations[index]);
                  },
                  isSelected: selectedIndex == index,
                ),
              );
            },
          ),
        ],
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //   child:
    // );
  }
}

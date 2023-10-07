import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'conversation_view.dart';
import 'provider/conversation_list.dart';

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
    final conversations = ref.watch(conversationListProvider);

    return conversations.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          controller: _controller,
          children: [
            const SizedBox(height: 8),
            const SearchBar(leading: Icon(Icons.search)),
            const SizedBox(height: 8),
            ...List.generate(
              data.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ConversationWidget(
                    conversation: data[index],
                    onSelected: () {
                      context.pushNamed(kChatPagePath, extra: data[index]);
                    },
                    isSelected: selectedIndex == index,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      loading: () => LinearProgressIndicator(),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}

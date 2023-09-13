import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';

import 'conversation_view.dart';

class ConversationList extends HookConsumerWidget {
  const ConversationList({
    super.key,
    this.selectedIndex,
    this.onSelected,
    // required this.currentUser,
  });

  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  // final User currentUser;

  // const Conversation({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationProvider).query(max: 10);

    late final _colorScheme = Theme.of(context).colorScheme;
    late final _backgroundColor = Color.alphaBlend(
        _colorScheme.primary.withOpacity(0.14), _colorScheme.surface);

    return Scaffold(
      // appBar: AppBar(
      //   leading: Builder(builder: (context) {
      //     return IconButton(
      //       onPressed: () {
      //         //back to from
      //         context.pop();
      //       },
      //       icon: const Icon(Icons.menu),
      //     );
      //   }),
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            SearchBar(leading: const Icon(Icons.search)),
            const SizedBox(height: 8),
            ...List.generate(
              conversations.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ConversationWidget(
                    conversation: conversations[index],
                    onSelected: onSelected != null
                        ? () {
                            onSelected!(index);
                          }
                        : null,
                    isSelected: selectedIndex == index,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorScheme.tertiaryContainer,
        foregroundColor: _colorScheme.onTertiaryContainer,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

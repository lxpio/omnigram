import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';
import 'package:omnigram/screens/chat/chat_item_view.dart';

class ChatWidget extends ConsumerWidget {
  const ChatWidget({
    Key? key,
    required this.messages,
    required this.controller,
  }) : super(key: key);

  final List<Message> messages;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scrollbar(
      controller: controller,
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          reverse: true,
          shrinkWrap: true,
          controller: controller,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // switch(messages[index].role) {
            //   case Role.user:
            // }
            return ChatItemView(messages[index]);
          },
        ),
      ),
    );
  }
}

import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/views/chat_text_receive_item_view.dart';
import 'package:flutter/material.dart';


class ChatView extends StatelessWidget {
  final List<Message> messages;
  final ScrollController controller;
  final ValueChanged<Message> onRetried;
  final ValueChanged<Message> onAvatarClicked;
  final ValueChanged<Message>? onQuoted;

  const ChatView({
    Key? key,
    required this.messages,
    required this.controller,
    required this.onRetried,
    required this.onAvatarClicked,
    required this.onQuoted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
             return ChatTextItemView(
              message: messages[index],
              onRetried: onRetried,
              onAvatarClicked: onAvatarClicked,
              onQuoted: onQuoted,
            );
          },
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        ),
      ),
    );
  }
}

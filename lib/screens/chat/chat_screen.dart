import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/screens/chat/chat_view.dart';

import '../../providers/service/chat/message_model.dart';

class ChatScreen extends StatefulHookConsumerWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
  });

  final Conversation conversation;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<Message> messages = [];

  late final scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ChatWidget(messages: messages, controller: scroll),
          )
        ],
      ),
    );

    // return LayoutBuilder(builder: (context, constraints) {
    //   return Container();
    // });
  }
}

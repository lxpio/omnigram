import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/chat_input.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';
import 'package:omnigram/providers/service/chat/message_provider.dart';
import 'package:omnigram/screens/chat/chat_item_view.dart';

import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'chat_page_screen.g.dart';

final msgIndexProvider = Provider<int>((_) {
  throw UnimplementedError();
});
//TODO https://github.com/rei-codes/advanced_list_riverpod/blob/main/lib/pages/home_page.dart

@riverpod
class MessageList extends _$MessageList {
  @override
  List<Message> build(int id) {
    return [];
  }
}

class ChatPageScreen extends StatefulHookConsumerWidget {
  const ChatPageScreen({
    super.key,
    required this.conversation,
  });

  final Conversation conversation;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends ConsumerState<ChatPageScreen> {
  late final List<Message> messages = [];

  final _scroll = ScrollController();

  late final focusNode = FocusNode();
  late final textEditing = TextEditingController();

  // @override
  // void initState() {
  //   final msgProvider = ref.read(messageProvider);

  //   loadMessages(msgProvider, 0);
  //   // _scroll = ScrollController(initialScrollOffset: 0.0);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    loadMessages();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          widget.conversation.displayName ?? context.l10n.new_chat,
        ),
        centerTitle: true,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {
              print("press search");
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {
              print("press person");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scroll,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                // switch(messages[index].role) {
                //   case Role.user:
                // }
                return ChatItemView(
                  message: messages[index],
                  onAvatarClicked: (value) {},
                );
              },
            ),
            // ),
          ),
          ChatInput(
            controller: textEditing,
            focusNode: focusNode,
            onSubmitted: onSendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> onSendMessage() async {
    if (textEditing.text.isEmpty) {
      return;
    }

    if (widget.conversation.id == 0) {
      widget.conversation.name = textEditing.text;

      //保存会话
      ref.read(conversationProvider).create(widget.conversation);

      if (kDebugMode) {
        print('create new conversion and id ${widget.conversation.id}');
      }
    }

    // 发送消息
    final msg = Message(
      conversationId: widget.conversation.id,
      role: Role.user,
      createAt: DateTime.now(),
      content: textEditing.text,
    );

    if (kDebugMode) {
      print(
          'current conversion id ${widget.conversation.id}, cuurent message: ${textEditing.text}');
    }

    ref.read(messageProvider).create(msg);

    textEditing.clear();

    setState(() {
      messages.add(msg);
      _scrollDown();
    });

    //send message to remote
  }

  //scroll to last message

  void _scrollDown() {
    _scroll.animateTo(
      //see https://github.com/flutter/flutter/issues/71742
      _scroll.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> queryMessages(MessageProvider msgProvider, int offset) async {
    final id = widget.conversation.id;

    if (id == 0) {
      //处理新增逻辑
      final msg = Message(
        conversationId: id,
        role: Role.system,
        createAt: DateTime.now(),
        content: context.l10n.open_ai_hello,
      );

      messages.add(msg);

      return;
    }

    final list = msgProvider.query(
        conversationId: widget.conversation.id, offset: offset);

    if (kDebugMode) {
      print('current conversion id $id, get message counts: ${list.length}');
    }

    messages.clear();
    messages.addAll(list);
  }

  void loadMessages() {
    final id = widget.conversation.id;

    if (id == 0) {
      //处理新增逻辑
      final msg = Message(
        conversationId: id,
        role: Role.system,
        createAt: DateTime.now(),
        content: context.l10n.open_ai_hello,
      );

      messages.add(msg);

      return;
    }

    final list = ref.read(messageProvider).query(conversationId: id);

    if (kDebugMode) {
      print('current conversion id $id, get message counts: ${list.length}');
    }

    messages.addAll(list);
  }
}

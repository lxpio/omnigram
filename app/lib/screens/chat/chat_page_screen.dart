import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/chat/views/input_view.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';

import 'package:omnigram/utils/localization.service.dart';

import 'models/conversation.dart';
import 'models/message.dart';
import 'provider/conversation_list.dart';
import 'provider/message_list.dart';
import 'provider/openai_service.dart';
import 'views/message_list_view.dart';

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
  final _scroll = ScrollController();

  late final focusNode = FocusNode();
  late final textEditing = TextEditingController();

  @override
  void initState() {
    if (widget.conversation.id == 0) {
      final count = ref.read(conversationProvider).count();
      widget.conversation.id = count + 1;
    }

    // _scroll = ScrollController(initialScrollOffset: 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.conversation.displayName ?? 'new_chat'.tr(), //TODO
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
            child: MessageListView(widget.conversation.id, _scroll),
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

    //第一次发送则存储回话信息
    if (!widget.conversation.isActive) {
      if (kDebugMode) {
        print('create new conversion and id ${widget.conversation.id}');
      }
      widget.conversation.name = textEditing.text.length > 20
          ? textEditing.text.substring(0, 20)
          : textEditing.text;
      widget.conversation.isActive = true;
      //保存会话
      await ref
          .read(conversationListProvider.notifier)
          .add(widget.conversation);
    }

    // 发送消息
    final msgList = await _appendMessages(widget.conversation.id);

    final stream = ref.read(openAIServiceProvider).chatSSE(messages: msgList);

    stream.listen(
      (data) {
        // This is called whenever new data is received from the SSE stream
        // Do something with the data, e.g., write it to another variable
        // For example, if you have a variable called 'myData', you can do this:
        // myData = data;
        final delta = data.choices?[0].message?.content;

        if (delta != null && delta.isNotEmpty) {
          ref
              .read(messageListProvider(widget.conversation.id).notifier)
              .append(delta);
        }

        _scroll.animateTo(
          //see https://github.com/flutter/flutter/issues/71742
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );

        // print(data.choices![0].message!.content);
      },
      onError: (error) {
        // Handle errors from the SSE stream if necessary
        ref
            .read(messageListProvider(widget.conversation.id).notifier)
            .markError("error: $error");
      },
      onDone: () {
        // This is called when the SSE stream is closed or no more data is available
        // Perform any cleanup or closing operations here if needed
        ref
            .read(messageListProvider(widget.conversation.id).notifier)
            .savelast();

        _scrollDown();
      },
    );
  }

  Future<List<Message>> _appendMessages(int id) async {
    // 发送消息
    final msgs = [
      Message(
        conversationId: id,
        role: Role.user,
        createAt: DateTime.now(),
        content: textEditing.text,
        type: MessageType.text,
      ),
      Message(
        conversationId: id,
        role: Role.assistant,
        createAt: DateTime.now(),
        content: '',
        type: MessageType.text,
      )
    ];

    if (kDebugMode) {
      print('current conversion id $id, cuurent message: ${textEditing.text}');
    }

    await ref.read(messageListProvider(id).notifier).create(msgs);

    textEditing.clear();

    _scrollDown();

    final msgsList = ref.read(messageListProvider(id)).value;

    //if msgsList is null return msgs

    if (msgsList == null || msgsList.length < 3) {
      return [msgs.first];
    }
    return msgsList.sublist(1, msgsList.length - 1);
  }

  //scroll to last message

  void _scrollDown() {
    _scroll.animateTo(
      //see https://github.com/flutter/flutter/issues/71742
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }
}

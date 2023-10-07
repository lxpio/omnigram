import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/chat/input_view.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';

import 'package:omnigram/screens/chat/chat_item_view.dart';

import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';

import 'provider/conversation_list.dart';
import 'provider/message_list.dart';
import 'provider/openai_service.dart';

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
      widget.conversation.name = textEditing.text;
      widget.conversation.isActive = true;
      //保存会话
      ref.read(conversationListProvider.notifier).add(widget.conversation);
      if (kDebugMode) {
        print('create new conversion and id ${widget.conversation.id}');
      }
    }

    // 发送消息
    final msgs = [
      Message(
        conversationId: widget.conversation.id,
        role: Role.user,
        createAt: DateTime.now(),
        content: textEditing.text,
      ),
      Message(
        conversationId: widget.conversation.id,
        role: Role.assistant,
        createAt: DateTime.now(),
        content: '',
      )
    ];

    if (kDebugMode) {
      print(
          'current conversion id ${widget.conversation.id}, cuurent message: ${textEditing.text}');
    }

    ref.read(messageListProvider(widget.conversation.id).notifier).create(msgs);

    textEditing.clear();

    _scrollDown();

    final stream =
        ref.read(openAIServiceProvider).chatSSE(messages: [msgs.first]);

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
        print("error: $error");
      },
      onDone: () {
        // This is called when the SSE stream is closed or no more data is available
        // Perform any cleanup or closing operations here if needed
        ref
            .read(messageListProvider(widget.conversation.id).notifier)
            .savelast();

        _scrollDown();
        print("done");
      },
    );
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

  // void loadMessages() {
  //   final id = widget.conversation.id;

  //   if (id == 0) {
  //     //处理新增逻辑
  //     final msg = Message(
  //       conversationId: id,
  //       role: Role.system,
  //       createAt: DateTime.now(),
  //       content: context.l10n.open_ai_hello,
  //     );

  //     messages.add(msg);

  //     return;
  //   }

  //   final list = ref.read(messageProvider).query(conversationId: id);

  //   if (kDebugMode) {
  //     print('current conversion id $id, get message counts: ${list.length}');
  //   }

  //   messages.addAll(list);
  // }
}

class MessageListView extends ConsumerWidget {
  const MessageListView(this.conversationId, this.scrollController,
      {super.key});

  final int conversationId;

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageListProvider(conversationId));

    return messages.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Center(child: Text(err.toString())),
      data: (data) {
        if (data.isEmpty) {
          sendTipMessage(context, ref, conversationId);
        }

        return ListView.builder(
          shrinkWrap: true,
          controller: scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            // switch(messages[index].role) {
            //   case Role.user:
            // }
            return ProviderScope(
              overrides: [msgIndexProvider.overrideWith((_) => index)],
              child: ChatItemView(
                message: data[index],
                onAvatarClicked: (value) {},
              ),
            );
          },
        );
      },
    );
  }

  void sendTipMessage(BuildContext context, WidgetRef ref, int id) {
    final msg = Message(
      conversationId: id,
      role: Role.system,
      createAt: DateTime.now(),
      content: context.l10n.open_ai_hello,
    );

    ref.read(messageListProvider(id).notifier).tips(msg);
  }
}

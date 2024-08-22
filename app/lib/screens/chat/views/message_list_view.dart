import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/utils/localization.service.dart';

import '../models/message.dart';
import '../provider/message_list.dart';
import 'chat_item_view.dart';

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
      content: 'open_ai_hello'.tr(),
    );

    ref.read(messageListProvider(id).notifier).tips(msg);
  }
}

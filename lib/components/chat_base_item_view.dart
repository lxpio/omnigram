import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/utils/app_toast.dart';
import 'package:share_plus/share_plus.dart';

import 'chat_avatar.dart';

abstract class ChatBaseItemView extends HookConsumerWidget {
  static const avatarWidth = 16.0;

  final Message message;
  final ValueChanged<Message>? onRetried;
  final ValueChanged<Message>? onAvatarClicked;
  final ValueChanged<Message>? onQuoted;

  const ChatBaseItemView({
    Key? key,
    required this.message,
    this.onRetried,
    required this.onAvatarClicked,
    this.onQuoted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        padding: const EdgeInsets.all(8),
        child: message.role != Role.user
            ? buildReceiveRow(context, ref)
            : buildSendRow(context, ref),
      );

  Widget buildContent(BuildContext context, WidgetRef ref);

  Widget buildReceiveRow(BuildContext context, WidgetRef ref) {
    final container = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: buildContent(context, ref),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onAvatarClicked?.call(message),
                child: Text(
                  message.serviceName ?? '-',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              message.type == MessageType.error
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: container,
                        ),
                        IconButton(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 0,
                            right: 16,
                            bottom: 16,
                          ),
                          onPressed: () => onRetried?.call(message),
                          icon: Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    )
                  : container,
              if ((message.type == MessageType.text) ||
                  message.type == MessageType.image)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildButton(
                      context: context,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: message.content ?? "",
                          ),
                        );
                        AppToast.show(msg: 'copied');
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    buildButton(
                      context: context,
                      onPressed: () {
                        if (message.type == MessageType.text) {
                          Share.share(
                            message.content,
                            subject: message.serviceName,
                          );
                        }
                      },
                      icon: const Icon(Icons.share),
                    ),
                    buildButton(
                      context: context,
                      onPressed: () {
                        onQuoted?.call(message);
                      },
                      icon: const Icon(
                        Icons.format_quote_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(
          width: avatarWidth,
        ),
      ],
    );
  }

  Widget buildButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: 32,
        height: 32,
      ),
      iconSize: 16,
      onPressed: onPressed,
      icon: icon,
    );
  }

  Widget buildSendRow(BuildContext context, WidgetRef ref) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 8 + avatarWidth,
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: buildContent(context, ref),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          _buildAvatar(context),
        ],
      );

  Widget _buildAvatar(BuildContext context) => GestureDetector(
        onTap: () => onAvatarClicked?.call(message),
        child: ChatAvatar(
          source: message.serviceAvatar ?? Icons.person,
          width: avatarWidth,
          height: avatarWidth,
          radius: const Radius.circular(8),
          backgroundColor: Colors.white,
        ),
      );
}

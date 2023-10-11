import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/screens/chat/models/message.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/utils/show_snackbar.dart';
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
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 4,
              ),
              (message.error != null && message.error!.isNotEmpty)
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
                    const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.campaign),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: message.content,
                          ),
                        ).then((value) {
                          showSnackBar(context, context.l10n.copied);
                        });
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () {
                        if (message.type == MessageType.text) {
                          Share.share(
                            message.content,
                            // subject: message,
                          );
                        }
                      },
                      icon: const Icon(Icons.share),
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

  Widget _buildAvatar(BuildContext context) => ChatAvatar(
        source: Icons.person,
        width: avatarWidth,
        height: avatarWidth,
        radius: const Radius.circular(8),
        backgroundColor: Colors.white,
      );
}

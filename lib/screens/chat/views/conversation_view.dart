import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/utils/show_snackbar.dart';

import '../models/conversation.dart';
import '../provider/conversation_list.dart';

class ConversationWidget extends StatefulHookConsumerWidget {
  const ConversationWidget({
    super.key,
    required this.conversation,
    this.isSelected = false,
    this.isPreview = true,
    this.isThreaded = false,
    this.showHeadline = false,
    this.onSelected,
  });

  final bool isSelected;
  final bool isPreview;
  final bool showHeadline;
  final bool isThreaded;
  final void Function()? onSelected;
  final Conversation conversation;

  @override
  ConsumerState<ConversationWidget> createState() => _ConversationWidgetState();
}

class _ConversationWidgetState extends ConsumerState<ConversationWidget> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late Color unselectedColor = Color.alphaBlend(
    _colorScheme.primary.withOpacity(0.08),
    _colorScheme.surface,
  );

  Color get _surfaceColor {
    if (!widget.isPreview) return _colorScheme.surface;
    if (widget.isSelected) return _colorScheme.primaryContainer;
    return unselectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      child: Card(
        elevation: 0,
        color: _surfaceColor,
        clipBehavior: Clip.hardEdge,
        child: Slidable(
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: context.l10n.delete,
                onPressed: (BuildContext context) {
                  ref
                      .read(conversationListProvider.notifier)
                      .remove(widget.conversation)
                      .then((_) {
                    showSnackBar(
                        context,
                        context.l10n.deleted(
                            widget.conversation.name ?? 'Conversation'));
                  }).onError((error, stackTrace) {
                    showSnackBar(
                        context,
                        context.l10n.deleted_error(
                            widget.conversation.name ?? 'Conversation'));
                  });
                },
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showHeadline) ...[
                ConversationHeadline(
                  conversation: widget.conversation,
                  isSelected: widget.isSelected,
                ),
              ],
              ConversationContent(
                conversation: widget.conversation,
                isPreview: widget.isPreview,
                isThreaded: widget.isThreaded,
                isSelected: widget.isSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationHeadline extends StatefulWidget {
  const ConversationHeadline({
    super.key,
    required this.conversation,
    required this.isSelected,
  });

  final Conversation conversation;
  final bool isSelected;

  @override
  State<ConversationHeadline> createState() => _ConversationHeadlineState();
}

class _ConversationHeadlineState extends State<ConversationHeadline> {
  late final TextTheme _textTheme = Theme.of(context).textTheme;
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 84,
        color: Color.alphaBlend(
          _colorScheme.primary.withOpacity(0.05),
          _colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'TODO Messages',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: _textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Display a "condensed" version if the widget in the row are
              // expected to overflow.
              if (constraints.maxWidth - 200 > 0) ...[
                SizedBox(
                  height: 40,
                  width: 40,
                  child: FloatingActionButton(
                    onPressed: () {},
                    elevation: 0,
                    backgroundColor: _colorScheme.surface,
                    child: const Icon(Icons.delete_outline),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 8.0)),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: FloatingActionButton(
                    onPressed: () {},
                    elevation: 0,
                    backgroundColor: _colorScheme.surface,
                    child: const Icon(Icons.more_vert),
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    });
  }
}

class ConversationContent extends StatefulWidget {
  const ConversationContent({
    super.key,
    required this.conversation,
    required this.isPreview,
    required this.isThreaded,
    required this.isSelected,
  });

  final Conversation conversation;
  final bool isPreview;
  final bool isThreaded;
  final bool isSelected;

  @override
  State<ConversationContent> createState() => _ConversationContentState();
}

class _ConversationContentState extends State<ConversationContent> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  Widget get contentSpacer => SizedBox(height: widget.isThreaded ? 20 : 2);

  String get lastActiveLabel {
    final DateTime now = DateTime.now();
    if (widget.conversation.lastActive.isAfter(now)) throw ArgumentError();
    final Duration elapsedTime =
        widget.conversation.lastActive.difference(now).abs();
    if (elapsedTime.inSeconds < 60) return '${elapsedTime.inSeconds}s';
    if (elapsedTime.inMinutes < 60) return '${elapsedTime.inMinutes}m';
    if (elapsedTime.inHours < 60) return '${elapsedTime.inHours}h';
    if (elapsedTime.inDays < 365) return '${elapsedTime.inDays}d';
    throw UnimplementedError();
  }

  TextStyle? get contentTextStyle {
    if (widget.isThreaded) {
      return _textTheme.bodyLarge;
    }
    if (widget.isSelected) {
      return _textTheme.bodyMedium
          ?.copyWith(color: _colorScheme.onPrimaryContainer);
    }
    return _textTheme.bodyMedium
        ?.copyWith(color: _colorScheme.onSurfaceVariant);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            title: Text(
              widget.conversation.name ?? 'new chat',
              overflow: TextOverflow.fade,
              maxLines: 1,
              style: widget.isSelected
                  ? _textTheme.labelMedium
                      ?.copyWith(color: _colorScheme.onSecondaryContainer)
                  : _textTheme.labelMedium
                      ?.copyWith(color: _colorScheme.onSurface),
            ),
            // subtitle: Text('TODO'),
            trailing: Text(
              lastActiveLabel,
              overflow: TextOverflow.fade,
              maxLines: 1,
              style: widget.isSelected
                  ? _textTheme.labelMedium
                      ?.copyWith(color: _colorScheme.onSecondaryContainer)
                  : _textTheme.labelMedium
                      ?.copyWith(color: _colorScheme.onSurfaceVariant),
            ),
          ),

          const SizedBox(width: 8),
          Text(
            'lastActiveLabel',
            overflow: TextOverflow.fade,
            maxLines: 3,
            style: widget.isSelected
                ? _textTheme.labelMedium
                    ?.copyWith(color: _colorScheme.onSecondaryContainer)
                : _textTheme.labelMedium
                    ?.copyWith(color: _colorScheme.onSurfaceVariant),
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     if (widget.isPreview) ...[
          //       Text(
          //         widget.conversation.displayName ?? "",
          //         style: const TextStyle(fontSize: 18)
          //             .copyWith(color: _colorScheme.onSurface),
          //       ),
          //     ],
          //     // if (widget.isThreaded) ...[
          //     //   contentSpacer,
          //     //   Text(
          //     //     "To ${widget.email.recipients.map((recipient) => recipient.name.first).join(", ")}",
          //     //     style: _textTheme.bodyMedium,
          //     //   )
          //     // ],
          //     contentSpacer,
          //     Text(
          //       widget.conversation.name ?? "",
          //       maxLines: widget.isPreview ? 2 : 100,
          //       overflow: TextOverflow.ellipsis,
          //       style: contentTextStyle,
          //     ),
          //   ],
          // ),
          const SizedBox(width: 12),
          // widget.email.attachments.isNotEmpty
          //     ? Container(
          //         height: 96,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(8.0),
          //           image: DecorationImage(
          //             fit: BoxFit.cover,
          //             image: AssetImage(widget.email.attachments.first.url),
          //           ),
          //         ),
          //       )
          //     : const SizedBox.shrink(),
          // if (!widget.isPreview) ...[
          //   const EmailReplyOptions(),
          // ],
        ],
      ),
    );
  }
}

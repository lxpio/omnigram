import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omnigram/utils/l10n.dart';

import '../models/message.dart';

class ChatInput extends StatelessWidget {
  final bool? enabled;
  final Function()? onSubmitted;
  final Function()? onCommand;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;
  final FocusNode focusNode;

  final Message? quoteMessage;
  final VoidCallback? onCleared;

  const ChatInput({
    Key? key,
    required this.controller,
    this.onSubmitted,
    this.onCommand,
    this.onChanged,
    this.enabled,
    required this.focusNode,
    this.quoteMessage,
    this.onCleared,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 40,
        top: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            // padding: EdgeInsets.zero,
            onPressed: () {
              print('on attached file');
            },
            // color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.attach_file,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: quoteMessage == null
                ? _buildTextField(context)
                : Column(
                    children: [
                      _buildQuote(context),
                      const SizedBox(
                        height: 4,
                      ),
                      _buildTextField(context),
                    ],
                  ),
          ),
          const SizedBox(
            width: 8,
          ),
          IconButton(
            // padding: EdgeInsets.zero,
            onPressed: onSubmitted,
            // color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 4,
        bottom: 4,
        // left: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).unselectedWidgetColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 4,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              quoteMessage?.content.replaceAll('\n', '') ?? '',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            iconSize: 15,
            constraints: const BoxConstraints.tightFor(
              width: 32,
            ),
            onPressed: onCleared,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  TextField _buildTextField(BuildContext context) {
    return TextField(
      // key: textKey,
      enabled: enabled,
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      cursorColor: Theme.of(context).focusColor,
      textAlignVertical: TextAlignVertical.center,
      // textInputAction: TextInputAction.send,
      cursorRadius: const Radius.circular(5),
      maxLines: 10,
      minLines: 1,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: onCommand,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey, // Change the color here
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                  'assets/images/terminal.svg', // Replace with your SVG file path
                  width: 20,
                  height: 20),
            ),
          ),
        ), // Add the icon here
        border: InputBorder.none,
        isCollapsed: true,
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSecondary,
        // hintText: 'typing_a_message',
        hintText: context.l10n.type_message_placeholder,
        contentPadding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }
}

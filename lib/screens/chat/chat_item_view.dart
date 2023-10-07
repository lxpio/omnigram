import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/chat_base_item_view.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

import 'code_highlight_view.dart';

class ChatItemView extends ChatBaseItemView {
  // const ChatItemView(this.message, {super.key});

  // final Message message;

  const ChatItemView({
    super.key,
    required super.message,
    super.onRetried,
    required super.onAvatarClicked,
    super.onQuoted,
  }) : super();

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MarkdownBody(
      data: message.content,
      selectable: true,
      builders: {
        'code': CodeElementBuilder(mode),
      },
      onTapLink: (text, href, title) {
        if (href == null) return;
        if (href.startsWith('http')) {
          launchUrlString(href);
        } else if (href.startsWith('/')) {
          context.go(href);
        }
      },
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final ThemeMode mode;

  CodeElementBuilder(this.mode);

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    return CodeHighlightView(
      code: element.textContent,
      language: language,
      theme: mode == ThemeMode.light ? atomOneLightTheme : atomOneDarkTheme,
      padding: const EdgeInsets.all(8),
    );
  }
}

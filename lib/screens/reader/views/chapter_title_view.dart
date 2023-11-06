import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub/models/chapter_view_value.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';

import 'package:flutter_html/flutter_html.dart';

class ChapterTitleView extends ConsumerWidget {
  const ChapterTitleView({
    required this.title,
    this.animationAlignment = Alignment.centerLeft,
    Key? key,
  }) : super(key: key);

  final String? title;
  final Alignment animationAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.15),
          end: const Offset(0, 0),
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) =>
          Stack(
        alignment: animationAlignment,
        children: <Widget>[
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: Text(
        title?.replaceAll('\n', '').trim() ?? '',
        textAlign: TextAlign.start,
      ),
    );
  }
}

class ChapterParaView extends ConsumerWidget {
  const ChapterParaView(
      {super.key, required this.controller, required this.index});

  final int index;
  final BookController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      controller.document.paragraphs[index].element.innerHtml;
    }
    return Column(
      children: <Widget>[
        if (controller.chapterDivider(index)) const Divider(),
        SelectionArea(
          child: Html(
            data: controller.document.paragraphs[index].element.outerHtml,
            onLinkTap: (href, _, __) => _onLinkPressed(href!),
            style: {
              'html': Style(
                padding: HtmlPaddings.only(
                  top: const EdgeInsets.symmetric(horizontal: 16).top,
                  right: const EdgeInsets.symmetric(horizontal: 16).right,
                  bottom: const EdgeInsets.symmetric(horizontal: 16).bottom,
                  left: const EdgeInsets.symmetric(horizontal: 16).left,
                ),
              ).merge(Style.fromTextStyle(const TextStyle(
                height: 1.25,
                fontSize: 16,
              ))),
            },
            extensions: [
              TagExtension(
                tagsToExtend: {"img"},
                builder: (imageContext) {
                  final url =
                      imageContext.attributes['src']!.replaceAll('../', '');
                  final content = Uint8List.fromList(
                      controller.content!.Images![url]!.Content!);
                  return Image(
                    image: MemoryImage(content),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onLinkPressed(String href) {
    if (href.contains('://')) {
      // widget.onExternalLinkPressed?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    if (kDebugMode) {
      print('current href: $href');
    }

    final cfi = controller.cfiParse(href);
    if (cfi != null) {
      _gotoEpubCfi(cfi);
    }
    return;
  }

  void _gotoEpubCfi(
    ChapterIndex? index, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    if (index == null) {
      return;
    }

    controller.itemScrollController?.scrollTo(
      index: controller.absParagraphIndex(index) ?? 0,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }
}

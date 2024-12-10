import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/models/epub/epub.dart';

import '../providers/book_controller.dart';

class ChapterParaView extends ConsumerWidget {
  const ChapterParaView({super.key, required this.controller, required this.index}) : super();
  final int index;
  final BookController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if (kDebugMode) {
    //   controller.document.paragraphs[index].element.innerHtml;
    // }
    return Column(
      children: <Widget>[
        if (controller.chapterDivider(index)) const Divider(),
        SelectionArea(
          child: Html(
            data: controller.document.paragraphs[index].element.outerHtml,
            onLinkTap: (href, _, __) => _onLinkPressed(ref, href!),
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
                  final url = imageContext.attributes['src']!.replaceAll('../', '');
                  final content = Uint8List.fromList(controller.content!.Images![url]!.Content!);
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

  void _onLinkPressed(WidgetRef ref, String href) {
    if (href.contains('://')) {
      // widget.onExternalLinkPressed?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    if (kDebugMode) {
      print('current href: $href');
    }

    final cfi = controller.document.cfiParse(href);
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
      index: controller.document.absParagraphIndex(index) ?? 0,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }
}

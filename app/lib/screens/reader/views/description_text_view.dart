import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DescriptionTextView extends HookConsumerWidget {
  const DescriptionTextView({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMore = useState(true);

    //splitting the text into two halves

    final (firstHalf, secondHalf) = _splitText(text, 300);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: secondHalf.isEmpty
          ? Text(
              (showMore.value ? firstHalf : (firstHalf + secondHalf))
                  .replaceAll(r'\n', '\n')
                  .replaceAll(r'\r', '')
                  .replaceAll(r"\'", "'"),
              style: TextStyle(
                fontSize: 16.0,
                // color: context.theme.textTheme.bodySmall!.color,
              ),
            )
          : Column(
              children: <Widget>[
                Text(
                  (showMore.value ? ('$firstHalf...') : (firstHalf + secondHalf))
                      .replaceAll(r'\n', '\n\n')
                      .replaceAll(r'\r', '')
                      .replaceAll(r"\'", "'"),
                  style: TextStyle(
                    fontSize: 16.0,
                    // color: context.theme.textTheme.bodySmall!.color,
                  ),
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        showMore.value ? 'show more' : 'show less',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
                    showMore.value = !showMore.value;
                  },
                ),
              ],
            ),
    );
  }

  (String, String) _splitText(String? text, int maxBytes) {
    if (text == null || text.isEmpty) {
      return ('', '');
    }

    String firstSegment = '';
    String secondSegment = '';
    int currentLength = 0;

    for (var rune in text.runes) {
      String char = String.fromCharCode(rune);
      int charBytes = utf8.encode(char).length;

      if (currentLength + charBytes > maxBytes) {
        // 如果超出最大字节限制，将剩余文本放入第二段
        secondSegment = text.substring(firstSegment.length);
        break;
      }

      firstSegment += char;
      currentLength += charBytes;
    }

    // 返回分割后的两段
    return (firstSegment, secondSegment);
  }
}

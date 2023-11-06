import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class EpubParaView extends HookConsumerWidget {
  const EpubParaView({super.key, required this.epubController});

  final BookController epubController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _itemScrollController = useState(ItemScrollController());

    return Container();
  }
}

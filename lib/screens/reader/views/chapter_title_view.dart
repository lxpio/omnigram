import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';

import 'package:omnigram/screens/reader/providers/book_controller.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';

import '../models/epub/epub.dart';

class ChapterTitleView extends ConsumerWidget {
  const ChapterTitleView({
    this.animationAlignment = Alignment.centerLeft,
    Key? key,
  }) : super(key: key);

  final Alignment animationAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectBookProvider.select((value) => value.index));

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
        index?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
        textAlign: TextAlign.start,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/reader/book_model.dart';
import 'package:omnigram/providers/service/reader/books.dart';
import 'package:omnigram/screens/home/book_group_view.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';

import 'book_card.dart';

class EpubIndexView extends StatefulHookConsumerWidget {
  const EpubIndexView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubIndexViewState();
}

class _EpubIndexViewState extends ConsumerState<EpubIndexView> {
  final ScrollController _controllerOne = ScrollController();

  @override
  Widget build(BuildContext context) {
    final booknav = ref.watch(booksProvider);

    return booknav.when(
      loading: () => const LinearProgressIndicator(),
      data: (nav) {
        return SafeArea(
          child: ListView(
            controller: _controllerOne,
            children: <Widget>[
              BookGroup(
                  context.l10n.keepreading, context.l10n.viewmore, nav.reading),
              BookGroup(
                  context.l10n.recentbooks, context.l10n.viewmore, nav.recent),
              BookGroup(
                  context.l10n.randombooks, context.l10n.viewmore, nav.random),
            ],
          ),
        );
      },
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
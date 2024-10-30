import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/screens/no_connection.dart';
import 'package:omnigram/screens/home/views/book_liked_group_view.dart';

class EpubIndexView extends StatefulHookConsumerWidget {
  const EpubIndexView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubIndexViewState();
}

class _EpubIndexViewState extends ConsumerState<EpubIndexView> {
  final ScrollController _controllerOne = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        controller: _controllerOne,
        children: <Widget>[
          BookGroup('keepreading'.tr(), 'viewmore'.tr(), BookQuery.readings),
          BookGroup('recentbooks'.tr(), 'viewmore'.tr(), BookQuery.recents),
          BookGroup('randombooks'.tr(), 'viewmore'.tr(), BookQuery.recents),
        ],
      ),
    );
  }
}

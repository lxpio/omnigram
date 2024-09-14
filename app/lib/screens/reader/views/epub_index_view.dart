import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/screens/no_connection.dart';

import 'package:omnigram/screens/reader/views/book_group_view.dart';

class EpubIndexView extends StatefulHookConsumerWidget {
  const EpubIndexView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubIndexViewState();
}

class _EpubIndexViewState extends ConsumerState<EpubIndexView> {
  final ScrollController _controllerOne = ScrollController();

  @override
  Widget build(BuildContext context) {
    final booknav = ref.watch(bookProvider);

    return booknav.when(
      loading: () => const LinearProgressIndicator(),
      data: (nav) {
        return SafeArea(
          child: ListView(
            controller: _controllerOne,
            children: <Widget>[
              BookGroup(
                  'keepreading'.tr(), 'viewmore'.tr(), nav.readings),
              BookGroup(
                  'recentbooks'.tr(), 'viewmore'.tr(), nav.recents),
              BookGroup(
                  'randombooks'.tr(), 'viewmore'.tr(), nav.randoms),
            ],
          ),
        );
      },
      error: (err, stack) {
        if (err is DioException &&
            (err.type == DioExceptionType.connectionTimeout ||
                err.type == DioExceptionType.connectionError)) {
          // 处理连接超时或接收超时
          // print('Timeout Error: ${err.message}');
          return NoConnectionScreen(onRefresh: () async {
            await ref.read(bookProvider.notifier).refresh(10);
          });
        } else {
          // 处理其他Dio错误
          // print('Dio Error: ${e.message}');

          return Text('Error: $err');
        }
      },
    );
  }
}

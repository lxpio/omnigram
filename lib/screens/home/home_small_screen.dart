import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/screens/no_connection.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:omnigram/utils/constants.dart';
import '../reader/providers/books.dart';
import '../reader/providers/tts_service.dart';
import '../reader/views/epub_index_view.dart';
import '../views/stackbar.dart';
import 'views/home_small_view.dart';

class HomeSmallScreen extends HookConsumerWidget {
  const HomeSmallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booknav = ref.watch(personBooksProvider);

    return booknav.when(
      loading: () => const LinearProgressIndicator(),
      data: (nav) {
        final ttsState = ref.watch(ttsServiceProvider);

        return Column(
          children: [
            Expanded(child: HomeSmallView(nav: nav)),
            if (ttsState.showbar) const StackbarWidget(),
          ],
        );
      },
      error: (err, stack) {
        if (err is DioException &&
            (err.type == DioExceptionType.connectionTimeout ||
                err.type == DioExceptionType.connectionError)) {
          // 处理连接超时或接收超时
          // print('Timeout Error: ${err.message}');
          return NoConnectionScreen(onRefresh: () async {
            await ref.read(booksProvider.notifier).refresh();
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

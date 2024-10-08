import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';

import 'package:omnigram/screens/no_connection.dart';


import '../reader/providers/tts_service.dart';
import '../views/stackbar.dart';
import 'views/home_small_view.dart';

class HomeSmallScreen extends HookConsumerWidget {
  const HomeSmallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booknav = ref.watch(bookProvider);

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
        if (err is DioException) {
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

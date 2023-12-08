import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../reader/providers/books.dart';
import '../reader/providers/tts_service.dart';
import '../reader/views/epub_index_view.dart';
import '../views/stackbar.dart';
import 'views/home_small_view.dart';

class HomeSmallScreen extends HookConsumerWidget {
  const HomeSmallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booknav = ref.watch(booksProvider);

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
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

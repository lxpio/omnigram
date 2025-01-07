import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/note/views/note_item_view.dart';
import 'package:omnigram/services/note.service.dart';

import 'package:omnigram/utils/constants.dart';

class NoteSmallScreen extends HookConsumerWidget {
  const NoteSmallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(noteServiceProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
            // ref.invalidate(bookSearchProvider(query));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('search'.tr()),
      ),
      body: NoteItemView(service: service),
    );
  }
}

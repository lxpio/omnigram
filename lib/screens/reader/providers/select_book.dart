import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book_model.dart';
import 'books.dart';

// part 'select_book.g.dart';

// final selectedBookProvider = Provider.autoDispose<Book>((ref) {
//   return Book(id: 1);
// });

final selectBookProvider =
    NotifierProvider<SelectBookProvider, Book>(SelectBookProvider.new);

// class AppConfigProvider extends Notifier<AppConfig> {

class SelectBookProvider extends Notifier<Book> {
  @override
  Book build() {
    print('SelectBook  -=-=-=-=-=-=***  build');
    return Book(id: 1);
  }

  Future<void> update(Book b) async {
    //if progress or chapterPos is null , try request backend to get
    if (b.progress == null || b.chapterPos == null) {
      final api = ref.read(bookAPIProvider);

      final data = await api.getReadProcess(b.id);

      if (data != null) {
        b.progress = (data["progress"] + 0.0);
        b.chapterPos = data["chapter_pos"];
      }
    }

    state = b;
  }

  void updateProcess(double progress, String chapterPos) {
    print('updateProcess ${state.id}');
    state.progress = progress;
    state.chapterPos = chapterPos;
  }

  Future<void> saveProcess(double progress, String? chapterPos) async {
    print('saveProcess todo handle error  ${state.id}');
    final api = ref.read(bookAPIProvider);
    await api.updateProcess(state.id, progress, chapterPos);

    state.progress = progress;
    state.chapterPos = chapterPos;
  }

  void updateLocalPath(String path) {
    // print('updateProcess');
    state.path = path;
  }
}

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book_model.dart';
import '../models/epub/epub.dart';
import '../models/epub_document.dart';
import 'books.dart';

part 'select_book.g.dart';

final selectBookProvider =
    NotifierProvider<SelectBookProvider, SelectBook>(SelectBookProvider.new);

class SelectBook {
  SelectBook({
    required this.book,
    this.progress = 0.0,
  });
  late BookModel? book;

  late ChapterIndex? index;
  double progress = 0;
}

class SelectBookProvider extends Notifier<SelectBook> {
  @override
  SelectBook build() {
    if (kDebugMode) {
      print('SelectBook init build');
    }

    return SelectBook(book: null);
  }

  Future<void> refresh({required BookModel book}) async {
    if (kDebugMode) {
      print(
          'refresh select book: ${book.hashCode} and ${state.book?.hashCode}');
    }

    if (book.hashCode == state.book?.hashCode) {
      return;
    }

    final updater = SelectBook(book: book, progress: book.progress ?? 0.0);
    updater.index = ChapterIndex.create(book.progressIndex);

    state = updater;

    if (kDebugMode) {
      print('refresh select book: ${book.id}');
    }
    // ref.notifyListeners();
  }

  void updateProgress(ChapterIndex index, double progress) {
    if (kDebugMode) {
      print(
          'updateProgress book: ${index.chapterIndex} - ${index.paragraphIndex} ');
    }
    state.progress = progress;
    state.index = index;
    ref.notifyListeners();
  }

  void updateIndex(ChapterIndex? current) {
    if (state.book == null || current == null) {
      return;
    }

    if (state.index == null ||
        current.chapterIndex != state.index!.chapterIndex ||
        (current.paragraphIndex - state.index!.paragraphIndex).abs() > 5) {
      print('updateProcess ${state.book?.id}');
      state.index = current;
      ref.notifyListeners();
    }
  }

  Future<void> saveProcess() async {
    if (state.book == null) {
      return;
    }

    print('saveProcess todo handle  ${state.book!.id}');
    final api = ref.read(bookAPIProvider);
    await api.updateProcess(
        state.book!.id, state.progress, state.index?.combined);
  }
}

@Riverpod(keepAlive: true)
Future<EpubDocument?> epubDocument(EpubDocumentRef ref) async {
  final selected = ref.watch(selectBookProvider.select((value) => value.book));

  if (selected == null || selected.path == null) {
    return null;
  }
  if (kDebugMode) {
    print('epubDocumentProvider init ${selected.path}');
  }
  final document = await EpubDocument.initialize(selected.path!);

  return document;
}

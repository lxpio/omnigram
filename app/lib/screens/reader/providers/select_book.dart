import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/epub/epub.dart';
import '../models/epub_document.dart';


part 'select_book.g.dart';

final selectBookProvider =
    NotifierProvider<SelectBookProvider, SelectBook>(SelectBookProvider.new);

class SelectBook {
  SelectBook({
    required this.book,
    this.progress = 0.0,
  });
  BookEntity? book;

  late ChapterIndex? index;
  double progress = 0;
}

class SelectBookProvider extends Notifier<SelectBook> {
  @override
  SelectBook build() {
    if (kDebugMode) {
      debugPrint('SelectBook init build');
    }

    return SelectBook(book: null);
  }

  Future<void> refresh({required BookEntity book}) async {
    if (kDebugMode) {
      debugPrint(
          'refresh select book: ${book.hashCode} and ${state.book?.hashCode}');
    }

    if (book.hashCode == state.book?.hashCode) {
      return;
    }

    final updater = SelectBook(book: book, progress: book.progress ?? 0.0);
    updater.index = ChapterIndex.create(book.progressIndex, book.paraPosition);

    state = updater;

    if (kDebugMode) {
      debugPrint('refresh select book: ${book.id}');
    }
    // ref.notifyListeners();
  }

  void updateProgress(ChapterIndex index, double progress) {

    if (kDebugMode) {
      debugPrint(
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
      debugPrint('updateProcess ${state.book?.id}');
      state.index = current;
      ref.notifyListeners();
    }
  }

  Future<void> saveProcess(int? position) async {
    if (state.book == null) {
      return;
    }

    debugPrint('saveProcess todo handle  ${state.book!.id}');


    final bk = state.book!.copyWith(progress: state.progress, progressIndex: state.index?.chapterIndex, paraPosition: position);;




    final db = ref.read(dbProvider);
    db.bookEntitys.put(bk);

    
  }
}

@Riverpod(keepAlive: true)
Future<EpubDocument?> epubDocument(EpubDocumentRef ref) async {
  final selected = ref.watch(selectBookProvider.select((value) => value.book));

  if (selected == null || selected.localPath == null) {
    return null;
  }
  if (kDebugMode) {
    print('epubDocumentProvider init ${selected.localPath}');
  }
  final document = await EpubDocument.initialize(selected.id, selected.localPath!);

  return document;
}

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown/markdown.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book_model.dart';
import '../models/epub/epub.dart';
import '../models/epub_document.dart';
import 'books.dart';

part 'select_book.g.dart';

final selectBookProvider =
    NotifierProvider<SelectBookProvider, SelectBook>(SelectBookProvider.new);

class SelectBook {
  SelectBook({required this.book, required this.playing});
  late BookModel? book;

  bool playing = false;
  // late EpubDocument? document;
  late ChapterIndex? index;
}

class SelectBookProvider extends Notifier<SelectBook> {
  @override
  SelectBook build() {
    if (kDebugMode) {
      print('SelectBook  -=-=-=-=-=-=***  build');
    }
    return SelectBook(book: null, playing: false);
  }

  Future<void> refresh(BookModel b) async {
    if (kDebugMode) {
      print('refresh select book: ${b.id}');
    }
    //if progress or chapterPos is null , try request backend to get
    if (b.progress == null || b.chapterPos == null) {
      final api = ref.read(bookAPIProvider);

      final data = await api.getReadProcess(b.id);

      if (data != null) {
        state = SelectBook(
            book: b.copyWith(
                progress: (data["progress"] + 0.0),
                chapterPos: data["chapter_pos"]),
            playing: state.playing);
      }
      return;
    }
    // final index = document.cfiParse(b.chapterPos);
    state = SelectBook(book: null, playing: false);
    //fresh bookDocument;
  }

  void close() {
    state = SelectBook(book: null, playing: false);
  }

  void play() {
    if (state.book == null) {
      return;
    }

    state.playing = true;

    ref.notifyListeners();
  }

  void pause() {
    if (state.book == null) {
      return;
    }
    state.playing = false;

    ref.notifyListeners();
  }

  void updatePath(String? localPath) {
    if (state.book == null) {
      return;
    }
    print('updateProcess ${state.book?.id}');

    state.book = state.book!.copyWith(path: localPath);
    ref.notifyListeners();
  }

  void updateIndex(ChapterIndex? current, bool manual) {
    if (state.book == null || current == null) {
      return;
    }
    final diff = manual ? 5 : 0;
    if (manual && state.playing) {
      return;
    }

    print('in updateProcess ${state.book?.id}');

    if (state.index == null ||
        current.chapterIndex != state.index!.chapterIndex ||
        (current.paragraphIndex - state.index!.paragraphIndex).abs() > diff) {
      print('updateProcess ${state.book?.id}');
      state.index = current;
      ref.notifyListeners();
    }
  }
}

@Riverpod(keepAlive: true)
Future<EpubDocument?> epubDocument(EpubDocumentRef ref) async {
  final selected = ref.watch(selectBookProvider.select((value) => value.book));

  if (selected == null || selected.path == null) {
    return null;
  }
  if (kDebugMode) {
    print('epubDocumentProvider  -=-=-=-=-=-=***  ${selected.path}');
  }
  final document = await EpubDocument.initialize(selected.path!);

  final index = document.cfiParse(selected.chapterPos);

  ref.read(selectBookProvider).index = index;

  return document;
}

// @Riverpod(keepAlive: true)
// class BookDocument extends _$BookDocument {
//   @override
//   Future<EpubDocument?> build() async {
//     if (kDebugMode) {
//       print('SelectBook  -=-=-=-=-=-=***  initialize');
//     }
//     final selected = ref.watch(selectBookProvider);

//     if (selected.book == null || selected.book!.path == null) {
//       return null;
//     }

//     final document = await EpubDocument.initialize(selected.book!.path!);

//     return document;
//   }

//   Future<void> refresh(BookModel b) async {
//     if (kDebugMode) {
//       print('SelectBook  -=-=-=-=-=-=***  initialize');
//     }
//     final selected = ref.watch(selectBookProvider);

//     if (selected.book == null || selected.book!.path == null) {
//       return null;
//     }

//     final document = await EpubDocument.initialize(selected.book!.path!);

//     return document;
//   }

//   void updateIndex(ChapterIndex? current) {
//     final selected = ref.watch(selectBookProvider.notifier);
//     selected.updateIndex(current);
//   }

//   Future<void> saveProcess() async {
//     //   final index = document.cfiParse(chapterPos);
//     final selected = ref.watch(selectBookProvider);

//     if (selected.book == null || state.value == null) {
//       return;
//     }

//     final cfi = state.value!.cfiGenerate(selected.index);
//     final progress = state.value!.progress(selected.index);

//     print('saveProcess todo handle error  ${selected.book!.id}');
//     final api = ref.read(bookAPIProvider);
//     await api.updateProcess(selected.book!.id, progress, cfi);
//   }
//   // Add methods to mutate the state
// }
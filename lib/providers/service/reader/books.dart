import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/app_config.dart';
import 'package:omnigram/models/model.dart';
import 'package:omnigram/providers/service/api_service.dart';
import 'package:omnigram/utils/constants.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'book_model.dart';
// part 'books.g.dart';

class BookNav {
  final List<Book> recent = [];
  final List<Book> random = [];
  final List<Book> pop = [];
}

// @riverpod
// class Books extends _$Books {
//   late final APIService _service;

//   @override
//   Future<BookNav> build() async {
//     final baseUrl = (ref.watch(appConfigProvider).bookBaseUrl);

//     _service = ref.watch(bookAPIServiceProvider);

//     final ApiResponse<BookNav> result =
//         await _service.request('GET', "/reader/nav/books");

//     if (result.code == 0) {
//       return result.data!;
//     } else {
//       throw Exception(result.message);
//     }
//   }

//   Future<void> freshRandom() async {
//     // await http.post(
//     //   Uri.https('your_api.com', '/todos'),
//     //   // We serialize our Todo object and POST it to the server.
//     //   headers: {'Content-Type': 'application/json'},
//     //   body: jsonEncode(todo.toJson()),
//     // );

//     // final previousState = await future;

//     ref.notifyListeners();

//     // await future;
//   }
// }

// @riverpod
// Future<Book> getBook(GetBookRef ref, int id) async {
//   final box = AppStore.instance.box<Book>();

//   final book = box.get(id);

//   if (book != null) {
//     return book;
//   }

//   //from objectbox to get book
//   final bookApi = ref.watch(bookAPIServiceProvider);

//   final resp = await bookApi.request<Book>('GET', "/books/$id");

//   if (resp.code == 200) {
//     return resp.data!;
//   }

//   throw Exception(resp.message);
// }

final bookAPIProvider = Provider(BookAPI.new);

class BookAPI {
  BookAPI(this.ref);

  final Ref ref;

  Future<Book> getBook(int id) async {
    final box = AppStore.instance.box<Book>();

    final book = box.get(id);

    if (book != null) {
      return book;
    }

    //from objectbox to get book
    final bookApi = ref.read(bookAPIServiceProvider);

    final resp = await bookApi.request<Book>('GET', "/books/$id");

    if (resp.code == 200) {
      return resp.data!;
    }

    throw Exception(resp.message);
  }

  //Download book
  Future<void> downloadBook(int id) async {
    final bookApi = ref.read(bookAPIServiceProvider);
    await bookApi.downloadFile(
      "/books/$id/download",
      "$globalEpubPath/$id.pdf",
    );
  }
}

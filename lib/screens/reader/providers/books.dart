import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/app_store.dart';
import 'package:omnigram/providers/service/api_service.dart';
import 'package:omnigram/providers/service/provider.dart';
import 'package:omnigram/screens/reader/models/epub/epub.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book_model.dart';
part 'books.g.dart';
part 'books.freezed.dart';

@freezed
class BookNav with _$BookNav {
  const factory BookNav({
    List<BookModel>? recent,
    List<BookModel>? random,
    List<BookModel>? reading,
  }) = _BookNav;

  factory BookNav.fromJson(Map<String, Object?> json) =>
      _$BookNavFromJson(json);
}

@freezed
class BookSearch with _$BookSearch {
  const factory BookSearch({
    String? search,
    String? author,
    String? publisher,
    String? tags,
  }) = _BookSearch;

  factory BookSearch.fromJson(Map<String, Object?> json) =>
      _$BookSearchFromJson(json);
}

@riverpod
class Books extends _$Books {
  @override
  Future<BookNav> build() async {
    final bookApi = ref.watch(apiServiceProvider);

    final args = ref.watch(bookIndexSearchProvider);

    final ApiResponse<BookNav> result = await bookApi.request(
        'GET', "/book/index",
        body: args.toJson(), fromJsonT: BookNav.fromJson);

    if (result.code == 200) {
      return result.data!;
    } else {
      throw Exception(result.message);
    }
  }
}

final bookIndexSearchProvider = Provider.autoDispose<BookSearch>((ref) {
  return const BookSearch();
});

final bookAPIProvider = Provider(BookAPI.new);

class BookAPI {
  BookAPI(this.ref);

  final Ref ref;

  Future<BookModel> getBook(int id) async {
    final box = AppStore.instance.box<BookModel>();

    final book = box.get(id);

    if (book != null) {
      return book;
    }

    //from objectbox to get book
    final bookApi = ref.read(apiServiceProvider);

    final resp = await bookApi.request<BookModel>('GET', "/books/$id");

    if (resp.code == 200) {
      return resp.data!;
    }

    throw Exception(resp.message);
  }

  //Download book
  Future<String> downloadBook(
    int id,
    ProgressCallback? onDownloadProgress,
  ) async {
    final bookApi = ref.read(apiServiceProvider);
    await bookApi.download(
      "/book/download/books/$id",
      "$globalEpubPath/$id.epub",
      onDownloadProgress: onDownloadProgress,
    );

    return "$globalEpubPath/$id.epub";
  }

  Future<ApiResponse> updateProcess(
      int id, double progress, ChapterIndex? index) async {
    final bookApi = ref.read(apiServiceProvider);

    try {
      return await bookApi.request(
        "PUT",
        "/book/read/books/$id",
        body: {
          "progress": progress,
          "progress_index": index?.combined,
          "para_position": index?.position,
        },
        // onDownloadProgress: onDownloadProgress,
      );
    } catch (e) {
      //TODO
      print(e);
    }

    return ApiResponse(code: 400, message: "error");
  }

  Future<Map<String, dynamic>?> getReadProcess(int id) async {
    final bookApi = ref.read(apiServiceProvider);

    try {
      final resp = await bookApi.request(
        "GET",
        "/book/read/books/$id",
      );

      if (resp.code == 200) {
        return resp.data as Map<String, dynamic>;
      }
    } catch (e) {
      //TODO
      print(e);
    }

    return null;
  }
}

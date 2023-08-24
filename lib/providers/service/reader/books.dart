import 'package:dio/dio.dart';
import 'package:omnigram/flavors/app_config.dart';
import 'package:omnigram/providers/service/api_service.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'book_model.dart';
part 'books.g.dart';

class BookNav {
  final List<Book> recent = [];
  final List<Book> random = [];
  final List<Book> pop = [];
}

@riverpod
class Books extends _$Books {
  late final APIService _service;

  @override
  Future<BookNav> build() async {
    final baseUrl = (ref.watch(appConfigProvider).bookBaseUrl);

    _service = APIService.singleton.build(baseUrl: baseUrl);

    final ApiResponse<BookNav> result =
        await _service.request('GET', "/reader/nav/books");

    if (result.code == 0) {
      return result.data!;
    } else {
      throw Exception(result.message);
    }
  }

  Future<void> freshRandom() async {
    // await http.post(
    //   Uri.https('your_api.com', '/todos'),
    //   // We serialize our Todo object and POST it to the server.
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(todo.toJson()),
    // );

    // final previousState = await future;

    ref.notifyListeners();

    // await future;
  }
}

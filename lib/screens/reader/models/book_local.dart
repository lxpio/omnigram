import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:omnigram/flavors/app_store.dart';

part 'book_local.freezed.dart';
part 'book_local.g.dart';

@freezed
class BookLocal with _$BookLocal {
  @Entity(realClass: BookLocal)
  factory BookLocal({
    @Id(assignable: true) required int id,
    @JsonKey(name: 'local_path') required String localPath,
    @JsonKey(name: 'md5') String? md5,
  }) = _BookLocal;

  factory BookLocal.fromJson(Map<String, dynamic> json) =>
      _$BookLocalFromJson(json);
}

// BookLocal get(int bookId) {

//   final bookLocal = Box<BookLocal>()
//       .query()
//       .equal(BookLocal_.bookId, bookId)
//       .build()
//       .findFirst();
//   return bookLocal!;
//   return Box<BookLocal>().get(bookId);
// }

class BookLocalBox {
  late final Box<BookLocal> _box;

  BookLocalBox._internal() : _box = AppStore.instance.box<BookLocal>();
  static final instance = BookLocalBox._internal();

  // BookLocalBox() : _box = AppStore.instance.box<BookLocal>();

  BookLocal? get(int bookId) {
    return _box.get(bookId);
  }

  int create(int bookId, String path) {
    return _box.put(BookLocal(id: bookId, localPath: path));
  }
}

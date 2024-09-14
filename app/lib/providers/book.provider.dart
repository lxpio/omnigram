import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:omnigram/services/book.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'book.provider.g.dart';

@riverpod
class Book extends _$Book {
  @override
  Future<BookNav> build() {


    final service = BookService(ref.watch(dbProvider), ref.watch(apiServiceProvider.notifier));

    return service.getNavBook( 10);
    
  }

  Future<void> refresh(int limit) async {
    state = const AsyncValue.loading();
    final service = BookService(ref.watch(dbProvider), ref.watch(apiServiceProvider.notifier));
    
    state = await AsyncValue.guard(() => service.getNavBook(limit));
    // return service.getNavBook(id);
  }



}


// BookService bookService(BookServiceRef ref) {

//   return BookService(
//    ref.watch(dbProvider),
//    ref.watch(apiServiceProvider.notifier),
//   );

// }


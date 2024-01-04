import 'dart:convert';

import 'package:omnigram/screens/reader/models/book_model.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';

import 'package:test/test.dart';

void main() {
  test('simple get should be created', () async {
    const data =
        '{"id":1,"identifier":"tsts","author":"ttt","book_id":682,"title":"test","user_id":1,"progress":2.3033707,"start_date":1700202334,"updated_at":1700549503,"expt_end_date":1701498334,"end_date":0,"chapter_pos":"/text00002.html?12"}';

// factory LLMService.fromRawJson(String str) =>
//       LLMService.fromJson(json.decode(str));
    final book = BookModel.fromJson(json.decode(data));

    expect(book.id, 1);
    // expect(book.chapterPos, "/text00002.html?12");
  });

  test('open epub doc', () async {
// factory LLMService.fromRawJson(String str) =>
//       LLMService.fromJson(json.decode(str));
    final doc = await EpubDocument.initialize(
        1, '/Workspace/flutter_epub/example/assets/test.epub');

    expect(doc.chapters.length, 1);
    // expect(book.chapterPos, "/text00002.html?12");
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';

void main() {
  group('splitSentences — basics', () {
    test('empty input → empty', () {
      expect(splitSentences(''), isEmpty);
      expect(splitSentences('   \n  '), isEmpty);
    });

    test('single sentence', () {
      final r = splitSentences('Hello world.');
      expect(r, hasLength(1));
      expect(r.first.text, 'Hello world.');
      expect(r.first.charOffset, 0);
    });

    test('multiple English sentences', () {
      final r = splitSentences('First one. Second one! Third?');
      expect(r.map((s) => s.text), ['First one.', 'Second one!', 'Third?']);
      expect(r[0].charOffset, 0);
      expect(r[1].charOffset, 11);
      expect(r[2].charOffset, 23);
    });

    test('Chinese sentences (long enough not to merge)', () {
      final r = splitSentences('今天天气真好。我们去公园玩吧！你觉得呢？');
      expect(r.map((s) => s.text), ['今天天气真好。', '我们去公园玩吧！', '你觉得呢？']);
    });

    test('short CJK fragments merge per minChars default', () {
      final r = splitSentences('你好。世界！再见？');
      // All three are 3-char which is < minChars=4. They merge into one.
      expect(r, hasLength(1));
    });

    test('decimal point not a sentence end', () {
      final r = splitSentences('Pi is 3.14 approximately.');
      expect(r, hasLength(1));
      expect(r.first.text, 'Pi is 3.14 approximately.');
    });

    test('abbreviations not sentence ends', () {
      final r = splitSentences('Mr. Smith went home. He was tired.');
      expect(r, hasLength(2));
      expect(r[0].text, 'Mr. Smith went home.');
      expect(r[1].text, 'He was tired.');
    });

    test('closing marks attach to sentence', () {
      final r = splitSentences('"Hello." She smiled.');
      expect(r.map((s) => s.text), ['"Hello."', 'She smiled.']);
    });

    test('paragraph break is hard boundary', () {
      final r = splitSentences('First.\n\nSecond.');
      expect(r, hasLength(2));
      expect(r[0].text, 'First.');
      expect(r[1].text, 'Second.');
    });
  });

  group('splitSentences — merge-short', () {
    test('numeric bullet merged into next', () {
      final r = splitSentences('1. The first real sentence here.');
      expect(r, hasLength(1));
      expect(r.first.text, '1. The first real sentence here.');
    });

    test('short fragment merged into previous', () {
      // "OK." is 3 chars (< 4) and follows a real sentence.
      final r = splitSentences('This is a real sentence. OK.');
      expect(r, hasLength(1));
      expect(r.first.text.contains('OK.'), isTrue);
    });
  });

  group('splitSentences — split-long', () {
    test('splits at clause boundaries past maxChars', () {
      // Build a long sentence with commas at clause boundaries.
      final long = '${'aaaa, ' * 60}done.';
      final r = splitSentences(long, const Splitter(minChars: 0, maxChars: 50));
      expect(r.length, greaterThan(1));
      for (final s in r) {
        // Each piece should be <= roughly maxChars (clause-aware splitting may
        // overshoot slightly because we accumulate until >= maxChars/2).
        expect(s.text.runes.length, lessThanOrEqualTo(80));
      }
    });
  });

  group('splitSentences — char offsets', () {
    test('offsets are monotonic and within bounds', () {
      const text =
          'First sentence here. Second one follows! Third?\n\nFourth in new para.';
      final r = splitSentences(text);
      var prev = -1;
      for (final s in r) {
        expect(s.charOffset, greaterThan(prev));
        expect(s.charOffset, lessThan(text.runes.length));
        prev = s.charOffset;
      }
    });
  });
}

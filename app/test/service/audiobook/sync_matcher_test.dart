import 'package:flutter_test/flutter_test.dart';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/audiobook/sync_matcher.dart';

SentenceAlignment _s(int index, int start, int end, [String text = '']) =>
    SentenceAlignment(index: index, text: text, startMs: start, endMs: end);

void main() {
  group('findSentenceForTime', () {
    final fixture = [
      _s(0, 0, 1000, 'a'),
      _s(1, 1000, 2500, 'b'),
      _s(2, 2500, 3000, 'c'),
    ];

    test('empty → -1', () {
      expect(findSentenceForTime(const [], 100), -1);
    });

    test('hit within span', () {
      expect(findSentenceForTime(fixture, 0), 0);
      expect(findSentenceForTime(fixture, 999), 0);
      expect(findSentenceForTime(fixture, 1000), 1);
      expect(findSentenceForTime(fixture, 2499), 1);
      expect(findSentenceForTime(fixture, 2500), 2);
      expect(findSentenceForTime(fixture, 2999), 2);
    });

    test('past end clamps to last', () {
      expect(findSentenceForTime(fixture, 3000), 2);
      expect(findSentenceForTime(fixture, 99999), 2);
    });

    test('before start clamps to first', () {
      expect(findSentenceForTime(fixture, -500), 0);
    });
  });

  group('normaliseForMatch', () {
    test('strips punctuation and whitespace', () {
      expect(normaliseForMatch('Hello, World!'), 'helloworld');
      expect(normaliseForMatch('  spaced  out  '), 'spacedout');
    });

    test('keeps Chinese chars, strips CJK punct', () {
      expect(normaliseForMatch('真的吗？"他问。'), '真的吗他问');
    });

    test('case-insensitive ASCII', () {
      expect(normaliseForMatch('CamelCase'), 'camelcase');
    });
  });

  group('bigramSimilarity', () {
    test('identical → 1', () {
      expect(bigramSimilarity('hello world', 'hello world'), 1);
    });

    test('empty → 0', () {
      expect(bigramSimilarity('', 'anything'), 0);
      expect(bigramSimilarity('anything', ''), 0);
    });

    test('disjoint → 0', () {
      expect(bigramSimilarity('abcdef', 'xyzuvw'), 0);
    });

    test('minor difference → high score', () {
      final score = bigramSimilarity(
        normaliseForMatch('余华出生于杭州。'),
        normaliseForMatch('余华出生于杭州'),
      );
      expect(score, greaterThan(0.8));
    });

    test('short strings use containment heuristic', () {
      expect(bigramSimilarity('abc', 'abc'), 1);
      expect(bigramSimilarity('ab', 'abcd'), 0.9);
      expect(bigramSimilarity('xy', 'ab'), 0);
    });
  });
}

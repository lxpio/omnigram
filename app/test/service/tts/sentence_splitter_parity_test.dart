import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';

/// Parity test against `server/service/tts/testdata/splitter_parity.json`.
///
/// Both the Go splitter and this Dart port load the same fixture; if either
/// side changes the algorithm both tests must update in lockstep. That's
/// what keeps pre-gen alignment indices line up with client-side sentences.
void main() {
  test('splitter output matches Go fixture', () async {
    final fixtureFile = File('../server/service/tts/testdata/splitter_parity.json');
    expect(
      fixtureFile.existsSync(),
      isTrue,
      reason: 'fixture not found at ${fixtureFile.absolute.path}',
    );

    final raw = jsonDecode(await fixtureFile.readAsString()) as Map<String, dynamic>;
    final cases = raw['cases'] as List<dynamic>;
    expect(cases, isNotEmpty);

    for (final c in cases) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final input = m['input'] as String;
      final splitterJson = m['splitter'] as Map<String, dynamic>?;
      final splitter = Splitter(
        lang: (splitterJson?['lang'] as String?) ?? '',
        minChars: (splitterJson?['minChars'] as int?) ?? 4,
        maxChars: (splitterJson?['maxChars'] as int?) ?? 200,
      );
      final expected = (m['expected'] as List<dynamic>)
          .map((e) => Sentence(
                text: (e as Map<String, dynamic>)['text'] as String,
                charOffset: e['charOffset'] as int,
              ))
          .toList();

      final got = splitSentences(input, splitter);
      expect(
        got.length,
        expected.length,
        reason: 'case "$name" length mismatch — got: $got',
      );
      for (var i = 0; i < expected.length; i++) {
        expect(got[i].text, expected[i].text, reason: 'case "$name" sent $i text');
        expect(got[i].charOffset, expected[i].charOffset,
            reason: 'case "$name" sent $i charOffset');
      }
    }
  });
}

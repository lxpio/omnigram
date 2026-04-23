import 'package:omnigram/models/server/server_tts.dart';

/// Pure-function primitives backing AudiobookSyncController.
///
/// Kept in their own file so they're unit-testable without mocking an
/// AudioPlayer or a WebView. No imports of Flutter or platform code here.

/// Find the sentence whose [startMs, endMs) interval contains [ms].
/// Returns the last sentence when [ms] is past the end; the first when
/// before the start. Returns -1 only for an empty list.
int findSentenceForTime(List<SentenceAlignment> sentences, int ms) {
  if (sentences.isEmpty) return -1;
  var lo = 0;
  var hi = sentences.length - 1;
  while (lo <= hi) {
    final mid = (lo + hi) >> 1;
    final s = sentences[mid];
    if (ms < s.startMs) {
      hi = mid - 1;
    } else if (ms >= s.endMs) {
      lo = mid + 1;
    } else {
      return mid;
    }
  }
  if (lo >= sentences.length) return sentences.length - 1;
  if (hi < 0) return 0;
  return lo;
}

/// Normalise text for fuzzy comparison: strip whitespace + punctuation
/// (ASCII + CJK ranges), lower-case ASCII letters. Keeps Chinese characters
/// intact. Used to compare server's SplitSentences output against foliate-js
/// output which may differ in quote/punctuation handling.
String normaliseForMatch(String text) {
  final buf = StringBuffer();
  for (final r in text.runes) {
    if (r == 0x20 || r == 0x09 || r == 0x0A || r == 0x0D) continue;
    if ((r >= 0x21 && r <= 0x2F) ||
        (r >= 0x3A && r <= 0x40) ||
        (r >= 0x5B && r <= 0x60) ||
        (r >= 0x7B && r <= 0x7E) ||
        (r >= 0x3000 && r <= 0x303F) ||
        (r >= 0xFF00 && r <= 0xFFEF)) {
      continue;
    }
    if (r >= 0x41 && r <= 0x5A) {
      buf.writeCharCode(r + 0x20);
    } else {
      buf.writeCharCode(r);
    }
  }
  return buf.toString();
}

/// Jaccard similarity on character bigrams — 0.0 for disjoint, 1.0 for
/// identical, robust to minor noise. Good enough for "is this the same
/// sentence" when punctuation or leading whitespace differs.
double bigramSimilarity(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  if (a == b) return 1;
  if (a.length < 4 || b.length < 4) {
    if (a.contains(b) || b.contains(a)) return 0.9;
    return 0;
  }
  final setA = _bigrams(a);
  final setB = _bigrams(b);
  final intersect = setA.intersection(setB).length;
  final union = setA.union(setB).length;
  return union == 0 ? 0 : intersect / union;
}

Set<String> _bigrams(String s) {
  final out = <String>{};
  for (var i = 0; i + 1 < s.length; i++) {
    out.add(s.substring(i, i + 2));
  }
  return out;
}

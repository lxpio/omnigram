/// Sentence splitter — Dart port of `server/service/tts/sentence_splitter.go`.
///
/// Both sides MUST stay in lock-step so that pre-gen alignment indices line up
/// with the client's sentence list. See `test/service/tts/sentence_splitter_test.dart`
/// for the parity fixtures.
library;

class Sentence {
  const Sentence({required this.text, required this.charOffset});
  final String text;
  final int charOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sentence && other.text == text && other.charOffset == charOffset);

  @override
  int get hashCode => Object.hash(text, charOffset);

  @override
  String toString() => 'Sentence(@$charOffset, ${text.length}c: "${text.length > 30 ? '${text.substring(0, 30)}…' : text}")';
}

class Splitter {
  const Splitter({this.lang = '', this.minChars = 4, this.maxChars = 200});
  final String lang;
  final int minChars;
  final int maxChars;
}

const _defaultSplitter = Splitter();

/// Split [text] into sentences. Mirrors Go `SplitSentences`.
List<Sentence> splitSentences(String text, [Splitter splitter = _defaultSplitter]) {
  var s = splitter;
  if (s.minChars < 0) s = Splitter(lang: s.lang, minChars: 0, maxChars: s.maxChars);
  if (s.maxChars <= 0) s = Splitter(lang: s.lang, minChars: s.minChars, maxChars: 200);

  final trimmed = text.replaceFirst(RegExp(r'[ \t\n\r]+$'), '');
  if (trimmed.isEmpty) return const [];

  final raw = _splitWithOffsets(trimmed);
  if (raw.isEmpty) return const [];

  // Merge-short.
  final merged = <Sentence>[];
  Sentence? pending;
  for (final sent in raw) {
    final runeCount = sent.text.runes.length;
    if (runeCount < s.minChars) {
      if (merged.isNotEmpty) {
        final prev = merged.removeLast();
        merged.add(Sentence(text: '${prev.text} ${sent.text}', charOffset: prev.charOffset));
        continue;
      }
      if (pending == null) {
        pending = sent;
      } else {
        pending = Sentence(text: '${pending.text} ${sent.text}', charOffset: pending.charOffset);
      }
      continue;
    }
    if (pending != null) {
      merged.add(Sentence(text: '${pending.text} ${sent.text}', charOffset: pending.charOffset));
      pending = null;
    } else {
      merged.add(sent);
    }
  }
  if (pending != null) merged.add(pending);

  // Split-long.
  final out = <Sentence>[];
  for (final sent in merged) {
    if (sent.text.runes.length <= s.maxChars) {
      out.add(sent);
      continue;
    }
    out.addAll(_splitLongSentence(sent.text, sent.charOffset, s.maxChars));
  }
  return out;
}

List<Sentence> _splitWithOffsets(String text) {
  final result = <Sentence>[];
  final runes = text.runes.toList();
  var paragraphStart = 0;

  void flushParagraph(int paraStart, int paraEnd) {
    if (paraStart >= paraEnd) return;
    final para = runes.sublist(paraStart, paraEnd);
    var sentStart = 0;
    for (var i = 0; i < para.length; i++) {
      final r = para[i];
      if (!_isSentenceEnd(r)) continue;
      if (r == _dot) {
        if (_isAbbreviation(para, i) || _isDecimalPoint(para, i)) continue;
      }
      var end = i + 1;
      if (r == _dot) {
        while (end < para.length && para[end] == _dot) {
          end++;
        }
      }
      while (end < para.length && _isClosingMark(para[end])) {
        end++;
      }
      _emit(para, sentStart, end, paraStart, result);
      sentStart = end;
      i = end - 1;
    }
    if (sentStart < para.length) {
      _emit(para, sentStart, para.length, paraStart, result);
    }
  }

  for (var i = 0; i < runes.length; i++) {
    if (runes[i] == _newline && i + 1 < runes.length && runes[i + 1] == _newline) {
      flushParagraph(paragraphStart, i);
      var j = i + 2;
      while (j < runes.length && _isSpaceOrNewline(runes[j])) {
        j++;
      }
      paragraphStart = j;
      i = j - 1;
    }
  }
  flushParagraph(paragraphStart, runes.length);
  return result;
}

void _emit(List<int> para, int start, int end, int paraOffset, List<Sentence> out) {
  var lead = start;
  while (lead < end && _isSpace(para[lead])) {
    lead++;
  }
  var trail = end;
  while (trail > lead && _isSpace(para[trail - 1])) {
    trail--;
  }
  if (trail <= lead) return;
  out.add(Sentence(
    text: String.fromCharCodes(para.sublist(lead, trail)),
    charOffset: paraOffset + lead,
  ));
}

List<Sentence> _splitLongSentence(String text, int baseOffset, int maxChars) {
  final runes = text.runes.toList();
  final pieces = <Sentence>[];
  var targetMin = maxChars ~/ 2;
  if (targetMin < 20) targetMin = 20;

  var start = 0;
  for (var i = 0; i < runes.length; i++) {
    if (!_isClauseBoundary(runes[i])) continue;
    final end = i + 1;
    final currentLen = end - start;
    if (currentLen >= targetMin) {
      _emitPiece(runes, start, end, baseOffset, pieces);
      start = end;
      i = end - 1;
    }
  }
  if (start < runes.length) {
    final remainingLen = runes.length - start;
    if (remainingLen > maxChars) {
      var cursor = start;
      while (cursor < runes.length) {
        final end = (cursor + maxChars).clamp(0, runes.length);
        _emitPiece(runes.sublist(cursor), 0, end - cursor, baseOffset + cursor, pieces);
        cursor = end;
      }
    } else {
      _emitPiece(runes, start, runes.length, baseOffset, pieces);
    }
  }
  if (pieces.isEmpty) {
    pieces.add(Sentence(text: text, charOffset: baseOffset));
  }
  return pieces;
}

void _emitPiece(List<int> runes, int start, int end, int baseOffset, List<Sentence> out) {
  var lead = start;
  while (lead < end && _isSpace(runes[lead])) {
    lead++;
  }
  var trail = end;
  while (trail > lead && _isSpace(runes[trail - 1])) {
    trail--;
  }
  if (trail <= lead) return;
  out.add(Sentence(
    text: String.fromCharCodes(runes.sublist(lead, trail)),
    charOffset: baseOffset + lead,
  ));
}

// ── Predicates / constants ─────────────────────────────────────────

const _dot = 0x2E; // '.'
const _newline = 0x0A;

bool _isSpace(int r) =>
    r == 0x20 || r == 0x09 || r == 0x0A || r == 0x0D || r == 0xA0;

bool _isSpaceOrNewline(int r) =>
    r == 0x0A || r == 0x20 || r == 0x09 || r == 0x0D;

bool _isSentenceEnd(int r) {
  return r == 0x2E || // .
      r == 0x21 || // !
      r == 0x3F || // ?
      r == 0x3002 || // 。
      r == 0xFF01 || // ！
      r == 0xFF1F || // ？
      r == 0x2026; // …
}

bool _isClosingMark(int r) {
  return r == 0x22 || // "
      r == 0x27 || // '
      r == 0x29 || // )
      r == 0x5D || // ]
      r == 0x201D || // ”
      r == 0x2019 || // ’
      r == 0x300D || // 」
      r == 0x300F || // 』
      r == 0x300B || // 》
      r == 0xFF09; // ）
}

bool _isClauseBoundary(int r) {
  return r == 0x2C || // ,
      r == 0x3B || // ;
      r == 0x3A || // :
      r == 0x3001 || // 、
      r == 0xFF0C || // ，
      r == 0xFF1B || // ；
      r == 0xFF1A || // ：
      r == 0x2014; // —
}

bool _isDigit(int r) => r >= 0x30 && r <= 0x39;

final _abbreviations = ['Mr.', 'Dr.', 'Mrs.', 'Jr.', 'Sr.', 'vs.']
    .map((s) => s.runes.toList(growable: false))
    .toList(growable: false);

bool _isAbbreviation(List<int> runes, int pos) {
  for (final abbr in _abbreviations) {
    final start = pos + 1 - abbr.length;
    if (start < 0) continue;
    var match = true;
    for (var k = 0; k < abbr.length; k++) {
      if (runes[start + k] != abbr[k]) {
        match = false;
        break;
      }
    }
    if (!match) continue;
    if (start == 0 || runes[start - 1] == 0x20 || runes[start - 1] == 0x0A) {
      return true;
    }
  }
  return false;
}

bool _isDecimalPoint(List<int> runes, int pos) {
  if (pos > 0 && pos < runes.length - 1) {
    return _isDigit(runes[pos - 1]) && _isDigit(runes[pos + 1]);
  }
  return false;
}

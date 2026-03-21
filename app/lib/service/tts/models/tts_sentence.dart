class TtsSentence {
  const TtsSentence({required this.text, this.cfi});

  final String text;
  final String? cfi;

  factory TtsSentence.fromMap(Map<dynamic, dynamic> data) {
    final text = data['text'];
    final cfi = data['cfi'];
    if (text is! String) {
      throw const FormatException('Missing TTS sentence text');
    }
    return TtsSentence(
      text: text,
      cfi: cfi is String && cfi.isNotEmpty ? cfi : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        if (cfi != null) 'cfi': cfi,
      };

  @override
  String toString() => 'TtsSentence(text: $text, cfi: $cfi)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TtsSentence && other.text == text && other.cfi == cfi;
  }

  @override
  int get hashCode => Object.hash(text, cfi);
}

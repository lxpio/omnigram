class BookNote {
  int? id;
  int bookId;
  String content;
  String cfi;
  String chapter;
  String type;
  String color;
  String? readerNote;
  DateTime? createTime;
  DateTime updateTime;

  void setId(int id) {
    this.id = id;
  }

  BookNote({
    this.id,
    required this.bookId,
    required this.content,
    required this.cfi,
    required this.chapter,
    required this.type,
    required this.color,
    this.readerNote,
    this.createTime,
    required this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'content': content,
      'cfi': cfi,
      'chapter': chapter,
      'type': type,
      'color': color,
      'reader_note': readerNote,
      'create_time': createTime?.toIso8601String(),
      'update_time': updateTime.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': content,
      'value': cfi,
      'type': type,
      'color': '#$color',
    };
  }

  factory BookNote.fromDb(Map<String, dynamic> map) {
    final createTimeString = map['create_time'] as String?;
    final updateTimeString = map['update_time'] as String?;

    return BookNote(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      content: map['content'] as String? ?? '',
      cfi: map['cfi'] as String? ?? '',
      chapter: map['chapter'] as String? ?? '',
      type: map['type'] as String? ?? '',
      color: map['color'] as String? ?? '',
      readerNote: map['reader_note'] as String?,
      createTime:
          createTimeString != null ? DateTime.tryParse(createTimeString) : null,
      updateTime: updateTimeString != null
          ? DateTime.parse(updateTimeString)
          : DateTime.now(),
    );
  }
}

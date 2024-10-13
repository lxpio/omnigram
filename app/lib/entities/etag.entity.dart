// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:isar/isar.dart';

part 'etag.entity.g.dart';

@Collection(inheritance: false)
class ETag {
  ETag({
    required this.id,

    this.bookCount,
    required this.utime,
  });

  @Id()
  final int id;

  final int? bookCount;

  //本地存储文件路径
  final int utime;


  ETag copyWith({
    int? id,
    int? bookCount,
    int? utime,
  }) {
    return ETag(
      id: id ?? this.id,
      bookCount: bookCount ?? this.bookCount,
      utime: utime ?? this.utime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bookCount': bookCount,
      'utime': utime,
    };
  }

  factory ETag.fromMap(Map<String, dynamic> map) {
    return ETag(
      id: map['id'] as int,
      bookCount: map['bookCount'] != null ? map['bookCount'] as int : null,
      utime: map['utime'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ETag.fromJson(String source) => ETag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ETag(id: $id, bookCount: $bookCount, utime: $utime)';

  @override
  bool operator ==(covariant ETag other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.bookCount == bookCount &&
      other.utime == utime;
  }

  @override
  int get hashCode => id.hashCode ^ bookCount.hashCode ^ utime.hashCode;
}

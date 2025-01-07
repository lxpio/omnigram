// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

part 'note.entity.g.dart';

@Collection(inheritance: false)
class NoteEntity {
  @Id()
  final int id;

  @Index(unique: false)
  final String? remoteId;

  final String title;
  //本地存储文件路径
  final String? localPath;

  final int? parentId;

  final String levelPath;

  final int priority;

  final bool shouldRenderChildren;

  final bool isHoverEnabled;

  final int? ctime;

  final int? utime;

  @Ignore()
  get parents => levelPath.split(',').map((e) => int.parse(e)).toList();

  @Ignore()
  get level => parents.length;

  @Ignore()
  final List<NoteEntity>? children;
  NoteEntity({
    required this.id,
    this.remoteId,
    required this.title,
    this.localPath,
    this.parentId,
    required this.levelPath,
    this.priority = 0,
    required this.shouldRenderChildren,
    required this.isHoverEnabled,
    this.ctime,
    this.utime,
    this.children,
  });

  NoteEntity copyWith({
    int? id,
    String? remoteId,
    String? title,
    String? localPath,
    int? parentId,
    String? levelPath,
    int? priority,
    bool? shouldRenderChildren,
    bool? isHoverEnabled,
    int? ctime,
    int? utime,
    List<NoteEntity>? children,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      localPath: localPath ?? this.localPath,
      parentId: parentId ?? this.parentId,
      levelPath: levelPath ?? this.levelPath,
      priority: priority ?? this.priority,
      shouldRenderChildren: shouldRenderChildren ?? this.shouldRenderChildren,
      isHoverEnabled: isHoverEnabled ?? this.isHoverEnabled,
      ctime: ctime ?? this.ctime,
      utime: utime ?? this.utime,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'remoteId': remoteId,
      'title': title,
      'localPath': localPath,
      'parentId': parentId,
      'levelPath': levelPath,
      'priority': priority,
      'shouldRenderChildren': shouldRenderChildren,
      'isHoverEnabled': isHoverEnabled,
      'ctime': ctime,
      'utime': utime,
      'children': children?.map((x) => x.toMap()).toList(),
    };
  }

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'] as int,
      remoteId: map['remoteId'] != null ? map['remoteId'] as String : null,
      title: map['title'] as String,
      localPath: map['localPath'] != null ? map['localPath'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      levelPath: map['levelPath'] as String,
      priority: map['priority'] as int,
      shouldRenderChildren: map['shouldRenderChildren'] as bool,
      isHoverEnabled: map['isHoverEnabled'] as bool,
      ctime: map['ctime'] != null ? map['ctime'] as int : null,
      utime: map['utime'] != null ? map['utime'] as int : null,
      children: map['children'] != null
          ? List<NoteEntity>.from(
              (map['children'] as List<int>).map<NoteEntity?>(
                (x) => NoteEntity.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteEntity.fromJson(String source) => NoteEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NoteEntity(id: $id, remoteId: $remoteId, title: $title, localPath: $localPath, parentId: $parentId, levelPath: $levelPath, priority: $priority, shouldRenderChildren: $shouldRenderChildren, isHoverEnabled: $isHoverEnabled, ctime: $ctime, utime: $utime, children: $children)';
  }

  @override
  bool operator ==(covariant NoteEntity other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.remoteId == remoteId &&
        other.title == title &&
        other.localPath == localPath &&
        other.parentId == parentId &&
        other.levelPath == levelPath &&
        other.priority == priority &&
        other.shouldRenderChildren == shouldRenderChildren &&
        other.isHoverEnabled == isHoverEnabled &&
        other.ctime == ctime &&
        other.utime == utime &&
        listEquals(other.children, children);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        remoteId.hashCode ^
        title.hashCode ^
        localPath.hashCode ^
        parentId.hashCode ^
        levelPath.hashCode ^
        priority.hashCode ^
        shouldRenderChildren.hashCode ^
        isHoverEnabled.hashCode ^
        ctime.hashCode ^
        utime.hashCode ^
        children.hashCode;
  }
}

import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';

import '../../../models/value_serializer.dart';

import '../../../models/objectbox.g.dart';

enum MessageType { text, image, loading, error, vendor }

// enum MessageFromType { receive, send }

// Annotate a Dart class to create a box
@Entity()
class Message {
  @Id()
  int id;
  @Index()
  final int conversationId;

  String content;

  String? error;

  @Property(type: PropertyType.date)
  final DateTime? createAt;

  @Transient()
  MessageType? type;
  @Transient()
  Role role;

  int? get dbMessageType {
    // _ensureStableEnumValues();
    return type?.index;
  }

  set dbMessageType(int? value) {
    // _ensureStableEnumValues();
    if (value == null) {
      type = null;
    } else {
      // type = MessageType.values[value]; // throws a RangeError if not found

      // or if you want to handle unknown values gracefully:
      type = value >= 0 && value < MessageType.values.length
          ? MessageType.values[value]
          : MessageType.text;
    }
  }

  int? get dbMessageFromType {
    // _ensureStableEnumValues();
    return role.index;
  }

  set dbMessageFromType(int? value) {
    // _ensureStableEnumValues();
    if (value == null) {
      role = Role.system;
    } else {
      // type = MessageType.values[value]; // throws a RangeError if not found

      // or if you want to handle unknown values gracefully:
      role = value >= 0 && value < Role.values.length
          ? Role.values[value]
          : Role.system;
    }
  }

  Message({
    this.id = 0,
    this.type,
    this.role = Role.system,
    this.error,
    this.content = '',
    this.createAt,
    required this.conversationId,
    // this.serviceId,
  });

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) {
    const serializer = ValueSerializer();
    // final requestMessageJson = serializer.fromJson<String?>(
    //   json["request_message"],
    // );
    // final quoteMessage = serializer.fromJson<String?>(
    //   json["quote_message"],
    // );
    return Message(
      id: serializer.fromJson<int>(json['id']),
      type: MessageType.values[serializer.fromJson<int?>(json['type']) ?? 0],
      role: Role.values[serializer.fromJson<int?>(json['from_type']) ?? 0],
      error: serializer.fromJson<String?>(json['error']),
      content: serializer.fromJson<String>(json['content']),
      createAt: serializer.fromJson<DateTime?>(json['create_at']),
      conversationId: serializer.fromJson<int>(json['conversation_id']),
    );
  }

  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    const serializer = ValueSerializer();
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'type': serializer.toJson<int?>(type?.index),
      'role': serializer.toJson<int?>(role.index),
      'error': serializer.toJson<String?>(error),
      'content': serializer.toJson<String?>(content),
      'create_at': serializer.toJson<DateTime?>(createAt),
      'conversation_id': serializer.toJson<int?>(conversationId),
    };
  }

  Message copyWith({
    int? id,
    MessageType? type,
    Role? role,
    String? error,
    String? content,
    DateTime? createAt,
    int? conversationId,
    String? serviceId,
  }) =>
      Message(
        id: id ?? this.id,
        type: type ?? this.type,
        role: role ?? this.role,
        error: error ?? this.error,
        content: content ?? this.content,
        createAt: createAt ?? this.createAt,
        conversationId: conversationId ?? this.conversationId,
      );

  @override
  String toString() {
    return (StringBuffer('MessageMetadata(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createAt: $createAt, ')
          ..write('conversationId: $conversationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        type,
        role,
        error,
        content,
        createAt,
        conversationId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == id &&
          other.type == type &&
          other.role == role &&
          other.error == error &&
          other.content == content &&
          other.createAt == createAt &&
          other.conversationId == conversationId);
}

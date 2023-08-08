import 'package:omnigram/app/data/models/value_serializer.dart';

import 'package:objectbox/objectbox.dart';

import 'objectbox.g.dart';

// Annotate a Dart class to create a box
@Entity()
class Conversation {
  @Id(assignable: true)
  int id = 0;
  String? name;
  int timeout;
  int maxTokens;
  final String? editName;
  final String serviceId;
  final int autoQuote;

  final String? promptId;

  String? get displayName => name ?? editName;

  Conversation({
    this.id = 0,
    this.name,
    this.editName,
    this.serviceId = 'open_ai_chat_gpt',
    this.autoQuote = 0,
    this.timeout = 60,
    this.maxTokens = 800,
    this.promptId,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    const serializer = ValueSerializer();
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      editName: serializer.fromJson<String?>(json['edit_name']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      autoQuote: serializer.fromJson<int?>(json['auto_quote']) ?? 0,
      timeout: serializer.fromJson<int?>(json['timeout']) ?? 60,
      maxTokens: serializer.fromJson<int?>(json['max_tokens']) ?? 800,
      promptId: serializer.fromJson<String?>(json['prompt_id']),
    );
  }

  Map<String, dynamic> toJson() {
    const serializer = ValueSerializer();
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'edit_name': serializer.toJson<String?>(editName),
      'serviceId': serializer.toJson<String?>(serviceId),
      'auto_quote': serializer.toJson<int?>(autoQuote) ?? 0,
      'timeout': serializer.toJson<int?>(timeout),
      'max_tokens': serializer.toJson<int?>(maxTokens),
      'prompt_id': serializer.toJson<String?>(promptId),
    };
  }

  Conversation copyWith({
    int? id,
    String? name,
    String? editName,
    required String serviceId,
    String? pluginKey,
    int? provider,
    int? autoQuote,
    int? timeout,
    int? maxTokens,
    String? promptId,
  }) =>
      Conversation(
        id: id ?? this.id,
        name: name ?? this.name,
        editName: editName ?? this.editName,
        serviceId: serviceId,
        autoQuote: autoQuote ?? this.autoQuote,
        timeout: timeout ?? this.timeout,
        maxTokens: maxTokens ?? this.maxTokens,
        promptId: promptId ?? this.promptId,
      );
  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('editName: $editName')
          ..write('serviceId: $serviceId')
          ..write('autoQuote: $autoQuote')
          ..write('timeout: $timeout')
          ..write('maxTokens: $maxTokens')
          ..write('promptId: $promptId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        editName,
        serviceId,
        autoQuote,
        timeout,
        maxTokens,
        promptId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == id &&
          other.name == name &&
          other.editName == editName &&
          other.autoQuote == autoQuote &&
          other.serviceId == serviceId &&
          other.maxTokens == maxTokens &&
          other.promptId == promptId &&
          other.timeout == timeout);
}

import 'choice.dart';

class ChatCTResponse {
  final String id;
  final String object;
  final int created;
  final List<ChatChoice> choices;
  final Usage? usage;
  final String conversionId = "${DateTime.now().millisecondsSinceEpoch}";

  ChatCTResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.choices,
    required this.usage,
  });

  factory ChatCTResponse.fromJson(Map<String, dynamic> json) => ChatCTResponse(
        id: json["id"],
        object: json["object"],
        created: json["created"],
        choices: List<ChatChoice>.from(
          json["choices"].map((x) => ChatChoice.fromJson(x)),
        ),
        usage: json["usage"] == null ? null : Usage.fromJson(json["usage"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "created": created,
        "choices": List<Map>.from(choices.map((x) => x.toJson())),
        "usage": usage?.toJson(),
      };
}

class ChatResponseSSE {
  final String id;
  final String? object;
  final int? created;
  final List<ChatChoiceSSE>? choices;
  final Usage? usage;
  final String? model;
  String conversionId = "${DateTime.now().millisecondsSinceEpoch}";

  ChatResponseSSE({
    required this.id,
    this.object,
    required this.created,
    required this.choices,
    required this.usage,
    this.model,
  });

  factory ChatResponseSSE.fromJson(Map<String, dynamic> json) =>
      ChatResponseSSE(
        id: json["id"],
        object: json["object"],
        created: json["created"],
        model: json["model"],
        choices: (json["choices"] == null)
            ? null
            : (json["choices"] as List)
                .map((e) => ChatChoiceSSE.fromJson(e))
                .toList(),
        usage: json["usage"] == null ? null : Usage.fromJson(json["usage"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "created": created,
        "choices": choices?.map((e) => e.toJson()).toList(),
        "usage": usage?.toJson(),
        "model": model,
      };
}

class Usage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final String id = "${DateTime.now().millisecondsSinceEpoch}";

  Usage(this.promptTokens, this.completionTokens, this.totalTokens);

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        json['prompt_tokens'],
        json['completion_tokens'],
        json['total_tokens'],
      );
  Map<String, dynamic> toJson() => usageToJson(this);

  Map<String, dynamic> usageToJson(Usage instance) => <String, dynamic>{
        'prompt_tokens': instance.promptTokens,
        'completion_tokens': instance.completionTokens,
        'total_tokens': instance.totalTokens,
      };
}

import 'message.dart';

class ChatChoice {
  final String id = "${DateTime.now().millisecondsSinceEpoch}";
  final int index;
  final ChatMessage? message;
  final String? finishReason;

  ChatChoice({required this.index, required this.message, this.finishReason});

  factory ChatChoice.fromJson(Map<String, dynamic> json) => ChatChoice(
        index: json["index"],
        message: json["message"] == null
            ? null
            : ChatMessage.fromJson(json["message"]),
        finishReason: json["finish_reason"],
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "message": message?.toJson(),
        "finish_reason": finishReason ?? "",
      };
}

class ChatChoiceSSE {
  final String id = "${DateTime.now().millisecondsSinceEpoch}";
  final int index;
  final ChatMessage? message;
  final String? finishReason;

  ChatChoiceSSE({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory ChatChoiceSSE.fromJson(Map<String, dynamic> json) => ChatChoiceSSE(
        index: json["index"],
        message:
            json["delta"] == null ? null : ChatMessage.fromJson(json["delta"]),
        finishReason:
            json["finish_reason"] == null ? "" : json["finish_reason"],
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "delta": message?.toJson(),
        "finish_reason": finishReason ?? "",
      };
}

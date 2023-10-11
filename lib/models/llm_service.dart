// {
// 	"id": "",
// 	"name": "New Chat",
// 	"avatar": "",
// 	"group_id": 0,
// 	"official_url": "",
// 	"api_url": "",
//   "on_received": "",
//   "help": "Help",
//   "help_url": "Help",
//   "block": false,
//   "tokens": [
//    {
//      "id": "api-key",
//      "name": "API Key",
//      "value": "",
//      "service_provider_id": 0
//    }
//  ]
// }

import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:omnigram/screens/chat/models/message.dart';

import 'value_serializer.dart';

import 'objectbox.g.dart';

typedef LLMServiceCallback = Future<void> Function(Message message);

// Annotate a Dart class to create a box
@Entity()
class LLMService {
  @Id()
  int id;

  @Unique()
  String name;

  String model;
  String avatar;
  String token;
  String? desc;
  String? apiUrl;
  String? officialUrl;
  String? editApiUrl;
  String? hello;
  String? help;
  String? helpUrl;

  bool block;

  // Transient
  // Message? currentRequestMessage;

  LLMService({
    this.id = 0,
    required this.name,
    required this.model,
    required this.avatar,
    this.token = '',
    required this.desc,
    this.apiUrl = '',
    this.officialUrl = '',
    this.editApiUrl = '',
    this.hello = 'open_ai_hello',
    this.help = 'chat_gpt_help',
    this.helpUrl = '',
    this.block = false,
  });

  factory LLMService.fromRawJson(String str) =>
      LLMService.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  LLMService copyWith({
    int? id,
    String? name,
    String? model,
    String? avatar,
    String? token,
    String? desc,
    String? apiUrl,
    String? officialUrl,
    String? editApiUrl,
    String? hello,
    String? help,
    String? helpUrl,
    bool? block,
    Map<String, dynamic>? map,
  }) =>
      LLMService(
        id: id ?? map?['id'] ?? this.id,
        name: name ?? map?['name'] ?? this.name,
        model: model ?? map?['model'] ?? this.model,
        avatar: avatar ?? map?['avatar'] ?? this.avatar,
        token: token ?? map?['token'] ?? this.token,
        desc: desc ?? map?['desc'] ?? this.desc,
        apiUrl: apiUrl ?? map?['apiUrl'] ?? this.apiUrl,
        officialUrl: officialUrl ?? map?['officialUrl'] ?? this.officialUrl,
        editApiUrl: editApiUrl ?? map?['editApiUrl'] ?? this.editApiUrl,
        hello: hello ?? map?['hello'] ?? this.hello,
        help: hello ?? map?['hello'] ?? this.hello,
        helpUrl: helpUrl ?? map?['helpUrl'] ?? this.helpUrl,
        block: block ?? map?['block'] ?? this.block,
      );

  factory LLMService.fromJson(Map<String, dynamic> json) {
    const serializer = ValueSerializer();
    return LLMService(
      id: json["id"],
      model: json["model"],
      name: json["name"],
      avatar: json["avatar"],
      desc: json['desc'],
      apiUrl: json["apiUrl"],
      token: json["token"],
      officialUrl: json["officialUrl"],
      editApiUrl: json["editApiUrl"],
      hello: json["hello"],
      help: json["help"],
      helpUrl: json["helpUrl"],
      block: serializer.fromJson<int>(json["block"]) == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "name": name,
        "avatar": avatar,
        "desc": desc,
        "token": token,
        "apiUrl": apiUrl,
        "officialUrl": officialUrl,
        "editApiUrl": editApiUrl,
        "hello": hello,
        "help": help,
        "helpUrl": helpUrl,
        "block": block ? 1 : 0,
      };
}

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

import 'package:omnigram/app/core/app_hive_keys.dart';
import 'package:omnigram/app/core/app_manager.dart';
import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:omnigram/openai/chat/enum.dart';

import '../data/models/message_model.dart';
import '../data/models/value_serializer.dart';
import '../modules/home/controllers/home_controller.dart';

typedef ServiceProviderCallback = Future<void> Function(Message message);

class ServiceProvider {
  static const loadingIdPrefix = 'loading__';
  static const errorIdPrefix = 'error__';

  String id;
  String model;
  String name;
  String avatar;
  String? apiUrl;
  String? desc;
  String? hello;
  String? help;
  int groupId;
  String token;
  String? officialUrl;
  String? editApiUrl;
  String? helpUrl;
  bool block;

  Message? currentRequestMessage;

  ServiceProvider({
    required this.id,
    required this.model,
    required this.name,
    required this.avatar,
    required this.desc,
    required this.groupId,
    this.apiUrl = '',
    this.hello = 'open_ai_hello',
    this.help = 'chat_gpt_help',
    this.token = '',
    this.block = false,
  });

  factory ServiceProvider.fromRawJson(String str) =>
      ServiceProvider.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  ServiceProvider copyWith({
    String? id,
    String? model,
    String? name,
    String? avatar,
    String? desc,
    int? groupId,
    String? apiUrl,
    String? hello,
    String? help,
    String? token,
    bool? block,
    Map<String, dynamic>? map,
  }) =>
      ServiceProvider(
        id: id ?? map?['id'] ?? this.id,
        model: model ?? map?['model'] ?? this.model,
        name: name ?? map?['name'] ?? this.name,
        avatar: avatar ?? map?['avatar'] ?? this.avatar,
        desc: desc ?? map?['desc'] ?? this.desc,
        token: token ?? map?['token'] ?? this.token,
        groupId: groupId ?? map?['group_id'] ?? this.groupId,
        apiUrl: apiUrl ?? map?['apiUrl'] ?? this.apiUrl,
        hello: hello ?? map?['hello'] ?? this.hello,
        help: hello ?? map?['hello'] ?? this.hello,
        block: block ?? map?['block'] ?? this.block,
      );

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    const ValueSerializer serializer = ValueSerializer();
    return ServiceProvider(
      id: json["id"],
      model: json["model"],
      name: json["name"],
      avatar: json["avatar"],
      desc: json['desc'],
      groupId: json["group_id"],
      apiUrl: json["apiUrl"],
      hello: json["hello"],
      help: json["help"],
      token: json["token"],
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
        "group_id": groupId,
        "hello": hello,
        "help": help,
        "block": block ? 1 : 0,
      };

  // ServiceVendor get vendor =>
  //     ServiceProviderManager.instance.vendors.firstWhere(
  //       (element) => element.id == vendorId,
  //     );

  @mustCallSuper
  Future<void> onInit({
    required Conversation conversation,
  }) async {
    bool? sent = AppManager.to.get(
      key: AppHiveKeys.serviceProviderIsSendHello + conversation.id.toString(),
    );
    if (sent == null || !sent) {
      if (hello != null && hello!.isNotEmpty) {
        receiveTextMessage(
          content: hello?.tr ?? "",
          conversationId: conversation.id,
        );
      }
      AppManager.to.set(
        key: AppHiveKeys.serviceProviderIsSendHello +
            id +
            conversation.id.toString(),
        value: true,
      );

      if (token.isNotEmpty) {
        return receiveTextMessage(
          content: help?.tr ?? "",
          conversationId: conversation.id,
        );
      }
    }
  }

  @mustCallSuper
  Future<bool> send({
    required Conversation conversation,
    required Message message,
  }) async {
    currentRequestMessage = message;

    if (token.isNotEmpty) {
      receiveErrorMessage(
        error: 'must_type_tokens'.trParams(
          {
            'tokens': name,
          },
        ),
        requestMessage: message,
      );
      return false;
    }

    receiveLoadingMessage(requestMessage: message);
    return true;
  }

  Future<void> receiveLoadingMessage({required Message requestMessage}) async {
    HomeController.to.onReceived(
      Message(
        type: MessageType.loading,
        serviceAvatar: avatar,
        serviceName: name,
        // serviceId: id,
        role: Role.assistant,
        createAt: DateTime.now(),
        // requestMessage: requestMessage,
        conversationId: requestMessage.conversationId,
      ),
    );
  }

  Future<void> receiveErrorMessage({
    required Message requestMessage,
    dynamic error,
  }) async {
    HomeController.to.onReceived(
      Message(
        type: MessageType.error,
        serviceAvatar: avatar,
        serviceName: name,
        // serviceId: id,
        content: error.toString(),
        role: Role.system,
        createAt: DateTime.now(),
        // requestMessage: requestMessage,
        conversationId: requestMessage.conversationId,
      ),
    );
  }

  Future<void> receiveTextMessage({
    Message? requestMessage,
    String content = '',
    int? conversationId,
  }) async {
    assert(requestMessage != null || conversationId != null);
    HomeController.to.onReceived(
      Message(
        type: MessageType.text,
        serviceAvatar: avatar,
        serviceName: name,
        // serviceId: id,
        content: content.trim(),
        role: Role.assistant,
        createAt: DateTime.now(),
        // requestMessage: requestMessage,
        conversationId: conversationId ?? 0,
      ),
    );
  }

  Future<void> receiveSystemMessage({
    String content = '',
    int? conversationId,
  }) async {
    HomeController.to.onReceived(
      Message(
        type: MessageType.vendor,
        serviceAvatar: avatar,
        serviceName: name,
        // serviceId: id,
        content: content.trim(),
        role: Role.system,
        createAt: DateTime.now(),
        conversationId: conversationId ?? 0,
      ),
    );
  }
}

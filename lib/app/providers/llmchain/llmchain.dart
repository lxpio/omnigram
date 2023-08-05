import 'dart:io';

import 'package:omnigram/app/core/app_http.dart';
import 'package:omnigram/app/data/models/llm_service.dart';

import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/providers/open_ai/chat_gpt_model.dart';
import 'package:omnigram/app/providers/service_provider.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';
import 'package:omnigram/flavors/build_config.dart';
import 'package:dio/dio.dart';

import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/openai/chat/message.dart';

class LLMChain extends LLMService {
  final List<Map<String, String>> messages = [];

  LLMChain({
    String name = 'open_ai_chat_gpt',
    String model = 'gpt-3.5-turbo-0301',
    String avatar = 'assets/images/ai_avatar.png',
    String apiUrl = 'https://api.openai.com/v1/chat/completions',
    String? desc,
    bool block = false,
  }) : super(
          model: model,
          name: name,
          avatar: avatar,
          desc: desc,
          block: block,
        );

  Future<bool> send({
    required Conversation conversation,
    required List<Message> messages,
  }) async {
    final chats = messages
        .map((e) => ChatMessage(role: e., content: e.content))
        .toList();

    return true;
    //change message to chatmessages
  }

  // void send(
  //   {required Conversation conversation, required List<Message> message}) {}

  Future<List<Map<String, String>>> _appendMessages(
    Conversation conversation,
    Message message,
  ) async {
    final messages = <Map<String, String>>[];
    return messages;
  }
}

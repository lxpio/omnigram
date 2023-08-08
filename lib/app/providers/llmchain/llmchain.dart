import 'dart:io';

import 'package:omnigram/app/core/app_http.dart';
import 'package:omnigram/app/data/models/llm_service.dart';

import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/modules/home/controllers/home_controller.dart';
import 'package:omnigram/app/providers/open_ai/chat_gpt_model.dart';
import 'package:omnigram/app/providers/open_ai_compatible.dart';
import 'package:omnigram/app/providers/service_provider.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';
import 'package:omnigram/flavors/build_config.dart';
import 'package:dio/dio.dart';

import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/openai/chat/chat_complate_text.dart';
import 'package:omnigram/openai/chat/enum.dart';
import 'package:omnigram/openai/chat/message.dart';
import 'package:omnigram/openai/chat/response.dart';
import 'package:omnigram/utils/constants.dart';

class LLMChain extends LLMService {
  final List<Map<String, String>> messages = [];

  late OpenAI _client;

  LLMChain({
    String model = kChatGptTurbo,
    String name = 'open_ai_chat_gpt',
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
        ) {
    // if (token == null) {
    //   throw Exception('Token is null');
    // }

    _client =
        OpenAI.instance.build(baseUrl: apiUrl, token: token, enableLog: true);
  }

  set updateClient(OpenAI client) {
    _client = client;
  }

  Stream<ChatResponseSSE> send({
    required Conversation conversation,
    required List<Message> messages,
  }) {
    // if token == null || token == '' {
    //   throw Exception('Token is null');
    // }

    final chats = messages
        .where((e) => e.role == Role.assistant || e.role == Role.user)
        .map((e) => ChatMessages(role: e.role, content: e.content ?? ""))
        .toList();

    final chatCompleteText = ChatCompleteText(
      model: model,
      messages: chats,
      temperature: 0.5,
      topP: 0.9,
      n: 2,
      stream: true,
      stop: ['User:'],
      maxToken: 50,
      presencePenalty: -0.5,
      frequencyPenalty: 0.5,
      user: 'user123',
    );

    return _client.onChatCompletionSSE(request: chatCompleteText);
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

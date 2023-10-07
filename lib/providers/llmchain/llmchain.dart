import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/models/llm_service.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';

import 'package:omnigram/providers/openai/chat/chat_complate_text.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/providers/openai/chat/message.dart';
import 'package:omnigram/providers/openai/chat/response.dart';
import 'package:omnigram/providers/service/open_ai_compatible_service.dart';
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
        .map((e) => ChatMessages(role: e.role, content: e.content))
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

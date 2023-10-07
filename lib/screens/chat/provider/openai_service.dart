import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/app_config.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/providers/client/model.dart';
import 'package:omnigram/providers/openai/chat/chat_complate_text.dart';
import 'package:omnigram/providers/openai/chat/message.dart';
import 'package:omnigram/providers/openai/chat/response.dart';
import 'package:omnigram/providers/service/chat/message_model.dart';
import 'package:omnigram/utils/constants.dart';

import '../../../providers/client/openai_client.dart';

// final openAIServiceProvider = Provider(OpenAIService.new);

//bookAPIServiceProvider 是全局有效的所以这了不要 autoDispose
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final appConfig = ref.watch(appConfigProvider);

  return OpenAIService(
    baseUrl: appConfig.openAIUrl ?? appConfig.bookBaseUrl,
    token: appConfig.bookToken,
  );
});

class OpenAIService {
  late OpenAIClient _client;

  late final String _baseUrl;

  OpenAIService({
    String baseUrl = "https://api.openai.com/v1/",
    String? token,
    String? orgId,
    HttpSetup? baseOption,
    bool enableLog = false,
  }) : _baseUrl = baseUrl {
    if ("$token".isEmpty || token == null) {
      //todo
    }

    final setup = baseOption ?? HttpSetup();

    final dio = Dio(BaseOptions(
      sendTimeout: setup.sendTimeout,
      connectTimeout: setup.connectTimeout,
      receiveTimeout: setup.receiveTimeout,
    ));
    if (setup.proxy.isNotEmpty) {
      dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          /// "PROXY localhost:7890"
          return setup.proxy;
        };

        return client;
      });
    }
    dio.interceptors.add(InterceptorWrapper(token: token, orgID: orgId));

    _client = OpenAIClient(dio: dio, isLogging: enableLog);
  }

  ///## Support Server Sent Event
  ///Given a chat conversation,
  /// the model will return a chat completion response. [chatSSE]
  Stream<ChatResponseSSE> chatSSE({
    required List<Message> messages,
    void Function(CancelData cancelData)? onCancel,
  }) {
    final request = makeChatCompletionRequest(messages: messages);
    print("$_baseUrl/$kChatGptTurbo");
    return _client.sse(
      "$_baseUrl/$kChatGptTurbo",
      request.toJson(),
      onCancel: (it) => onCancel != null ? onCancel(it) : null,
      complete: (it) {
        return ChatResponseSSE.fromJson(it);
      },
    );
  }
}

ChatCompleteText makeChatCompletionRequest(
    {required List<Message> messages, String? model}) {
  final chats = messages
      .map(
        (e) => ChatMessages(
          role: e.role,
          content: e.content,
          name: 'function_name',
        ),
      )
      .toList();

  final request = ChatCompleteText(
    model: model ?? kChatGptTurbo0613,
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

  return request;
}
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:omnigram/app/providers/client/model.dart';
import 'package:omnigram/app/providers/client/openai_client.dart';
import 'package:omnigram/openai/chat/chat_complate_text.dart';
import 'package:omnigram/openai/chat/response.dart';
import 'package:omnigram/utils/constants.dart';

import 'package:dio/io.dart';
import 'client/err.dart';

class OpenAI {
  ///instance of openai [instance]
  static final instance = OpenAI._internal();
  OpenAI._internal();

  late OpenAIClient _client;

  late final String _baseUrl;

  OpenAI build({
    String baseUrl = "https://api.openai.com/v1/",
    String? token,
    String? orgId,
    HttpSetup? baseOption,
    bool enableLog = false,
  }) {
    _baseUrl = baseUrl;
    if ("$token".isEmpty || token == null) throw MissingTokenException();
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
    // dio.interceptors.add(InterceptorWrapper(token: token, orgID: orgId));

    _client = OpenAIClient(dio: dio, isLogging: enableLog);

    return instance;
  }

  Future<ChatCTResponse?> onChatCompletion({
    required ChatCompleteText request,
    void Function(CancelData cancelData)? onCancel,
  }) {
    return _client.post(
      "$_baseUrl$kChatGptTurbo",
      request.toJson(),
      onCancel: (it) => onCancel != null ? onCancel(it) : null,
      onSuccess: (it) {
        return ChatCTResponse.fromJson(it);
      },
    );
  }

  ///## Support Server Sent Event
  ///Given a chat conversation,
  /// the model will return a chat completion response. [onChatCompletionSSE]
  Stream<ChatResponseSSE> onChatCompletionSSE({
    required ChatCompleteText request,
    void Function(CancelData cancelData)? onCancel,
  }) {
    return _client.sse(
      "$_baseUrl$kChatGptTurbo",
      request.toJson()..addAll({"stream": true}),
      onCancel: (it) => onCancel != null ? onCancel(it) : null,
      complete: (it) {
        return ChatResponseSSE.fromJson(it);
      },
    );
  }
}

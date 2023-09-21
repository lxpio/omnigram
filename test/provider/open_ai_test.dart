import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'package:omnigram/providers/openai/chat/chat_complate_text.dart';
import 'package:omnigram/providers/openai/chat/enum.dart';
import 'package:omnigram/providers/openai/chat/message.dart';
import 'package:omnigram/providers/service/chat/open_ai_compatible.dart';
import 'package:omnigram/utils/constants.dart';

import 'package:test/test.dart';

void main() {
  test('sse should be worked', () async {
    WidgetsFlutterBinding.ensureInitialized();

    OpenAI.instance.build(
        baseUrl: "http://192.168.12.121:33088/api/assistant/v2/",
        token: "test",
        enableLog: true);

    final messages = [
      ChatMessages(
        role: Role.user,
        content: 'Hello',
        name: 'function_name',
      ),
    ];

    final chatCompleteText = ChatCompleteText(
      model: kChatGptTurbo0613,
      messages: messages,
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

    final s = OpenAI.instance.onChatCompletionSSE(request: chatCompleteText);

    var subscription = s.listen(
      (data) {
        // This is called whenever new data is received from the SSE stream
        // Do something with the data, e.g., write it to another variable
        // For example, if you have a variable called 'myData', you can do this:
        // myData = data;
        print(data.choices?[0].message);
      },
      onError: (error) {
        // Handle errors from the SSE stream if necessary
        print("error: $error");
      },
      onDone: () {
        // This is called when the SSE stream is closed or no more data is available
        // Perform any cleanup or closing operations here if needed
        print("done");
      },
    );

    // ignore: prefer_const_constructors
    await Future.delayed(Duration(seconds: 20), () => subscription.cancel());
    print("exit....");
  });

  test('simple get should be created', () async {
    final dio = Dio();
    final onGetResponse = await dio.get("http://127.0.0.1/v1/",
        options: Options(responseType: ResponseType.stream));
    print(onGetResponse.data); // {message: Successfully mocked GET!}
  });
}

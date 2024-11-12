import 'dart:developer';

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

import 'package:omnigram/utils/wav.dart';

void main() {
  test('sse should be worked', () async {
    WidgetsFlutterBinding.ensureInitialized();

    // OpenAI.instance.build(
    //     baseUrl: "http://192.168.12.121:33088/api/assistant/v2/",
    //     token: "test",
    //     enableLog: true);

    // final messages = [
    //   ChatMessages(
    //     role: Role.user,
    //     content: 'Hello',
    //     name: 'function_name',
    //   ),
    // ];

    // final chatCompleteText = ChatCompleteText(
    //   model: kChatGptTurbo0613,
    //   messages: messages,
    //   temperature: 0.5,
    //   topP: 0.9,
    //   n: 2,
    //   stream: true,
    //   stop: ['User:'],
    //   maxToken: 50,
    //   presencePenalty: -0.5,
    //   frequencyPenalty: 0.5,
    //   user: 'user123',
    // );

    // final s = OpenAI.instance.onChatCompletionSSE(request: chatCompleteText);

    // var subscription = s.listen(
    //   (data) {
    //     // This is called whenever new data is received from the SSE stream
    //     // Do something with the data, e.g., write it to another variable
    //     // For example, if you have a variable called 'myData', you can do this:
    //     // myData = data;
    //     log(data.choices![0].message!.content);
    //   },
    //   onError: (error) {
    //     // Handle errors from the SSE stream if necessary
    //     log("error: $error");
    //   },
    //   onDone: () {
    //     // This is called when the SSE stream is closed or no more data is available
    //     // Perform any cleanup or closing operations here if needed
    //     log("done");
    //   },
    // );

    // // ignore: prefer_const_constructors
    // await Future.delayed(Duration(seconds: 20), () => subscription.cancel());
    // log("exit....");
  });

  // test('simple get should be created', () async {
  //   final dio = Dio();
  //   final onGetResponse = await dio.get("http://127.0.0.1/v1/",
  //       options: Options(responseType: ResponseType.stream));
  //   print(onGetResponse.data); // {message: Successfully mocked GET!}
  // });

  test('simple get should be created2', () async {
    //  WidgetsFlutterBinding.ensureInitialized();

    // await AppStore.initialize('db');

    // final ref = ProviderContainer();

    // final p = ref.read(conversationProvider);
    final dio = Dio();
    final onGetResponse = await dio.post("http://192.168.1.202:8080/m4t/pcm/stream",
        data: {
          "text": "你未看此花时，此花与汝同归于寂；你来看此花时，则此花颜色一时明白起来，便知此花不在你的心外。",
          "lang": "zh",
          "audio_id": "female_001",
        },
        options: Options(responseType: ResponseType.stream));
    // print(onGetResponse.data); // {message: Successfully mocked GET!}
    final Float32Wav raw = Float32Wav(
      numChannels: 1,
      sampleRate: 24000,
    );
    // Pipe the stream to the StreamController
    final subscription = onGetResponse.data!.stream.listen(
      (chunk) {
        final data = Uint8List.fromList(chunk);

        raw.append(data);
        print('Received chunk: ');
      },
      onDone: () {
        raw.writeFile("test.wav");
      },
      onError: (error) {
        print('Error during stream playback: $error');
      },
      cancelOnError: true,
    );

    await Future.delayed(const Duration(seconds: 10), () => subscription.cancel());

    log("exit....");
  });
}

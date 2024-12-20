import 'dart:developer';

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/setting.entity.dart';
import 'package:omnigram/providers/tts/fishtts.service.dart';
import 'package:omnigram/providers/tts/tts.service.dart';
// import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

  test('simple tts get should be save', () async {
    WidgetsFlutterBinding.ensureInitialized();

    PathProviderPlatform.instance = FakePathProviderPlatform();

    var log = Logger("OmmigramErrorLogger");

    final config =
        TTSConfig(enabled: false, ttsType: TTSServiceEnum.fishtts, endpoint: 'http://10.0.0.202:8999', accessToken: '');

    final TTS service = FishTTSService(config);

    final outfile = await service.saveToFile('test2', 'mp3', "你未看此花时，此花与汝同归于寂；你来看此花时，则此花颜色一时明白起来，便知此花不在你的心外。");

    log.info(",save data to  $outfile, exit....");
  });
}

class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getLibraryPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return '/tmp';
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>['/tmp'];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>['/tmp'];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getApplicationCachePath() {
    // TODO: implement getApplicationCachePath
    throw UnimplementedError();
  }
}

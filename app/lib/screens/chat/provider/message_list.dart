import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_platform/universal_platform.dart';

import '../models/message.dart';
import '../models/message_provider.dart';

part 'message_list.g.dart';

final msgIndexProvider = Provider<int>((_) {
  throw UnimplementedError();
});

final messageProvider = Provider<MessageProvider>((ref) {
  if (UniversalPlatform.isWeb) {
    return MessageAPI(ref);
  }

  return MessageBox();
});

@riverpod
class MessageList extends _$MessageList {
  @override
  Future<List<Message>> build(int id) async {
    if (kDebugMode) {
      print('MessageList build $id');
    }

    if (id == 0) {
      return [];
    }

    final box = ref.watch(messageProvider);

    return box.query(conversationId: id);
  }

  Future<void> create(List<Message> msg) async {
    final box = ref.read(messageProvider);

    for (final m in msg) {
      box.create(m);
    }

    final previousState = await future;
    state = AsyncData([...previousState, ...msg]);
  }

  Future<void> tips(Message msg) async {
    final previousState = await future;
    state = AsyncData([...previousState, msg]);
  }

  Future<void> append(String msg) async {
    final previousState = await future;
    previousState.last.content += msg;
    state = AsyncData(previousState);
  }

  Future<void> markError(String msg) async {
    final previousState = await future;
    previousState.last.error = msg;
    state = AsyncData(previousState);
  }

  Future<void> savelast() async {
    final box = ref.read(messageProvider);
    final previousState = await future;

    final msg = previousState.last;

    print(msg);

    box.create(msg);
  }
}

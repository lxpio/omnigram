import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/app_store.dart';
import 'package:omnigram/screens/chat/models/conversation.dart';

import 'package:omnigram/screens/chat/provider/conversation_list.dart';

import 'package:test/test.dart';

void main() {
  test('chat should be created', () async {
    //初始化

    WidgetsFlutterBinding.ensureInitialized();

    await AppStore.initialize('db');

    final ref = ProviderContainer();

    final p = ref.read(conversationProvider);

    final chat = Conversation(name: 'test', editName: 'editName1');
    final chat2 = Conversation(name: 'test2', editName: 'editName2');
    // print('The chat1 : ${chat.toString()}');
    // expect(p.create(chat), 1);
    // expect(p.create(chat2), 2);
    p.create(chat);
    p.create(chat2);

    expect(chat.id, 1);
    expect(chat2.id, 2);
  });

  test('chat should be query', () async {
    //初始化

    WidgetsFlutterBinding.ensureInitialized();

    await AppStore.initialize('./build');

    final ref = ProviderContainer();

    final p = ref.read(conversationProvider);

    final chats = p.query(max: 3);

    for (var cat in chats) {
      log('The chat1 : ${cat.toString()}');
    }

    // final chat = Conversation(name: 'test', editName: 'editName1', groupId: 1);
    // final chat2 =
    //     Conversation(name: 'test2', editName: 'editName2', groupId: 2);
    // print('The chat1 : ${chat.toString()}');
    // expect(p.create(chat), 1);
    // expect(p.create(chat2), 1);
  });
}

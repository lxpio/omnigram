import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/models/model.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';

import 'package:test/test.dart';

void main() {
  test('chat should be created', () async {
    //初始化

    WidgetsFlutterBinding.ensureInitialized();

    await AppStore.initialize('./db');

    final ConversationProvider p = ConversationProvider();

    final chat = Conversation(name: 'test', editName: 'editName1');
    final chat2 = Conversation(name: 'test2', editName: 'editName2');
    // print('The chat1 : ${chat.toString()}');
    // expect(p.create(chat), 1);
    // expect(p.create(chat2), 2);
    p.create(chat);
    p.create(chat2);
  });

  test('chat should be query', () async {
    //初始化

    WidgetsFlutterBinding.ensureInitialized();

    await AppStore.initialize('./build');

    final ConversationProvider p = ConversationProvider();

    final chats = p.query(max: 3);

    for (var cat in chats) {
      print('The chat1 : ${cat.toString()}');
    }

    // final chat = Conversation(name: 'test', editName: 'editName1', groupId: 1);
    // final chat2 =
    //     Conversation(name: 'test2', editName: 'editName2', groupId: 2);
    // print('The chat1 : ${chat.toString()}');
    // expect(p.create(chat), 1);
    // expect(p.create(chat2), 1);
  });
}

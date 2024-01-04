import 'package:omnigram/providers/provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_platform/universal_platform.dart';

import '../models/conversation.dart';
import '../models/conversation_provider.dart';
import 'message_list.dart';

part 'conversation_list.g.dart';

final conversationSearchProvider = Provider<String>((ref) {
  return '';
});

final conversationProvider = Provider<ConversationProvider>((ref) {
  if (UniversalPlatform.isWeb) {
    final baseUrl = ref.watch(appConfigProvider).baseUrl;

    return ConversationAPI(baseUrl);
  }

  return ConversationBox();
});

@riverpod
class ConversationList extends _$ConversationList {
  @override
  Future<List<Conversation>> build() async {
    final box = ref.watch(conversationProvider);

    final search = ref.watch(conversationSearchProvider);

    return box.query(max: 20);
  }

  Future<void> add(Conversation conversation) async {
    final box = ref.read(conversationProvider);
    box.create(conversation);

    final previousState = await future;
    state = AsyncData([conversation, ...previousState]);
  }

  Future<void> remove(Conversation conversation) async {
    final box = ref.read(conversationProvider);
    box.delete(conversation.id);

    //这里要同时删除关联的message

    await ref.read(messageProvider).removeALL(conversation.id);

    final previousState = await future;

    previousState.removeWhere((element) => element.id == conversation.id);

    state = AsyncData([...previousState]);
  }
}

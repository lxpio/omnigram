import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/providers/service/chat/conversation_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_list.g.dart';

final conversationSearchProvider = Provider<String>((_) {
  return '';
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

    final previousState = await future;

    previousState.removeWhere((element) => element.id == conversation.id);

    state = AsyncData([...previousState]);
  }
}

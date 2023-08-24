import 'package:omnigram/models/model.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/models/objectbox.g.dart';

abstract class ConversationProvider {
  factory ConversationProvider() {
    return ConversationBox();
  }

  List<Conversation> query({required int max});

  List<Conversation> getAll();

  int create(Conversation chat);

  int update(Conversation chat);

  bool delete(int id);
}

class ConversationBox implements ConversationProvider {
  late final Box<Conversation> _box;

  ConversationBox() : _box = AppStore.instance.create<Conversation>();

  @override
  int create(Conversation chat) {
    return _box.put(chat);
  }

  @override
  bool delete(int id) {
    return _box.remove(id);
  }

  @override
  List<Conversation> query({required int max}) {
    final query = (_box.query()..order(Conversation_.id)).build();

    query.limit = 5;

    final result = query.find();

    query.close();

    return result;
  }

  @override
  List<Conversation> getAll() {
    return _box.getAll();
  }

  @override
  int update(Conversation chat) {
    if (chat.id == 0) {
      //TODO 如果ID为零则代表不是新建这里要返回错误。
      return 0;
    }
    return create(chat);
  }
}

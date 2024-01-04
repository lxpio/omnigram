import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/models/app_config_model.dart';
import 'package:omnigram/providers/provider.dart';
import 'package:omnigram/models/app_store.dart';
import 'package:omnigram/models/objectbox.g.dart';

import 'message.dart';

abstract class MessageProvider {
  List<Message> query({
    required int conversationId,
    MessageType? type,
    int offset = 0,
    int limit = 16,
  });

  int create(Message message);

  bool delete(Message message);

  int removeALL(int conversationId);
}

class MessageBox implements MessageProvider {
  late final Box<Message> _box;

  MessageBox() : _box = AppStore.instance.box<Message>();

  @override
  int create(Message message) {
    return _box.put(message);
  }

  @override
  bool delete(Message message) {
    return _box.remove(message.id);
  }

  @override
  List<Message> query(
      {required int conversationId,
      String? serviceId,
      MessageType? type,
      int offset = 0,
      int limit = 16}) {
    print("query message $conversationId");
    final q = (_box.query(Message_.conversationId.equals(conversationId))
          ..order(Message_.id))
        .build();

    q
      ..offset = offset
      ..limit = limit;

    final result = q.find();

    q.close();

    return result;
  }

  @override
  int removeALL(int conversationId) {
    final q = (_box.query(Message_.conversationId.equals(conversationId))
          ..order(Message_.id))
        .build();

    final result = q.findIds();

    return _box.removeMany(result);
  }
}

class MessageAPI implements MessageProvider {
  MessageAPI(this.ref);

  final Ref ref;

  @override
  int create(Message message) {
    final backendCfg = ref.read(appConfigProvider);

    //new http client to post create

    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  bool delete(Message message) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  List<Message> query(
      {required int conversationId,
      MessageType? type,
      int offset = 0,
      int limit = 16}) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  int removeALL(int conversationId) {
    //do nothing

    return 0;
  }
}

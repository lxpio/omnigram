import 'package:get/get.dart';
import 'package:objectbox/objectbox.dart';
import 'package:omnigram/app/data/models/model.dart';
import 'package:omnigram/app/data/models/objectbox.g.dart';

import '../models/message_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class MessageProvider {
  factory MessageProvider() {
    return MessageBox();
  }

  List<Message> query({
    required int conversationId,
    MessageType? type,
    int offset = 0,
    int limit = 16,
  });

  int create(Message message);

  bool delete(Message message);
}

class MessageBox implements MessageProvider {
  late final Box<Message> _box;

  MessageBox() : _box = AppStore.instance.create<Message>();

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
    final q = (_box.query(Message_.conversationId.equals(conversationId))
          ..order(Message_.id, flags: Order.descending))
        .build();

    q
      ..offset = offset
      ..limit = limit;

    final result = q.find();

    q.close();

    return result;
  }
}

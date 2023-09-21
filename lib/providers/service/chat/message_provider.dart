import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/app_config.dart';
import 'package:omnigram/models/model.dart';
import 'package:omnigram/models/objectbox.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_platform/universal_platform.dart';

import 'message_model.dart';

final messageProvider = Provider<MessageProvider>((ref) {
  if (UniversalPlatform.isWeb) {
    return MessageAPI(ref);
  }

  return MessageBox();
});

abstract class MessageProvider {
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
}

class MessageAPI implements MessageProvider {
  MessageAPI(this.ref);

  final Ref ref;

  @override
  int create(Message message) {
    AppConfig backendCfg = ref.read(appConfigProvider);

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
}

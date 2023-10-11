// ignore_for_file: unused_import

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/flavors/app_store.dart';

import 'package:omnigram/models/objectbox.g.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../flavors/app_config.dart';
import 'conversation.dart';

abstract class ConversationProvider {
  List<Conversation> query({required int max});

  List<Conversation> getAll();

  int create(Conversation chat);

  int update(Conversation chat);

  bool delete(int id);

  int count();
}

class ConversationBox implements ConversationProvider {
  late final Box<Conversation> _box;

  ConversationBox() : _box = AppStore.instance.box<Conversation>();

  @override
  int create(Conversation chat) {
    return _box.put(chat);
  }

  @override
  bool delete(int id) {
    return _box.remove(id);
  }

  @override
  List<Conversation> query({required int max, String? search}) {
    late final qBuilder = (search != null && search.isNotEmpty)
        ? _box.query(Conversation_.name.contains(search))
        : _box.query();

    qBuilder.order(Conversation_.id, flags: Order.descending);

    final query = qBuilder.build();
    query.limit = max ?? 100; // 设置默认的最大值

    try {
      final result = query.find();
      return result;
    } catch (e) {
      // 处理异常情况
      print("查询出错：$e");
      return [];
    } finally {
      query.close();
    }
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

  @override
  int count() {
    // TODO: implement length
    return _box.count();
  }
}

class ConversationAPI implements ConversationProvider {
  ConversationAPI(this.baseUrl);
  final String baseUrl;

  @override
  int create(Conversation chat) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  bool delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  List<Conversation> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  List<Conversation> query({required int max}) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  int update(Conversation chat) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  int count() {
    // TODO: implement count
    throw UnimplementedError();
  }
}

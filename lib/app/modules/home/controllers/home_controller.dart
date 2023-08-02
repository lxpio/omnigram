import 'dart:core';

import 'package:omnigram/app/core/app_controller_mixin.dart';
import 'package:omnigram/app/core/app_hive_keys.dart';
import 'package:omnigram/app/core/app_manager.dart';
import 'package:omnigram/app/core/app_toast.dart';
import 'package:omnigram/app/core/refresh_mixin.dart';

import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'package:omnigram/app/routes/app_pages.dart';

class HomeController extends GetxController
    with AppControllerMixin, RefreshMixin {
  static HomeController to = Get.find();
  late final List<Message> messages = [];

  int _currentConversationIndex = -1;
  int get currentConversationIndex => _currentConversationIndex;

  set currentConversationIndex(int currentConversationIndex) {
    if (_currentConversationIndex == currentConversationIndex) return;
    _currentConversationIndex = currentConversationIndex;
    AppManager.to.set(
      key: currentConversationIndexHiveKey,
      value: currentConversationIndex,
    );
  }

  Message? currentQuotedMessage;

  final List<Conversation> conversations = [];

  Conversation? get currentConversation =>
      conversations.isEmpty || currentConversationIndex == -1
          ? null
          : conversations[currentConversationIndex];

  String get currentConversationIndexHiveKey =>
      AppHiveKeys.currentConversationIndex;

  @override
  late final scroll = ScrollController();

  late final focusNode = FocusNode();
  late final textEditing = TextEditingController();

  int currentGroupIndex = 0;

  String get title =>
      currentConversation?.editName ?? 'groups[currentGroupIndex].title';

  @override
  Future<void> onInit() async {
    await loadConversations(1024);

    // Remove splash after home page update
    FlutterNativeSplash.remove();

    super.onInit();
  }

  Future<void> onSubmitted(String value) async {
    if (value.isEmpty) {
      AppToast.show(msg: 'unable_send'.tr);
      return;
    }

    final message = Message(
      type: MessageType.text,
      fromType: MessageFromType.send,
      content: value,
      createAt: DateTime.now(),
      conversationId: currentConversation!.id,
    );
    // await AppDatabase.instance.messagesDao.create(message);
    messages.insert(0, message);

    currentQuotedMessage = null;

    update();

    final llm = ServiceProviderManager.instance.get(
      id: currentConversation!.serviceId,
    );
    llm.send(
      conversation: currentConversation!,
      messages: messages,
    );
  }

  Future<void> onReceived(Message message) async {
    if (message.type != MessageType.loading) {
      // await AppDatabase.instance.messagesDao.create(message);
    }

    final loadingIndex = messages.indexWhere(
      (element) =>
          element.serviceName == message.serviceName &&
          element.serviceAvatar == message.serviceAvatar &&
          element.type == MessageType.loading,
    );
    if (loadingIndex == -1) {
      messages.insert(0, message);
    } else {
      messages.removeAt(loadingIndex);
      messages.insert(0, message);
    }
    update();
  }

  Future<void> onRetried(Message message) async {
    if (message.type != MessageType.error) return;

    final index = messages.indexWhere((element) => element == message);
    messages[index] = message.copyWith(type: MessageType.loading);
    update();

    // await AppDatabase.instance.messagesDao.delete(message);

    final llm = ServiceProviderManager.instance.get(
      id: currentConversation?.serviceId,
    );

    llm.send(
      conversation: currentConversation!,
      messages: messages,
    );
  }

  void onQuoted(Message message) {
    currentQuotedMessage = message;
    update();

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  // clear current quote message
  void onCleared() {
    currentQuotedMessage = null;
    update();
  }

  void onAvatarClicked(Message message) {
    focusNode.unfocus();
    if (message.type == MessageType.vendor) {
      Get.toNamed(
        Routes.CONVERSATION,
        arguments: currentConversation,
      );
    } else if (message.type != MessageType.vendor &&
        message.fromType != MessageFromType.send) {
      Get.toNamed(
        Routes.CONVERSATION,
        arguments: currentConversation,
      );
    }
  }

  //加载已经存储的会话列表
  Future<void> loadConversations(int max) async {
    conversations.clear();
    conversations.addAll(AppProvider.instance.conversations.query(max: max));

    //todo 这里为什么要用 to.get ?
    final conversationIndex = AppManager.to.get(
      key: currentConversationIndexHiveKey,
    );
    changeConversation(index: conversationIndex);
  }

  Future<Conversation?> changeConversation({int? index}) async {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }

    if (currentConversationIndex == index) {
      update();
      return currentConversation;
    }

    if (index == null || index >= conversations.length) {
      await _createConversation();
      index = conversations.length - 1;
    }

    currentConversationIndex = index;
    currentQuotedMessage = null;

    messages.clear();
    final list = AppProvider.instance.messages.query(
      conversationId: conversations[index].id,
    );
    messages.addAll(list);

    // canFetchTop = list.length >= AppDatabase.defaultLimit;

    update();
    //TODO 这里 不需要放在在ServiceProviderManager 里面，而是直接在 当前class 处理
    await ServiceProviderManager.instance.changeConversation(
      conversation: currentConversation!,
    );

    return currentConversation;
  }

  Future<void> _createConversation({String? name}) async {
    final conversation = Conversation(
      name: name ?? '${'new_chat'.tr} ${conversations.length + 1}',
    );

    // create or replace
    AppProvider.instance.conversations.create(
      conversation,
    );

    // id == null: create conversation

    conversations.add(conversation);
  }

  Future<void> updateConversation(
      {required String id, required String name}) async {
    final index = conversations.indexWhere((element) => element.id == id);

    final conversation = conversations[index].copyWith(
      name: name,
      serviceId: id,
    );
    conversations[index] = conversation;
    // replace
    AppProvider.instance.conversations.create(
      conversation,
    );

    update();
  }

  Future<Conversation> deleteConversation(Conversation conversation) async {
    final index =
        conversations.indexWhere((element) => element.id == conversation.id);

    if (index != -1) {
      conversations.removeAt(index);
      //TODO handle error
      AppProvider.instance.conversations.delete(conversation.id);

      if (currentConversationIndex == index) {
        AppManager.to
            .set(key: AppHiveKeys.currentConversationIndex, value: null);
      }

      if (conversations.isEmpty) {
        loadConversations(1024);
      } else {
        changeConversation(
            index: index < conversations.length
                ? index
                : conversations.length - 1);
      }
    }

    return conversation;
  }

  @override
  Future<void> onEndScroll() async {
    if (currentConversation?.id == null) return;

    final list = AppProvider.instance.messages.query(
      conversationId: currentConversation!.id,
      offset: messages.length,
    );
    messages.addAll(list);

    // canFetchTop = list.length >= AppDatabase.defaultLimit;

    update();
  }

  @override
  Future<void> onTopScroll() async {}

  void toConversation({Conversation? conversation}) {
    Get.toNamed(Routes.CONVERSATION, arguments: {
      'conversation': conversation ?? currentConversation,
    });
  }
}

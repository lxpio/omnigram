import 'dart:core';

import 'package:flutter/material.dart';
import 'package:highlight/languages/fortran.dart';
import 'package:omnigram/app/core/app_controller_mixin.dart';
import 'package:omnigram/app/core/app_hive_keys.dart';
import 'package:omnigram/app/core/app_manager.dart';
import 'package:omnigram/app/core/app_toast.dart';
import 'package:omnigram/app/core/refresh_mixin.dart';

import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/data/models/model.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/providers/llmchain/llmchain.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'package:omnigram/app/routes/app_pages.dart';
import 'package:omnigram/openai/chat/enum.dart';

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

  // late OverlayEntry? _overlayEntry;

  int currentGroupIndex = 0;

  String get title =>
      currentConversation?.editName ?? 'groups[currentGroupIndex].title';

  @override
  Future<void> onInit() async {
    await loadConversations(1024);

    // textEditing.addListener(_handleTextChange);

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
      role: Role.user,
      content: value,
      createAt: DateTime.now(),
      conversationId: currentConversation!.id,
    );

//存储聊天记录
    AppProvider.instance.messages.create(message);

    messages.insert(0, message);

    currentQuotedMessage = null;

    update();

    final llm = ServiceProviderManager.instance.get(
      id: currentConversation!.serviceId,
    );

    try {
      int index = messages.indexWhere((e) => e.role == Role.system);

      final stream = llm.send(
        conversation: currentConversation!,
        messages: messages.sublist(0, index),
      );

      stream.listen(
        (data) {
          // This is called whenever new data is received from the SSE stream
          // Do something with the data, e.g., write it to another variable
          // For example, if you have a variable called 'myData', you can do this:
          // myData = data;

          final msg = data.choices?[0].message?.content;
          if (msg != null && msg.isNotEmpty) {
            receiveChatMessage(
                content: msg,
                llm: llm,
                conversationId: currentConversation!.id);
          }

          // print(data.choices?[0].message);
        },
        onError: (error) {
          // Handle errors from the SSE stream if necessary

          receiveErrorMessage(
              llm: llm, conversationId: currentConversation!.id, error: error);
          // print("error: $error");
        },
        onDone: () {
          // This is called when the SSE stream is closed or no more data is available
          // Perform any cleanup or closing operations here if needed
          AppProvider.instance.messages.create(messages.first);
        },
      );
    } catch (e) {
      AppToast.show(msg: 'unable_send'.tr);
    }

    // return true;
    //change message to chatmessages
  }

  Future<void> receiveChatMessage({
    required int conversationId,
    required LLMChain llm,
    required String content,
  }) async {
    // assert(requestMessage != null || conversationId != null);

    if (messages.first.role != Role.assistant) {
      messages.insert(
          0,
          Message(
            conversationId: conversationId,
            role: Role.assistant,
            type: MessageType.text,
            serviceAvatar: llm.avatar,
            serviceName: llm.name,
            content: content,
          ));
      update();
      return;
    }
    messages.first.content = content;
    // messages.first.content = messages.first.content + content;
    update();
  }

  Future<void> receiveErrorMessage({
    required LLMChain llm,
    required int conversationId,
    dynamic error,
  }) async {
    onReceived(
      Message(
        type: MessageType.error,
        serviceAvatar: llm.avatar,
        serviceName: llm.name,
        // serviceId: id,
        content: error.toString(),
        role: Role.system,
        createAt: DateTime.now(),
        // requestMessage: requestMessage,
        conversationId: conversationId,
      ),
    );
  }

  Future<void> onReceived(Message message) async {
    if (message.type != MessageType.loading) {
      AppProvider.instance.messages.create(message);
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
        arguments: {
          'conversation': currentConversation,
        },
      );
    } else if (message.type != MessageType.vendor &&
        message.role != Role.user) {
      Get.toNamed(Routes.CONVERSATION, arguments: {
        'conversation': currentConversation,
      });
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

  Future<void> onCommand() async {
    textEditing.text = "/";
  }
}

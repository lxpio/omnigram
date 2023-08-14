import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnigram/app/core/app_controller_mixin.dart';
import 'package:omnigram/app/core/app_toast.dart';
import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/modules/home/controllers/home_controller.dart';

import 'package:omnigram/app/providers/llmchain/llmchain.dart';
// import 'package:omnigram/app/providers/service_provider.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';
import 'package:omnigram/app/routes/app_pages.dart';

class ConversationController extends GetxController with AppControllerMixin {
  late Conversation conversation = Get.arguments['conversation'];

  late bool editing = Get.arguments['editing'] ?? false;

  late LLMChain? service;
  // late final nameTextEditing = TextEditingController(
  //   text: conversation.name,
  // );

  late final FocusNode nameFocusNode = FocusNode();

  final conversationNameTextEditingController = TextEditingController();

  final maxTokensTextEditingController = TextEditingController();
  final timeoutTextEditingController = TextEditingController();

  @override
  void onInit() {
    service = ServiceProviderManager.instance
        .get(id: conversation.serviceId); //conversation.serviceId
    if (conversation.id == 0) {
      editing = true;
    }
    super.onInit();
  }

  @override
  void onReady() {
    if (conversation.name != null) {
      conversationNameTextEditingController.text = conversation.name!;
    }

    maxTokensTextEditingController.text = conversation.maxTokens.toString();

    timeoutTextEditingController.text = conversation.timeout.toString();

    super.onReady();
  }

  void onEdited() {
    editing = true;
    // for (final token in tokens) {
    //   tokenControllers[token.id]?.text = token.value;
    // }
    update();
    // delay is working
    Future.delayed(const Duration(milliseconds: 100), () {
      nameFocusNode.requestFocus();
    });
  }

  Future<void> onSaved() async {
    if (conversation.name != conversationNameTextEditingController.text) {
      conversation.name = conversationNameTextEditingController.text;
    }

    conversation.maxTokens =
        int.tryParse(maxTokensTextEditingController.text) ?? 0;
    conversation.timeout = int.tryParse(timeoutTextEditingController.text) ?? 0;

    AppProvider.instance.conversations.create(
      conversation,
    );

    editing = false;

    // await AppDatabase.instance.serviceVendorsDao.create(vendor!);

    AppToast.show(msg: 'saved_successfully'.tr);

    HomeController.to.addConversation(conversation);
    update();
    Get.toNamed(
      Routes.HOME,
    );
  }
  // void increment() => count.value++;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnigram/app/core/app_controller_mixin.dart';
import 'package:omnigram/app/core/app_toast.dart';
import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/app/data/models/llm_service.dart';
import 'package:omnigram/app/providers/llmchain/llmchain.dart';
import 'package:omnigram/app/providers/service_provider.dart';
import 'package:omnigram/app/providers/service_provider_manager.dart';

class ConversationController extends GetxController with AppControllerMixin {
  //TODO: Implement ConversationController
  // late args = Get.arguments

  late Conversation conversation = Get.arguments['conversation'];

  late LLMChain? service;
  // late final nameTextEditing = TextEditingController(
  //   text: conversation.name,
  // );

  late final FocusNode nameFocusNode = FocusNode();

  final conversationNameTextEditingController = TextEditingController();

  final maxTokensTextEditingController = TextEditingController();
  final timeoutTextEditingController = TextEditingController();

  bool editing = false;

  @override
  void onInit() {
    service = ServiceProviderManager.instance.get(id: conversation.serviceId);
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
    if (conversation == null) return;

    if (conversation.name != conversationNameTextEditingController.text) {
      conversation.name = conversationNameTextEditingController.text;
    }

    conversation.maxTokens =
        int.tryParse(maxTokensTextEditingController.text) ?? 0;
    conversation.timeout = int.tryParse(timeoutTextEditingController.text) ?? 0;

    // for (int index = 0; index < tokens.length; index++) {
    //   final token = tokens[index];
    //   if (token.value != tokenControllers[token.id]?.text) {
    //     tokens[index] = token.copyWith(
    //       value: tokenControllers[token.id]?.text,
    //     );
    //     await ServiceProviderManager.instance.saveToken(tokens[index]);
    //   }
    // }

    // for (int index = 0; index < parameters.length; index++) {
    //   final parameter = parameters[index];
    //   if (parameter.value != parameterControllers[parameter.key]?.text) {
    //     parameters[index] = parameter.copyWith(
    //       value: parameterControllers[parameter.key]?.text,
    //     );
    //     await ServiceProviderManager.instance.saveParameter(parameters[index]);
    //   }
    // }

    // vendor?.editApiUrl = apiUrlTextEditingController.text;

    editing = false;

    update();

    // await AppDatabase.instance.serviceVendorsDao.create(vendor!);

    AppToast.show(msg: 'saved_successfully'.tr);
  }
  // void increment() => count.value++;
}

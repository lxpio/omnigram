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
    super.onInit();
  }

  @override
  void onReady() {
    service = ServiceProviderManager.instance.get(id: conversation.serviceId);

    if (conversation.name != null) {
      conversationNameTextEditingController.text = conversation.name!;
    }

    // if (service?.max_tokens != null) {
    //   maxTokensTextEditingController.text = service!.max_tokens!;
    // }

    // if (service?.timeout != null) {
    //   timeoutTextEditingController.text = service!.timeout!;
    // }

    super.onReady();
  }

  void onEdited() {
    // editing = true;
    // for (final token in tokens) {
    //   tokenControllers[token.id]?.text = token.value;
    // }
    update();
    // delay is working
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   apiUrlFocusNode.requestFocus();
    // });
  }

  Future<void> onSaved() async {
    if (conversation == null) return;

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

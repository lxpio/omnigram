import 'package:omnigram/app/data/models/conversation_model.dart';
import 'package:omnigram/app/data/models/llm_service.dart';

import 'package:omnigram/app/data/models/request_parameter.dart';
import 'package:omnigram/app/data/providers/provider.dart';
import 'package:omnigram/app/modules/home/controllers/home_controller.dart';
import 'package:omnigram/app/providers/llmchain/chat_gpt_3.dart';
import 'package:omnigram/app/providers/llmchain/llmchain.dart';
import 'package:omnigram/app/providers/llmchain/longchat.dart';
import 'package:omnigram/app/providers/service_provider.dart';
import 'package:get/get.dart';

import 'package:omnigram/app/core/app_hive_keys.dart';
import 'package:omnigram/app/core/app_manager.dart';
import 'package:omnigram/app/core/app_uuid.dart';
import 'package:omnigram/app/data/models/message_model.dart';
import 'package:omnigram/app/data/models/service_token.dart';

class ServiceProviderManager extends GetxController {
  static final instance = ServiceProviderManager._internal();
  ServiceProviderManager._internal();

  //内置的 LLM 模型 services
  late final Map<String, LLMChain> services = {
    'chat-gpt-3': LongChat(),
    'chat-gpt-4': ChatGPT3(),
  };

  // late final vendors = <ServiceVendor>[];

  late final tokens = <ServiceToken>[];
  late final parameters = <RequestParameter>[];

  static Future<void> initialize() async {
    // instance.providers.forEach((key, value) {
    //   instance._updateProvider(value);
    // });

    // instance.vendors.addAll(
    //   await AppDatabase.instance.serviceVendorsDao.getAll(),
    // );
    // instance.tokens.addAll(
    //   await AppDatabase.instance.serviceTokensDao.getAll(),
    // );
    // instance.parameters.addAll(
    //   await AppDatabase.instance.requestParametersDao.getAll(),
    // );
  }

  // Future<void> _updateProvider(LLMService? provider) async {
  //   if (provider == null) return;

  //   final map = await AppProvider.instance.serviceProviders.get(
  //     id: provider.id,
  //   );
  //   if (map != null) {
  //     provider.name = map['name'];
  //     provider.avatar = map['avatar'];
  //     provider.block = map['block'] == 1 ? true : false;
  //   }
  // }

  LLMChain get({String? id}) {
    final provider = services[id];

    if (provider == null) {
      return services.values.first;
    }

    return provider;
  }

  // Future<List<ServiceProvider>> getAll({
  //   // required Group group,
  //   required Conversation conversation,
  // }) async {
  //   final List<ServiceProvider> list = [];
  //   for (final item in providers) {
  //     if (!item.block) {
  //       list.add(item);
  //     }
  //   }
  //   return list;
  // }

  // Iterable<ServiceToken> getTokens({required String vendorId}) {
  //   return tokens.where((element) => element.vendorId == vendorId);
  // }

  Future<void> saveToken(ServiceToken token) async {
    final index = tokens.indexWhere((element) => element.id == token.id);
    if (index != -1) {
      tokens[index] = token;
    } else {
      tokens.add(token);
    }
    // await AppDatabase.instance.serviceTokensDao.create(
    //   token,
    // );
  }

  Iterable<RequestParameter> getParameters({required String vendorId}) {
    return parameters.where((element) => element.vendorId == vendorId);
  }

  Future<void> saveParameter(RequestParameter parameter) async {
    final index = parameters.indexWhere(
      (element) =>
          element.key == parameter.key &&
          element.vendorId == parameter.vendorId,
    );
    if (index != -1) {
      parameters[index] = parameter;
    } else {
      parameters.add(parameter);
    }
    // await AppDatabase.instance.requestParametersDao.create(
    //   parameter,
    // );
  }

  Future<void> block(ServiceProvider? provider, bool isBlocked) async {
    if (provider == null) return;

    provider.block = isBlocked;

    // replace block value
    await AppProvider.instance.serviceProviders.create(provider);
  }

  Future<void> changeConversation({
    required Conversation conversation,
  }) async {
    //获取第一个有效的 llm
    final llm = get(id: conversation.serviceId);

    final key =
        AppHiveKeys.serviceProviderIsSendHello + conversation.id.toString();
    bool? sent = AppManager.to.get(
      key: key,
    );
    if (sent == null || !sent) {
      if (llm.hello != null && llm.hello!.isNotEmpty) {
        HomeController.to.onReceived(
          Message(
            type: MessageType.vendor,
            serviceAvatar: llm.avatar,
            serviceName: llm.name,
            // serviceId: provider.id,
            content: llm.hello?.tr,
            fromType: MessageFromType.receive,
            createAt: DateTime.now(),
            conversationId: conversation.id,
          ),
        );
      }
      AppManager.to.set(
        key: key,
        value: true,
      );

      // final tokens = getTokens(
      //   vendorId: item.vendorId,
      // );
      // final emptyValueTokens = tokens.where(
      //   (element) => element.value.isEmpty,
      // );
      if (llm.token.isEmpty) {
        HomeController.to.onReceived(
          Message(
            type: MessageType.vendor,
            serviceAvatar: llm.avatar,
            serviceName: llm.name,
            // serviceId: provider.id,
            content: llm.help?.tr,
            fromType: MessageFromType.receive,
            createAt: DateTime.now(),
            conversationId: conversation.id,
          ),
        );
      }
    }
  }
}

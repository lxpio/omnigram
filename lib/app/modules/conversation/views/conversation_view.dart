import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:omnigram/app/core/app_view_mixin.dart';
import 'package:omnigram/app/views/app_cell.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/conversation_controller.dart';

class ConversationView extends StatelessWidget
    with AppViewMixin<ConversationController> {
  static const titleWidth = 80.0;
  const ConversationView({Key? key}) : super(key: key);

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      actions: controller.editing
          ? [
              TextButton(
                onPressed: controller.onSaved,
                child: Text(
                  'save'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ]
          : [
              IconButton(
                onPressed: controller.onEdited,
                icon: const Icon(Icons.edit),
              ),
            ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    if (controller.service == null) return Container();

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        // ServiceInfo(
        //   provider: controller.provider!,
        // ),
        AppCell(
          title: SizedBox(
            width: 80,
            child: Text(
              'conversation_name'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // detail: TextField(controller.conversation?.name ?? ''),
          detail: TextField(
            minLines: 1,
            maxLines: 1,
            autocorrect: true,
            enabled: controller.editing,
            focusNode: controller.nameFocusNode,
            controller: controller.conversationNameTextEditingController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration.collapsed(
              hintText: 'type_your_tokens'.trParams({'name': 'API URL'}),
            ),
            textInputAction: TextInputAction.next,
          ),
          hiddenDivider: true,
        ),
        const SizedBox(
          height: 8,
        ),
        AppCell.textFieldTile(
          title: SizedBox(
            width: 80,
            child: Text("max_tokens".tr ?? ''),
          ),
          enabled: controller.editing,
          controller: controller.maxTokensTextEditingController,
          textInputAction: TextInputAction.next,
        ),
        AppCell.textFieldTile(
          title: SizedBox(
            width: 80,
            child: Text('timeout'.tr ?? ''),
          ),
          enabled: controller.editing,
          controller: controller.timeoutTextEditingController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(
          height: 8,
        ),
        if (controller.service?.helpUrl?.isNotEmpty == true)
          AppCell.navigation(
            title: SizedBox(
              width: titleWidth,
              child: Text(
                'Get Help',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            hiddenDivider: true,
            onPressed: () {
              launchUrlString(controller.service!.helpUrl!);
            },
          ),
      ],
    );
  }
}

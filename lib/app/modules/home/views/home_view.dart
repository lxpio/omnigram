import 'package:omnigram/app/core/app_view_mixin.dart';
import 'package:omnigram/app/modules/home/views/home_drawer.dart';
import 'package:omnigram/app/views/chat_input.dart';
import 'package:omnigram/app/views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'home_cmd.dart';

class HomeView extends StatelessWidget with AppViewMixin<HomeController> {
  @override
  bool get bottomSafeArea => true;

  @override
  Color? get systemNavigationBarColor =>
      Theme.of(context).appBarTheme.backgroundColor;

  final GlobalKey _textFieldKey = GlobalKey();

  HomeView({Key? key}) : super(key: key);

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 2,
        ),
      ),
      elevation: 0,
      leading: Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
            controller.focusNode.unfocus();
          },
          icon: const Icon(Icons.menu),
        );
      }),
      title: Text(
        controller.currentConversation?.displayName ?? 'new_chat'.tr,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      centerTitle: true,
      titleSpacing: 0,
      actions: [
        IconButton(
          onPressed: controller.toConversation,
          icon: const Icon(
            Icons.add,
            size: 25,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) => Column(
        children: [
          Expanded(
            child: ChatView(
              messages: controller.messages,
              controller: controller.scroll,
              onRetried: controller.onRetried,
              onAvatarClicked: controller.onAvatarClicked,
              onQuoted: controller.onQuoted,
            ),
          ),
          // CommandMenuWidget(isMenuVisible: controller.isMenuVisible),
          ChatInput(
            key: _textFieldKey,
            focusNode: controller.focusNode,
            controller: controller.textEditing,
            onSubmitted: controller.onSubmitted,
            onChanged: (String text) {
              if (text == '/') {
                _showMenuOverlay(context);
              } else {
                removeHighlightOverlay();
              }
            },
            onCommand: () {
              controller.changeInputText('/');
              _showMenuOverlay(context);
            },
            quoteMessage: controller.currentQuotedMessage,
            onCleared: controller.onCleared,
          ),
        ],
      );

  @override
  Widget? buildDrawer() => const HomeDrawer();

  OverlayEntry? overlayEntry;

  // Remove the OverlayEntry.
  void removeHighlightOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showMenuOverlay(BuildContext context) {
    final RenderBox textFieldRenderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final textFieldPosition = textFieldRenderBox.localToGlobal(Offset.zero);
    removeHighlightOverlay();
    // commandController.showMenu(textFieldPosition.dy + textFieldRenderBox.size.height);
    overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
            onTap: () {
              removeHighlightOverlay();
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned(
                  left: textFieldPosition.dx,
                  top: (textFieldPosition.dy) - 32 * 2 - 65,
                  width: textFieldRenderBox.size.width,
                  child: CommandMenuView(onCommand: _handleCommand),
                ),
              ],
            )));

    Overlay.of(context).insert(overlayEntry!);
  }

  Future<void> _handleCommand(String commandTitle) async {
    controller.changeInputText(commandTitle);
    // Implement your logic to handle the selected command
    print('Command tapped: $commandTitle');
    removeHighlightOverlay();

    controller.onSubmitted();
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/chat/conversation_screen.dart';

class ChatPageBody extends StatefulWidget {
  static String get routeName => 'chat';
  static String get routeLocation => '/chat';

  const ChatPageBody({Key? key}) : super(key: key);

  @override
  State createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody> {
  @override
  Widget build(BuildContext context) {
    return ConversationList();
  }
}

import 'package:omnigram/widgets/ai/ai_chat_stream.dart';
import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: AiChatStream(),
      ),
    );
  }
}

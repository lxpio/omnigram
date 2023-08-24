import 'llmchain.dart';

class ChatGPT3 extends LLMChain {
  ChatGPT3({
    super.model = 'gpt-3.5-turbo-0301',
    super.name = 'open_ai_chat_gpt',
    super.avatar = 'assets/images/ai_avatar.png',
  });
}

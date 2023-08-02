import 'package:omnigram/app/providers/llmchain/llmchain.dart';

class LongChat extends LLMChain {
  LongChat({
    super.model = 'gpt-3.5-turbo-0301',
    super.name = 'longchat',
    // super.id = 'open_ai_chat_gpt',
    super.avatar = 'assets/images/ai_avatar.png',
  });
}

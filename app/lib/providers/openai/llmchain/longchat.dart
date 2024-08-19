import 'llmchain.dart';

class LongChat extends LLMChain {
  LongChat({
    super.name = 'longchat',
    super.model = 'vicuna-13b-v1.5-16k',
    super.avatar = 'assets/images/ai_avatar.png',
    super.apiUrl = 'http://127.0.0.1:8088/v1/',
  });
}

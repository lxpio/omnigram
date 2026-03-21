enum AiChatDisplayMode {
  adaptive('adaptive'),
  split('split'),
  popup('popup');

  final String code;

  const AiChatDisplayMode(this.code);

  static AiChatDisplayMode fromCode(String code) {
    switch (code) {
      case 'adaptive':
        return AiChatDisplayMode.adaptive;
      case 'split':
        return AiChatDisplayMode.split;
      case 'popup':
        return AiChatDisplayMode.popup;
      default:
        return AiChatDisplayMode.adaptive;
    }
  }
}

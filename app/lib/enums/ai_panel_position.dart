enum AiPanelPositionEnum {
  right('right'),
  bottom('bottom');

  final String code;

  const AiPanelPositionEnum(this.code);

  static AiPanelPositionEnum fromCode(String code) {
    switch (code) {
      case 'right':
        return AiPanelPositionEnum.right;
      case 'bottom':
        return AiPanelPositionEnum.bottom;
      default:
        return AiPanelPositionEnum.right;
    }
  }
}

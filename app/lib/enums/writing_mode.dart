enum WritingModeEnum {
  auto('auto'),
  verticalRl('vertical-rl'),
  verticalLr('vertical-lr'),
  horizontalTb('horizontal-tb'),
  horizontalLr('horizontal-lr');

  const WritingModeEnum(this.code);

  final String code;

  static WritingModeEnum fromCode(String code) {
    return WritingModeEnum.values
        .firstWhere((e) => e.code == code, orElse: () => WritingModeEnum.auto);
  }

  bool get isVertical =>
      this == WritingModeEnum.verticalRl || this == WritingModeEnum.verticalLr;

  bool get isHorizontal =>
      this == WritingModeEnum.horizontalTb ||
      this == WritingModeEnum.horizontalLr;
}

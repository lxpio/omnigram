enum BgimgFitEnum {
  cover('cover'),
  stretch('stretch');

  const BgimgFitEnum(this.code);

  final String code;

  static BgimgFitEnum fromCode(String code) {
    return BgimgFitEnum.values.firstWhere((e) => e.code == code);
  }
}

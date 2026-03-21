enum PageTurnMode {
  simple('simple'),
  custom('custom');

  final String code;

  const PageTurnMode(this.code);

  static PageTurnMode fromCode(String code) {
    return PageTurnMode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PageTurnMode.simple,
    );
  }
}

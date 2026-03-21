enum BgimgThemeMode {
  day('day'),
  night('night');

  final String code;
  const BgimgThemeMode(this.code);

  static BgimgThemeMode fromCode(String code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => BgimgThemeMode.day,
    );
  }
}

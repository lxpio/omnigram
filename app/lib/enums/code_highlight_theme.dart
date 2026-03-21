/// Code syntax highlight theme options
enum CodeHighlightThemeEnum {
  /// No highlighting (basic monospace styling only)
  off('off'),

  // Light themes
  /// Prism default theme (light)
  defaultTheme('default'),

  /// GitHub style theme
  github('github'),

  /// One Light theme (Atom inspired)
  oneLight('one-light'),

  /// Material Design light theme
  materialLight('material-light'),

  // Dark themes
  /// VS Code Dark+ theme
  vsDark('vs-dark'),

  /// One Dark theme (Atom inspired)
  oneDark('one-dark'),

  /// Dracula theme (purple tones)
  dracula('dracula'),

  /// Material Design dark theme
  materialDark('material-dark'),

  /// Nord theme (cool blue tones)
  nord('nord'),

  /// Night Owl theme
  nightOwl('night-owl'),

  /// Solarized Dark theme
  solarizedDark('solarized-dark'),

  /// Atom Dark theme
  atomDark('atom-dark');

  const CodeHighlightThemeEnum(this.code);

  final String code;

  /// Get theme from code string
  static CodeHighlightThemeEnum fromCode(String code) {
    return CodeHighlightThemeEnum.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CodeHighlightThemeEnum.defaultTheme,
    );
  }

  /// Check if this is a light theme
  bool get isLight => [
        defaultTheme,
        github,
        oneLight,
        materialLight,
      ].contains(this);

  /// Check if this is a dark theme
  bool get isDark => !isLight && this != off;

  /// Get display name for the theme
  String get displayName {
    switch (this) {
      case off:
        return 'Off';
      case defaultTheme:
        return 'Default';
      case github:
        return 'GitHub';
      case oneLight:
        return 'One Light';
      case materialLight:
        return 'Material Light';
      case vsDark:
        return 'VS Dark';
      case oneDark:
        return 'One Dark';
      case dracula:
        return 'Dracula';
      case materialDark:
        return 'Material Dark';
      case nord:
        return 'Nord';
      case nightOwl:
        return 'Night Owl';
      case solarizedDark:
        return 'Solarized Dark';
      case atomDark:
        return 'Atom Dark';
    }
  }

  /// Get CSS filename for the theme
  String get cssFileName {
    if (this == off) return '';
    if (this == defaultTheme) return 'prism-default.min.css';
    return 'prism-$code.min.css';
  }
}

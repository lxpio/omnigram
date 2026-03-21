class TtsVoice {
  /// Unique identifier or short name used for API calls
  final String shortName;

  /// Display name primarily for user interface
  final String name;

  /// Locale code (e.g., en-US)
  final String locale;

  /// Gender (Male, Female, or other/unknown)
  final String gender;

  /// Optional description for display
  final String description;

  /// Optional raw data for extra properties
  final Map<String, dynamic>? rawData;

  const TtsVoice({
    required this.shortName,
    required this.name,
    required this.locale,
    this.gender = '',
    this.description = '',
    this.rawData,
  });

  factory TtsVoice.fromMap(Map<String, dynamic> map) {
    return TtsVoice(
      shortName: map['ShortName'] ?? '',
      name: map['FriendlyName'] ?? map['Name'] ?? map['ShortName'] ?? '',
      locale: map['Locale'] ?? map['locale'] ?? '',
      gender: map['Gender'] ?? '',
      description: map['Description'] ?? map['description'] ?? '',
      rawData: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ShortName': shortName,
      'FriendlyName': name,
      'Locale': locale,
      'Gender': gender,
      'Description': description,
      ...rawData ?? {},
    };
  }
}

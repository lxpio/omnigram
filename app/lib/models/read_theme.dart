import 'dart:convert';
import 'dart:core';

class ReadTheme {
  int? id;
  String backgroundColor;
  String textColor;
  String backgroundImagePath;

  ReadTheme(
      {this.id,
      required this.backgroundColor,
      required this.textColor,
      required this.backgroundImagePath});

  Map<String, Object?> toMap() {
    return {
      'background_color': backgroundColor,
      'text_color': textColor,
      'background_image_path': backgroundImagePath
    };
  }

  String toJson() {
    return '''
    {
      "id": $id,
      "backgroundColor": "$backgroundColor",
      "textColor": "$textColor",
      "backgroundImagePath": "$backgroundImagePath"
    }
    ''';
  }

  factory ReadTheme.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return ReadTheme(
        id: data['id'],
        backgroundColor: data['backgroundColor'],
        textColor: data['textColor'],
        backgroundImagePath: data['backgroundImagePath']);
  }

  factory ReadTheme.fromDb(Map<String, dynamic> map) {
    return ReadTheme(
      id: map['id'] as int?,
      backgroundColor: map['background_color'] as String? ?? 'FFFBFBF3',
      textColor: map['text_color'] as String? ?? 'FF343434',
      backgroundImagePath: map['background_image_path'] as String? ?? '',
    );
  }
}

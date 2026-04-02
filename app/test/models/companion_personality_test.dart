import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/companion_personality.dart';

void main() {
  group('CompanionPersonality defaults', () {
    test('default toggles: crossBookAlerts and autoKnowledgeGraph true, rest false', () {
      const p = CompanionPersonality();
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.crossBookAlerts, true);
      expect(p.postChapterQuestions, false);
      expect(p.autoKnowledgeGraph, true);
    });

    test('default name, sliders unchanged', () {
      const p = CompanionPersonality();
      expect(p.name, 'TARS');
      expect(p.warmth, 50);
    });
  });

  group('CompanionPresets', () {
    test('silent preset: all toggles off', () {
      final p = CompanionPresets.silent();
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.crossBookAlerts, false);
      expect(p.postChapterQuestions, false);
      expect(p.autoKnowledgeGraph, false);
    });

    test('buddy preset: implemented features on', () {
      final p = CompanionPresets.buddy();
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.postChapterQuestions, false);
    });

    test('scholar preset: implemented features on', () {
      final p = CompanionPresets.scholar();
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
      expect(p.annotateHardWords, false);
      expect(p.postChapterQuestions, false);
    });
  });

  group('JSON round-trip', () {
    test('toJson includes toggle fields', () {
      const p = CompanionPersonality(crossBookAlerts: false);
      final json = p.toJson();
      expect(json['crossBookAlerts'], false);
      expect(json['autoKnowledgeGraph'], true);
    });

    test('fromJson restores toggle fields', () {
      final p = CompanionPersonality.fromJson({
        'name': 'TARS',
        'crossBookAlerts': false,
        'autoKnowledgeGraph': false,
      });
      expect(p.crossBookAlerts, false);
      expect(p.autoKnowledgeGraph, false);
    });

    test('fromJson with missing toggle fields uses defaults', () {
      final p = CompanionPersonality.fromJson({'name': 'TARS'});
      expect(p.crossBookAlerts, true);
      expect(p.autoKnowledgeGraph, true);
      expect(p.autoChapterRecap, false);
    });
  });
}

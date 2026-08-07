import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/content/theory_content_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_interval_facts.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';

void main() {
  final requiredIds = <String>{
    for (final lesson in TheoryLibrary.lessons) ...lesson.textIds,
    for (final interval in TheoryInterval.values) ...[
      interval.nameId,
      interval.qualityId,
    ],
  };

  test('every lesson identifier resolves in every supported language', () {
    for (final content in TheoryContentLibrary.supported) {
      final missing = [
        for (final id in requiredIds)
          if (!content.contains(id)) id,
      ]..sort();
      expect(
        missing,
        isEmpty,
        reason:
            '${content.languageCode} is missing ${missing.length} entries: '
            '${missing.take(30).join(', ')}',
      );
    }
  });

  test('languages define the same identifiers', () {
    final english = TheoryContentLibrary.forLanguageCode(
      'en',
    ).entries.keys.toSet();
    final turkish = TheoryContentLibrary.forLanguageCode(
      'tr',
    ).entries.keys.toSet();
    expect(
      (english.difference(turkish).toList()..sort()).take(30),
      isEmpty,
      reason: 'Turkish is missing entries that English defines.',
    );
    expect(
      (turkish.difference(english).toList()..sort()).take(30),
      isEmpty,
      reason: 'Turkish defines entries that English does not.',
    );
  });

  test('no content entry is empty or left as its identifier', () {
    for (final content in TheoryContentLibrary.supported) {
      for (final entry in content.entries.entries) {
        expect(
          entry.value.trim(),
          isNotEmpty,
          reason: '${content.languageCode}: ${entry.key} is empty',
        );
        expect(
          entry.value,
          isNot(equals(entry.key)),
          reason: '${content.languageCode}: ${entry.key} was left untranslated',
        );
      }
    }
  });
}

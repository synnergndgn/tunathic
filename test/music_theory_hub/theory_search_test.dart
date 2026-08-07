import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/music_theory/content/theory_content_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_search.dart';

void main() {
  final english = TheoryContentLibrary.forLanguageCode('en');
  final turkish = TheoryContentLibrary.forLanguageCode('tr');

  List<String> search(String query, {level, content}) => [
    for (final lesson in TheorySearch.query(
      lessons: TheoryLibrary.lessons,
      content: content ?? english,
      query: query,
      level: level,
    ))
      lesson.id,
  ];

  test('an empty query returns the whole catalog in authored order', () {
    final results = search('');
    expect(results, hasLength(TheoryLibrary.lessons.length));
    expect(results.first, TheoryLibrary.lessons.first.id);
  });

  test('titles rank above summaries', () {
    final results = search('tritone');
    expect(results.first, 'interval-tritone');
  });

  test('aliases match shorthand a reader would actually type', () {
    expect(search('m7b5'), contains('diminished-chords'));
    expect(search('p5'), contains('interval-perfect-fifth'));
    expect(search('caged'), contains('caged-system'));
    expect(search('dadgad'), contains('alternate-tunings'));
    expect(search('6/8'), contains('time-signatures'));
  });

  test('keywords find a lesson the title does not name', () {
    expect(search('nashville'), contains('roman-numerals'));
    expect(search('amen'), contains('cadences'));
  });

  test('search is case insensitive and ignores surrounding whitespace', () {
    expect(search('  TRIADS  '), contains('triads'));
  });

  test('Turkish content is searchable in Turkish, with folded letters', () {
    expect(search('aralık', content: turkish), contains('interval-basics'));
    expect(search('akor', content: turkish), contains('triads'));
    expect(search('donanım', content: turkish), contains('key-signatures'));
    expect(
      search('donanim', content: turkish),
      contains('key-signatures'),
      reason: 'Turkish letters must fold so an ASCII keyboard still matches.',
    );
    expect(search('üçlü', content: turkish), contains('triads'));
  });

  test('the level filter narrows results without changing matching', () {
    final all = search('scale');
    final advanced = search('scale', level: TheoryLevel.advanced);
    expect(advanced.length, lessThan(all.length));
    for (final id in advanced) {
      expect(TheoryLibrary.byId(id)!.level, TheoryLevel.advanced);
    }
  });

  test('a level with no query still filters the catalog', () {
    final beginner = search('', level: TheoryLevel.beginner);
    expect(beginner, isNotEmpty);
    for (final id in beginner) {
      expect(TheoryLibrary.byId(id)!.level, TheoryLevel.beginner);
    }
  });

  test('nonsense finds nothing rather than guessing', () {
    expect(search('zzzzqqqq'), isEmpty);
  });

  test('normalisation folds accents, case, and repeated whitespace', () {
    expect(TheorySearch.normalize('  Küçük   ARALIK '), 'kucuk aralik');
    expect(TheorySearch.normalize('B♭'), 'bb');
  });

  test('ranking is stable for equally scored lessons', () {
    final first = search('chord');
    final second = search('chord');
    expect(first, orderedEquals(second));
  });
}

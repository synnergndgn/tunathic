import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/scale_library/domain/scale_search_parser.dart';

void main() {
  test('parses supported English roots, accidentals, names, and aliases', () {
    expect(
      ScaleSearchParser.tryParse('C major')?.definition,
      ScaleDefinition.major,
    );
    expect(ScaleSearchParser.tryParse('Bb major')?.root.symbol, 'Bb');
    expect(
      ScaleSearchParser.tryParse('F# minor')?.definition,
      ScaleDefinition.naturalMinor,
    );
    expect(
      ScaleSearchParser.tryParse('D Dorian')?.definition,
      ScaleDefinition.dorian,
    );
    expect(
      ScaleSearchParser.tryParse('A aeolian')?.definition,
      ScaleDefinition.naturalMinor,
    );
  });

  test('parses the supported Turkish vocabulary', () {
    expect(
      ScaleSearchParser.tryParse('Do majör')?.definition,
      isNull,
      reason: 'Localized note syllables are not part of standard symbols.',
    );
    expect(
      ScaleSearchParser.tryParse('C majör')?.definition,
      ScaleDefinition.major,
    );
    expect(
      ScaleSearchParser.tryParse('A doğal minör')?.definition,
      ScaleDefinition.naturalMinor,
    );
    expect(
      ScaleSearchParser.tryParse('D doryen')?.definition,
      ScaleDefinition.dorian,
    );
    expect(
      ScaleSearchParser.tryParse('C İYONYEN')?.definition,
      ScaleDefinition.major,
    );
  });

  test('rejects unsupported, fuzzy, and incomplete syntax', () {
    expect(ScaleSearchParser.tryParse('C'), isNull);
    expect(ScaleSearchParser.tryParse('C whole tone'), isNull);
    expect(ScaleSearchParser.tryParse('major C'), isNull);
    expect(ScaleSearchParser.tryParse('best scale for C'), isNull);
  });
}

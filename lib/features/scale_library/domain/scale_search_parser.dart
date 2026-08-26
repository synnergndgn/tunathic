import 'package:tunathic/core/music_theory/music_theory.dart';

final class ParsedScaleSearch {
  const ParsedScaleSearch({required this.root, required this.definition});

  final SpelledPitchClass root;
  final ScaleDefinition definition;
}

abstract final class ScaleSearchParser {
  static const _names = <String, ScaleDefinition>{
    'major': ScaleDefinition.major,
    'majör': ScaleDefinition.major,
    'ionian': ScaleDefinition.major,
    'iyonyen': ScaleDefinition.major,
    'minor': ScaleDefinition.naturalMinor,
    'natural minor': ScaleDefinition.naturalMinor,
    'minör': ScaleDefinition.naturalMinor,
    'doğal minör': ScaleDefinition.naturalMinor,
    'aeolian': ScaleDefinition.naturalMinor,
    'eolyen': ScaleDefinition.naturalMinor,
    'harmonic minor': ScaleDefinition.harmonicMinor,
    'armonik minör': ScaleDefinition.harmonicMinor,
    'melodic minor': ScaleDefinition.melodicMinor,
    'melodik minör': ScaleDefinition.melodicMinor,
    'dorian': ScaleDefinition.dorian,
    'doryen': ScaleDefinition.dorian,
    'phrygian': ScaleDefinition.phrygian,
    'frigyen': ScaleDefinition.phrygian,
    'lydian': ScaleDefinition.lydian,
    'lidyen': ScaleDefinition.lydian,
    'mixolydian': ScaleDefinition.mixolydian,
    'miksolidyen': ScaleDefinition.mixolydian,
    'locrian': ScaleDefinition.locrian,
    'lokriyen': ScaleDefinition.locrian,
    'major pentatonic': ScaleDefinition.majorPentatonic,
    'majör pentatonik': ScaleDefinition.majorPentatonic,
    'minor pentatonic': ScaleDefinition.minorPentatonic,
    'minör pentatonik': ScaleDefinition.minorPentatonic,
    'blues': ScaleDefinition.blues,
  };

  static ParsedScaleSearch? tryParse(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    final match = RegExp(
      r'^([A-Ga-g](?:#|b|♯|♭)?)\s+(.+)$',
    ).firstMatch(normalized);
    if (match == null) return null;

    final root = SpelledPitchClass.tryParse(match.group(1)!);
    final scaleName = match.group(2)!.toLowerCase().replaceAll('i\u0307', 'i');
    final definition = _names[scaleName];
    if (root == null || definition == null) return null;
    return ParsedScaleSearch(root: root, definition: definition);
  }
}

import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';

/// How transposed chords should be spelled.
enum SheetSpelling { auto, sharps, flats }

enum SongLineKind { lyrics, section, blank }

/// A chord as printed above a lyric fragment.
final class ChordAnnotation {
  const ChordAnnotation({
    required this.text,
    this.symbol,
    this.sourceStart = 0,
    this.sourceEnd = 0,
  });

  /// The chord exactly as it should be displayed.
  final String text;

  /// The interpreted symbol, or null when the bracket text is not a chord.
  final WrittenChordSymbol? symbol;

  /// Index of `[` for this chord in the source text.
  final int sourceStart;

  /// Index just past `]` for this chord in the source text.
  final int sourceEnd;

  ChordAnnotation transpose(int semitones, SpellingPreference preference) {
    final source = symbol;
    if (source == null || semitones == 0) return this;
    final transposed = source.transpose(semitones, preference: preference);
    // Transposition never rewrites the stored text, so the source span of the
    // bracket this chord came from still applies.
    return ChordAnnotation(
      text: transposed.symbol,
      symbol: transposed,
      sourceStart: sourceStart,
      sourceEnd: sourceEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChordAnnotation &&
      text == other.text &&
      symbol == other.symbol &&
      sourceStart == other.sourceStart &&
      sourceEnd == other.sourceEnd;

  @override
  int get hashCode => Object.hash(text, symbol, sourceStart, sourceEnd);

  @override
  String toString() => text;
}

/// A lyric fragment with the chord that starts it, if any.
final class SongSheetSegment {
  const SongSheetSegment({this.chord, this.lyrics = '', this.lyricsOffset = 0});

  final ChordAnnotation? chord;
  final String lyrics;

  /// Index in the source text where [lyrics] begins, so the presentation layer
  /// can place a new chord bracket on any word.
  final int lyricsOffset;

  SongSheetSegment transpose(int semitones, SpellingPreference preference) =>
      SongSheetSegment(
        chord: chord?.transpose(semitones, preference),
        lyrics: lyrics,
        lyricsOffset: lyricsOffset,
      );

  @override
  bool operator ==(Object other) =>
      other is SongSheetSegment &&
      chord == other.chord &&
      lyrics == other.lyrics &&
      lyricsOffset == other.lyricsOffset;

  @override
  int get hashCode => Object.hash(chord, lyrics, lyricsOffset);
}

final class SongSheetLine {
  const SongSheetLine({
    required this.kind,
    this.segments = const [],
    this.label = '',
    this.sourceStart = 0,
    this.sourceEnd = 0,
  });

  const SongSheetLine.blank({int sourceStart = 0})
    : this(
        kind: SongLineKind.blank,
        sourceStart: sourceStart,
        sourceEnd: sourceStart,
      );

  const SongSheetLine.section(String label)
    : this(kind: SongLineKind.section, label: label);

  final SongLineKind kind;
  final List<SongSheetSegment> segments;

  /// The section heading text, for [SongLineKind.section] lines.
  final String label;

  /// Index in the source text where this line begins.
  final int sourceStart;

  /// Index in the source text just past the end of this line, where a chord
  /// can be appended after the last word or onto an empty line.
  final int sourceEnd;

  bool get hasChords => segments.any((segment) => segment.chord != null);

  String get lyrics => segments.map((segment) => segment.lyrics).join();

  SongSheetLine transpose(int semitones, SpellingPreference preference) =>
      kind == SongLineKind.lyrics
      ? SongSheetLine(
          kind: kind,
          label: label,
          sourceStart: sourceStart,
          sourceEnd: sourceEnd,
          segments: [
            for (final segment in segments)
              segment.transpose(semitones, preference),
          ],
        )
      : this;
}

/// A parsed, renderable chord chart.
final class SongSheet {
  const SongSheet(this.lines);

  static const empty = SongSheet([]);

  final List<SongSheetLine> lines;

  bool get isEmpty => lines.every((line) => line.kind == SongLineKind.blank);

  /// The first chord of the chart, used as the reference key.
  WrittenChordSymbol? get leadingChord {
    for (final line in lines) {
      for (final segment in line.segments) {
        final symbol = segment.chord?.symbol;
        if (symbol != null) return symbol;
      }
    }
    return null;
  }

  /// Every distinct chord in the chart, in reading order.
  List<String> get chordSymbols {
    final seen = <String>[];
    for (final line in lines) {
      for (final segment in line.segments) {
        final chord = segment.chord;
        if (chord == null || seen.contains(chord.text)) continue;
        seen.add(chord.text);
      }
    }
    return seen;
  }

  SongSheet transpose(
    int semitones, {
    SheetSpelling spelling = SheetSpelling.auto,
  }) {
    if (semitones == 0 && spelling == SheetSpelling.auto) return this;
    final preference = spellingPreference(semitones, spelling);
    return SongSheet([
      for (final line in lines) line.transpose(semitones, preference),
    ]);
  }

  /// Resolves the accidental style for a transposed chart.
  ///
  /// Automatic spelling follows the transposed reference key: keys that are
  /// conventionally written with flats keep flats, everything else uses sharps.
  /// A whole chart therefore stays in one accidental style instead of mixing
  /// C# with Eb.
  SpellingPreference spellingPreference(int semitones, SheetSpelling spelling) {
    switch (spelling) {
      case SheetSpelling.sharps:
        return SpellingPreference.sharps;
      case SheetSpelling.flats:
        return SpellingPreference.flats;
      case SheetSpelling.auto:
        final reference = leadingChord?.root.pitchClass.transpose(semitones);
        if (reference == null) return SpellingPreference.sharps;
        return _flatKeys.contains(reference)
            ? SpellingPreference.flats
            : SpellingPreference.sharps;
    }
  }

  static const _flatKeys = {
    PitchClass.f,
    PitchClass.aSharpBFlat,
    PitchClass.dSharpEFlat,
    PitchClass.gSharpAFlat,
    PitchClass.cSharpDFlat,
    PitchClass.fSharpGFlat,
  };
}

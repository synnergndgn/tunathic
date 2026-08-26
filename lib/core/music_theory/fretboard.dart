import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/interval.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/core/music_theory/scale.dart';

/// An octave-aware pitch using the scientific-pitch octave convention.
final class OctaveNote {
  const OctaveNote({
    required this.pitchClass,
    required this.octave,
    required this.midiNote,
  });

  final PitchClass pitchClass;
  final int octave;
  final int midiNote;
}

/// One structurally represented guitar string, ordered low to high.
final class GuitarStringTuning {
  const GuitarStringTuning({
    required this.index,
    required this.label,
    required this.openPitch,
    required this.openOctave,
    required this.openMidiNote,
  });

  final int index;
  final String label;
  final SpelledPitchClass openPitch;
  final int openOctave;
  final int openMidiNote;

  OctaveNote noteAt(int fret) {
    if (fret < 0 || fret > GuitarFretboard.maximumSupportedFret) {
      throw RangeError.range(
        fret,
        0,
        GuitarFretboard.maximumSupportedFret,
        'fret',
      );
    }
    final midiNote = openMidiNote + fret;
    return OctaveNote(
      pitchClass: openPitch.pitchClass.transpose(fret),
      octave: (midiNote ~/ 12) - 1,
      midiNote: midiNote,
    );
  }
}

/// A tuning is data, rather than fretboard-specific branching, so more tunings
/// can be supplied later without changing transposition logic.
final class GuitarTuning {
  const GuitarTuning({required this.id, required this.strings});

  final String id;
  final List<GuitarStringTuning> strings;

  static const standard = GuitarTuning(
    id: 'standard',
    strings: [
      GuitarStringTuning(
        index: 0,
        label: 'E2',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.natural,
        ),
        openOctave: 2,
        openMidiNote: 40,
      ),
      GuitarStringTuning(
        index: 1,
        label: 'A2',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.natural,
        ),
        openOctave: 2,
        openMidiNote: 45,
      ),
      GuitarStringTuning(
        index: 2,
        label: 'D3',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.d,
          accidental: Accidental.natural,
        ),
        openOctave: 3,
        openMidiNote: 50,
      ),
      GuitarStringTuning(
        index: 3,
        label: 'G3',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.natural,
        ),
        openOctave: 3,
        openMidiNote: 55,
      ),
      GuitarStringTuning(
        index: 4,
        label: 'B3',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.b,
          accidental: Accidental.natural,
        ),
        openOctave: 3,
        openMidiNote: 59,
      ),
      GuitarStringTuning(
        index: 5,
        label: 'E4',
        openPitch: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.natural,
        ),
        openOctave: 4,
        openMidiNote: 64,
      ),
    ],
  );
}

/// The active theory identity for one highlighted pitch class.
final class FretboardRelation {
  const FretboardRelation({
    required this.pitch,
    required this.symbol,
    required this.isRoot,
  });

  final SpelledPitchClass pitch;
  final String symbol;
  final bool isRoot;
}

/// A chord or scale projected to pitch-class membership.
final class FretboardProjection {
  FretboardProjection._({
    required this.root,
    required Map<PitchClass, FretboardRelation> relations,
  }) : relations = Map.unmodifiable(relations);

  final SpelledPitchClass root;
  final Map<PitchClass, FretboardRelation> relations;

  factory FretboardProjection.chord({
    required SpelledPitchClass root,
    required ChordQuality quality,
  }) {
    final chord = ChordConstructor.construct(root: root, quality: quality);
    return FretboardProjection._(
      root: root,
      relations: {
        for (var index = 0; index < chord.tones.length; index++)
          chord.tones[index].pitchClass: FretboardRelation(
            pitch: chord.tones[index],
            symbol: chordDegreeSymbol(quality.formula[index]),
            isRoot: index == 0,
          ),
      },
    );
  }

  factory FretboardProjection.scale({
    required SpelledPitchClass root,
    required ScaleDefinition definition,
  }) {
    final scale = ScaleConstructor.construct(
      root: root,
      definition: definition,
    );
    return FretboardProjection._(
      root: root,
      relations: {
        for (var index = 0; index < scale.tones.length; index++)
          scale.tones[index].pitchClass: FretboardRelation(
            pitch: scale.tones[index],
            symbol: definition.degrees[index].symbol,
            isRoot: index == 0,
          ),
      },
    );
  }
}

/// One deterministic point on a projected fretboard.
final class FretPosition {
  const FretPosition({
    required this.stringIndex,
    required this.stringLabel,
    required this.fret,
    required this.note,
    required this.relation,
  });

  final int stringIndex;
  final String stringLabel;
  final int fret;
  final OctaveNote note;
  final FretboardRelation? relation;

  PitchClass get pitchClass => note.pitchClass;
  int get octave => note.octave;
  int get midiNote => note.midiNote;
  bool get isMember => relation != null;
  bool get isRoot => relation?.isRoot ?? false;
  String? get relationshipSymbol => relation?.symbol;
  SpelledPitchClass? get displayedPitch => relation?.pitch;
}

/// Pure fret derivation for an injected structural tuning.
final class GuitarFretboard {
  const GuitarFretboard({this.tuning = GuitarTuning.standard});

  static const maximumSupportedFret = 24;

  final GuitarTuning tuning;

  List<FretPosition> project({
    required FretboardProjection projection,
    required int maximumFret,
  }) {
    if (maximumFret < 0 || maximumFret > maximumSupportedFret) {
      throw RangeError.range(
        maximumFret,
        0,
        maximumSupportedFret,
        'maximumFret',
      );
    }
    final positions = <FretPosition>[];
    for (final string in tuning.strings) {
      for (var fret = 0; fret <= maximumFret; fret++) {
        final note = string.noteAt(fret);
        positions.add(
          FretPosition(
            stringIndex: string.index,
            stringLabel: string.label,
            fret: fret,
            note: note,
            relation: projection.relations[note.pitchClass],
          ),
        );
      }
    }
    return List.unmodifiable(positions);
  }
}

/// Fretboard chord labels are sourced from structural interval identities.
String chordDegreeSymbol(TheoryInterval interval) => switch (interval) {
  TheoryInterval.perfectUnison || TheoryInterval.octave => '1',
  TheoryInterval.minorSecond => 'b2',
  TheoryInterval.majorSecond => '2',
  TheoryInterval.minorThird => 'b3',
  TheoryInterval.majorThird => '3',
  TheoryInterval.perfectFourth => '4',
  TheoryInterval.augmentedFourth => '#4',
  TheoryInterval.diminishedFifth => 'b5',
  TheoryInterval.perfectFifth => '5',
  TheoryInterval.minorSixth => 'b6',
  TheoryInterval.augmentedFifth => '#5',
  TheoryInterval.majorSixth => '6',
  TheoryInterval.diminishedSeventh => 'bb7',
  TheoryInterval.minorSeventh => 'b7',
  TheoryInterval.majorSeventh => '7',
  TheoryInterval.minorNinth => 'b9',
  TheoryInterval.majorNinth => '9',
  TheoryInterval.perfectEleventh => '11',
  TheoryInterval.majorThirteenth => '13',
};

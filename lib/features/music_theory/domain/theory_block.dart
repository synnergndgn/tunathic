import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

/// One renderable piece of a lesson.
///
/// Prose blocks hold a text identifier instead of a string, because lesson
/// copy is translated content resolved per locale. Every other block holds
/// structural values and is rendered by running the shared theory engine, so a
/// diagram can never drift from the note, chord, or scale it claims to show.
sealed class TheoryBlock {
  const TheoryBlock();
}

/// A paragraph of explanation.
final class TheoryParagraph extends TheoryBlock {
  const TheoryParagraph(this.textId);

  final String textId;
}

/// A titled subsection inside a longer lesson.
final class TheoryHeading extends TheoryBlock {
  const TheoryHeading(this.textId);

  final String textId;
}

/// A short list of points.
final class TheoryBullets extends TheoryBlock {
  const TheoryBullets(this.textIds);

  final List<String> textIds;
}

/// A label and value pair, such as a time signature and what it counts.
final class TheoryFact {
  const TheoryFact({required this.labelId, required this.valueId});

  final String labelId;
  final String valueId;
}

final class TheoryFacts extends TheoryBlock {
  const TheoryFacts(this.facts);

  final List<TheoryFact> facts;
}

/// A worked example built from a scale definition.
final class TheoryScaleExample extends TheoryBlock {
  const TheoryScaleExample({
    required this.root,
    required this.definition,
    this.captionId,
  });

  final SpelledPitchClass root;
  final ScaleDefinition definition;
  final String? captionId;

  ConstructedScale get scale =>
      ScaleConstructor.construct(root: root, definition: definition);
}

/// A worked example built from a chord quality.
final class TheoryChordExample extends TheoryBlock {
  const TheoryChordExample({
    required this.root,
    required this.quality,
    this.captionId,
  });

  final SpelledPitchClass root;
  final ChordQuality quality;
  final String? captionId;

  ConstructedChord get chord =>
      ChordConstructor.construct(root: root, quality: quality);
}

/// A chord shown as a stack of intervals above its root, used by the chord and
/// harmony lessons to make construction visible rather than asserted.
final class TheoryChordFormula extends TheoryBlock {
  const TheoryChordFormula(this.quality);

  final ChordQuality quality;
}

/// The complete profile of one interval: its size, its notes from a reference
/// root, and where the shape sits on the fretboard.
final class TheoryIntervalProfile extends TheoryBlock {
  const TheoryIntervalProfile({
    required this.interval,
    required this.root,
    this.enharmonic,
  });

  final TheoryInterval interval;
  final SpelledPitchClass root;

  /// The alternate spelling of the same distance, for the tritone lesson.
  final TheoryInterval? enharmonic;

  SpelledPitchClass get target => NoteSpelling.spellInterval(
    root: root,
    semitones: interval.semitones,
    diatonicSteps: interval.diatonicSteps,
  );
}

enum TheoryFretboardSubject { chord, scale }

/// A read-only fretboard window highlighting a chord or scale.
final class TheoryFretboardDiagram extends TheoryBlock {
  const TheoryFretboardDiagram.chord({
    required this.root,
    required ChordQuality this.quality,
    this.firstFret = 0,
    this.lastFret = 5,
    this.captionId,
  }) : subject = TheoryFretboardSubject.chord,
       definition = null;

  const TheoryFretboardDiagram.scale({
    required this.root,
    required ScaleDefinition this.definition,
    this.firstFret = 0,
    this.lastFret = 5,
    this.captionId,
  }) : subject = TheoryFretboardSubject.scale,
       quality = null;

  final TheoryFretboardSubject subject;
  final SpelledPitchClass root;
  final ChordQuality? quality;
  final ScaleDefinition? definition;
  final int firstFret;
  final int lastFret;
  final String? captionId;

  FretboardProjection get projection => switch (subject) {
    TheoryFretboardSubject.chord => FretboardProjection.chord(
      root: root,
      quality: quality!,
    ),
    TheoryFretboardSubject.scale => FretboardProjection.scale(
      root: root,
      definition: definition!,
    ),
  };
}

/// The diatonic chords of a key, with Roman numerals.
final class TheoryDiatonicTable extends TheoryBlock {
  const TheoryDiatonicTable({required this.key, this.sevenths = false});

  final MusicalKey key;
  final bool sevenths;

  DiatonicHarmony get harmony => DiatonicHarmonyConstructor.construct(key);

  List<DiatonicChord> get chords =>
      sevenths ? harmony.seventhChords : harmony.triads;
}

/// A short list of keys with their signatures, for the circle lessons.
final class TheoryKeySignatureTable extends TheoryBlock {
  const TheoryKeySignatureTable(this.keys);

  final List<MusicalKey> keys;
}

/// Relative durations, drawn to scale against one whole note.
final class TheoryNoteValue {
  const TheoryNoteValue({
    required this.nameId,
    required this.beats,
    required this.symbol,
  });

  final String nameId;

  /// Length in quarter-note beats.
  final double beats;

  /// A compact written form such as `1/4` or `1/8.`.
  final String symbol;
}

final class TheoryNoteValueChart extends TheoryBlock {
  const TheoryNoteValueChart(this.values);

  final List<TheoryNoteValue> values;
}

/// Open strings for one or more tunings, taken from the tuner's presets so the
/// lesson and the Guitar Tuner can never disagree about a tuning.
final class TheoryTuningTable extends TheoryBlock {
  const TheoryTuningTable(this.presets, {this.captionId});

  final List<TuningPreset> presets;
  final String? captionId;
}

/// A "Try it" button that opens a released tool on this lesson's example.
final class TheoryTryIt extends TheoryBlock {
  const TheoryTryIt(this.action);

  final TheoryAction action;
}

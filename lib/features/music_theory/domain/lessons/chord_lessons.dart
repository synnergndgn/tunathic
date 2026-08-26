import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

const chordLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'triads',
    category: TheoryCategory.chords,
    level: TheoryLevel.beginner,
    aliases: ['triad', 'major', 'minor', '1 3 5'],
    blocks: [
      TheoryParagraph('triads.p1'),
      TheoryChordFormula(ChordQuality.major),
      TheoryChordExample(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        captionId: 'triads.exampleMajor',
      ),
      TheoryChordFormula(ChordQuality.minor),
      TheoryChordExample(
        root: TheoryRoots.a,
        quality: ChordQuality.minor,
        captionId: 'triads.exampleMinor',
      ),
      TheoryParagraph('triads.p2'),
      TheoryBullets(['triads.b1', 'triads.b2', 'triads.b3']),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        captionId: 'triads.fretboard',
      ),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'seventh-chords',
    category: TheoryCategory.chords,
    level: TheoryLevel.intermediate,
    aliases: ['7', 'maj7', 'm7', 'dom7', 'seventh'],
    blocks: [
      TheoryParagraph('seventh-chords.p1'),
      TheoryChordFormula(ChordQuality.majorSeventh),
      TheoryChordFormula(ChordQuality.dominantSeventh),
      TheoryChordFormula(ChordQuality.minorSeventh),
      TheoryChordExample(
        root: TheoryRoots.g,
        quality: ChordQuality.dominantSeventh,
        captionId: 'seventh-chords.example',
      ),
      TheoryParagraph('seventh-chords.p2'),
      TheoryBullets([
        'seventh-chords.b1',
        'seventh-chords.b2',
        'seventh-chords.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.g,
          quality: ChordQuality.dominantSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'suspended-chords',
    category: TheoryCategory.chords,
    level: TheoryLevel.intermediate,
    aliases: ['sus', 'sus2', 'sus4', 'suspended'],
    blocks: [
      TheoryParagraph('suspended-chords.p1'),
      TheoryChordFormula(ChordQuality.suspendedSecond),
      TheoryChordFormula(ChordQuality.suspendedFourth),
      TheoryChordExample(
        root: TheoryRoots.d,
        quality: ChordQuality.suspendedFourth,
        captionId: 'suspended-chords.example',
      ),
      TheoryParagraph('suspended-chords.p2'),
      TheoryBullets([
        'suspended-chords.b1',
        'suspended-chords.b2',
        'suspended-chords.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.d,
          quality: ChordQuality.suspendedFourth,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'augmented-chords',
    category: TheoryCategory.chords,
    level: TheoryLevel.intermediate,
    aliases: ['aug', '+', '#5', 'augmented'],
    blocks: [
      TheoryParagraph('augmented-chords.p1'),
      TheoryChordFormula(ChordQuality.augmented),
      TheoryChordExample(
        root: TheoryRoots.c,
        quality: ChordQuality.augmented,
        captionId: 'augmented-chords.example',
      ),
      TheoryParagraph('augmented-chords.p2'),
      TheoryBullets([
        'augmented-chords.b1',
        'augmented-chords.b2',
        'augmented-chords.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.augmented,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'diminished-chords',
    category: TheoryCategory.chords,
    level: TheoryLevel.intermediate,
    aliases: ['dim', 'dim7', 'm7b5', 'half diminished', 'diminished'],
    blocks: [
      TheoryParagraph('diminished-chords.p1'),
      TheoryChordFormula(ChordQuality.diminished),
      TheoryChordFormula(ChordQuality.halfDiminishedSeventh),
      TheoryChordFormula(ChordQuality.diminishedSeventh),
      TheoryChordExample(
        root: TheoryRoots.b,
        quality: ChordQuality.halfDiminishedSeventh,
        captionId: 'diminished-chords.example',
      ),
      TheoryParagraph('diminished-chords.p2'),
      TheoryBullets([
        'diminished-chords.b1',
        'diminished-chords.b2',
        'diminished-chords.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.b,
          quality: ChordQuality.halfDiminishedSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'extended-chords',
    category: TheoryCategory.chords,
    level: TheoryLevel.advanced,
    aliases: ['9', '11', '13', 'add9', 'extended', 'tensions'],
    blocks: [
      TheoryParagraph('extended-chords.p1'),
      TheoryChordFormula(ChordQuality.dominantNinth),
      TheoryChordFormula(ChordQuality.eleventh),
      TheoryChordFormula(ChordQuality.thirteenth),
      TheoryChordExample(
        root: TheoryRoots.c,
        quality: ChordQuality.majorNinth,
        captionId: 'extended-chords.example',
      ),
      TheoryParagraph('extended-chords.p2'),
      TheoryBullets([
        'extended-chords.b1',
        'extended-chords.b2',
        'extended-chords.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.majorNinth,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'chord-inversions',
    category: TheoryCategory.chords,
    level: TheoryLevel.intermediate,
    aliases: ['inversion', 'slash chord', 'c/e', 'first inversion'],
    blocks: [
      TheoryParagraph('chord-inversions.p1'),
      TheoryChordExample(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        captionId: 'chord-inversions.example',
      ),
      TheoryBullets([
        'chord-inversions.b1',
        'chord-inversions.b2',
        'chord-inversions.b3',
      ]),
      TheoryParagraph('chord-inversions.p2'),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        firstFret: 0,
        lastFret: 7,
        captionId: 'chord-inversions.fretboard',
      ),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            root: TheoryRoots.c,
            chordQuality: ChordQuality.major,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'chord-voicings',
    category: TheoryCategory.chords,
    level: TheoryLevel.advanced,
    aliases: ['voicing', 'shell', 'drop 2', 'open voicing'],
    blocks: [
      TheoryParagraph('chord-voicings.p1'),
      TheoryParagraph('chord-voicings.p2'),
      TheoryBullets([
        'chord-voicings.b1',
        'chord-voicings.b2',
        'chord-voicings.b3',
      ]),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.g,
        quality: ChordQuality.majorSeventh,
        firstFret: 0,
        lastFret: 7,
        captionId: 'chord-voicings.fretboard',
      ),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.g,
          quality: ChordQuality.majorSeventh,
        ),
      ),
    ],
  ),
];

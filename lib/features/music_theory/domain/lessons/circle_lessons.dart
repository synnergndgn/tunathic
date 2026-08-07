import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

const circleLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'key-signatures',
    category: TheoryCategory.circleOfFifths,
    level: TheoryLevel.beginner,
    aliases: ['key signature', 'sharps order', 'flats order', 'fcgdaeb'],
    blocks: [
      TheoryParagraph('key-signatures.p1'),
      TheoryKeySignatureTable([
        MusicalKey(tonic: TheoryRoots.c, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.g, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.d, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.f, tonality: KeyTonality.major),
        MusicalKey(
          tonic: TheoryRoots.bFlat,
          tonality: KeyTonality.major,
          preferredSpelling: SpellingPreference.flats,
        ),
        MusicalKey(
          tonic: TheoryRoots.eFlat,
          tonality: KeyTonality.major,
          preferredSpelling: SpellingPreference.flats,
        ),
      ]),
      TheoryParagraph('key-signatures.p2'),
      TheoryBullets([
        'key-signatures.b1',
        'key-signatures.b2',
        'key-signatures.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'relative-keys',
    category: TheoryCategory.circleOfFifths,
    level: TheoryLevel.beginner,
    aliases: ['relative minor', 'relative major', 'same notes'],
    blocks: [
      TheoryParagraph('relative-keys.p1'),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'relative-keys.exampleMajor',
      ),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.naturalMinor,
        captionId: 'relative-keys.exampleMinor',
      ),
      TheoryParagraph('relative-keys.p2'),
      TheoryBullets([
        'relative-keys.b1',
        'relative-keys.b2',
        'relative-keys.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'parallel-keys',
    category: TheoryCategory.circleOfFifths,
    level: TheoryLevel.intermediate,
    aliases: [
      'parallel minor',
      'same tonic',
      'borrowed chords',
      'modal mixture',
    ],
    blocks: [
      TheoryParagraph('parallel-keys.p1'),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'parallel-keys.exampleMajor',
      ),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.naturalMinor,
        captionId: 'parallel-keys.exampleMinor',
      ),
      TheoryParagraph('parallel-keys.p2'),
      TheoryBullets([
        'parallel-keys.b1',
        'parallel-keys.b2',
        'parallel-keys.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'modulation',
    category: TheoryCategory.circleOfFifths,
    level: TheoryLevel.advanced,
    aliases: ['modulate', 'key change', 'pivot chord'],
    blocks: [
      TheoryParagraph('modulation.p1'),
      TheoryDiatonicTable(key: TheoryRoots.cMajorKey),
      TheoryDiatonicTable(key: TheoryRoots.gMajorKey),
      TheoryParagraph('modulation.p2'),
      TheoryBullets(['modulation.b1', 'modulation.b2', 'modulation.b3']),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'harmonic-relationships',
    category: TheoryCategory.circleOfFifths,
    level: TheoryLevel.intermediate,
    aliases: ['neighbouring keys', 'fifth relationship', 'circle movement'],
    blocks: [
      TheoryParagraph('harmonic-relationships.p1'),
      TheoryKeySignatureTable([
        MusicalKey(tonic: TheoryRoots.f, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.c, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.g, tonality: KeyTonality.major),
        MusicalKey(tonic: TheoryRoots.a, tonality: KeyTonality.naturalMinor),
      ]),
      TheoryParagraph('harmonic-relationships.p2'),
      TheoryBullets([
        'harmonic-relationships.b1',
        'harmonic-relationships.b2',
        'harmonic-relationships.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
];

import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

const harmonyLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'roman-numerals',
    category: TheoryCategory.harmony,
    level: TheoryLevel.beginner,
    aliases: ['roman numeral', 'i iv v', 'nashville', 'degrees'],
    blocks: [
      TheoryParagraph('roman-numerals.p1'),
      TheoryDiatonicTable(key: TheoryRoots.cMajorKey),
      TheoryParagraph('roman-numerals.p2'),
      TheoryBullets([
        'roman-numerals.b1',
        'roman-numerals.b2',
        'roman-numerals.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'tonic',
    category: TheoryCategory.harmony,
    level: TheoryLevel.beginner,
    aliases: ['tonic', 'home chord', 'i', 'resolution'],
    blocks: [
      TheoryParagraph('tonic.p1'),
      TheoryChordExample(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        captionId: 'tonic.example',
      ),
      TheoryParagraph('tonic.p2'),
      TheoryBullets(['tonic.b1', 'tonic.b2', 'tonic.b3']),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'dominant',
    category: TheoryCategory.harmony,
    level: TheoryLevel.beginner,
    aliases: ['dominant', 'v', 'v7', 'tension'],
    blocks: [
      TheoryParagraph('dominant.p1'),
      TheoryChordExample(
        root: TheoryRoots.g,
        quality: ChordQuality.dominantSeventh,
        captionId: 'dominant.example',
      ),
      TheoryParagraph('dominant.p2'),
      TheoryBullets(['dominant.b1', 'dominant.b2', 'dominant.b3']),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.g,
          quality: ChordQuality.dominantSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'subdominant',
    category: TheoryCategory.harmony,
    level: TheoryLevel.intermediate,
    aliases: ['subdominant', 'iv', 'departure'],
    blocks: [
      TheoryParagraph('subdominant.p1'),
      TheoryChordExample(
        root: TheoryRoots.f,
        quality: ChordQuality.major,
        captionId: 'subdominant.example',
      ),
      TheoryParagraph('subdominant.p2'),
      TheoryBullets(['subdominant.b1', 'subdominant.b2', 'subdominant.b3']),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.f,
          quality: ChordQuality.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'functional-harmony',
    category: TheoryCategory.harmony,
    level: TheoryLevel.intermediate,
    aliases: ['function', 'ii v i', 'progression', 'harmonic function'],
    blocks: [
      TheoryParagraph('functional-harmony.p1'),
      TheoryDiatonicTable(key: TheoryRoots.cMajorKey, sevenths: true),
      TheoryParagraph('functional-harmony.p2'),
      TheoryBullets([
        'functional-harmony.b1',
        'functional-harmony.b2',
        'functional-harmony.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.d,
          quality: ChordQuality.minorSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'cadences',
    category: TheoryCategory.harmony,
    level: TheoryLevel.intermediate,
    aliases: ['cadence', 'perfect', 'plagal', 'deceptive', 'half cadence'],
    blocks: [
      TheoryParagraph('cadences.p1'),
      TheoryFacts([
        TheoryFact(
          labelId: 'cadences.perfectLabel',
          valueId: 'cadences.perfectValue',
        ),
        TheoryFact(
          labelId: 'cadences.plagalLabel',
          valueId: 'cadences.plagalValue',
        ),
        TheoryFact(
          labelId: 'cadences.halfLabel',
          valueId: 'cadences.halfValue',
        ),
        TheoryFact(
          labelId: 'cadences.deceptiveLabel',
          valueId: 'cadences.deceptiveValue',
        ),
      ]),
      TheoryParagraph('cadences.p2'),
      TheoryBullets(['cadences.b1', 'cadences.b2', 'cadences.b3']),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
];

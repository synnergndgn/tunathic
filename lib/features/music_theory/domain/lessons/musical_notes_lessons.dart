import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

const musicalNotesLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'note-names',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.beginner,
    aliases: ['abc', 'musical alphabet', 'natural notes'],
    blocks: [
      TheoryParagraph('note-names.p1'),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'note-names.example',
      ),
      TheoryParagraph('note-names.p2'),
      TheoryBullets(['note-names.b1', 'note-names.b2', 'note-names.b3']),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.c,
            scaleDefinition: ScaleDefinition.major,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'sharps',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.beginner,
    aliases: ['#', 'sharp', 'raised'],
    blocks: [
      TheoryParagraph('sharps.p1'),
      TheoryScaleExample(
        root: TheoryRoots.g,
        definition: ScaleDefinition.major,
        captionId: 'sharps.example',
      ),
      TheoryParagraph('sharps.p2'),
      TheoryBullets(['sharps.b1', 'sharps.b2', 'sharps.b3']),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.g,
          definition: ScaleDefinition.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'flats',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.beginner,
    aliases: ['b', 'flat', 'lowered'],
    blocks: [
      TheoryParagraph('flats.p1'),
      TheoryScaleExample(
        root: TheoryRoots.f,
        definition: ScaleDefinition.major,
        captionId: 'flats.example',
      ),
      TheoryParagraph('flats.p2'),
      TheoryBullets(['flats.b1', 'flats.b2', 'flats.b3']),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.f,
          definition: ScaleDefinition.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'enharmonics',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.beginner,
    aliases: ['enharmonic', 'same pitch', 'f# gb'],
    blocks: [
      TheoryParagraph('enharmonics.p1'),
      TheoryScaleExample(
        root: TheoryRoots.fSharp,
        definition: ScaleDefinition.major,
        captionId: 'enharmonics.exampleSharp',
      ),
      TheoryScaleExample(
        root: TheoryRoots.dFlat,
        definition: ScaleDefinition.major,
        captionId: 'enharmonics.exampleFlat',
      ),
      TheoryParagraph('enharmonics.p2'),
      TheoryBullets(['enharmonics.b1', 'enharmonics.b2', 'enharmonics.b3']),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'octaves',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.beginner,
    aliases: ['octave', '8va', '12 frets'],
    blocks: [
      TheoryParagraph('octaves.p1'),
      TheoryIntervalProfile(
        interval: TheoryInterval.octave,
        root: TheoryRoots.e,
      ),
      TheoryParagraph('octaves.p2'),
      TheoryBullets(['octaves.b1', 'octaves.b2', 'octaves.b3']),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.e,
            scaleDefinition: ScaleDefinition.majorPentatonic,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'scientific-pitch-notation',
    category: TheoryCategory.musicalNotes,
    level: TheoryLevel.intermediate,
    aliases: ['spn', 'a4', 'e2', 'middle c', 'c4'],
    blocks: [
      TheoryParagraph('scientific-pitch-notation.p1'),
      TheoryTuningTable([
        TuningPresets.standard,
      ], captionId: 'scientific-pitch-notation.example'),
      TheoryParagraph('scientific-pitch-notation.p2'),
      TheoryBullets([
        'scientific-pitch-notation.b1',
        'scientific-pitch-notation.b2',
        'scientific-pitch-notation.b3',
      ]),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.guitarTuner)),
    ],
  ),
];

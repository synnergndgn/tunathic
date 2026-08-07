import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

const fretboardLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'fretboard-note-locations',
    category: TheoryCategory.fretboardTheory,
    level: TheoryLevel.beginner,
    aliases: ['note locations', 'fret markers', 'natural notes'],
    blocks: [
      TheoryParagraph('fretboard-note-locations.p1'),
      TheoryTuningTable([
        TuningPresets.standard,
      ], captionId: 'fretboard-note-locations.tuning'),
      TheoryFretboardDiagram.scale(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'fretboard-note-locations.fretboard',
      ),
      TheoryParagraph('fretboard-note-locations.p2'),
      TheoryBullets([
        'fretboard-note-locations.b1',
        'fretboard-note-locations.b2',
        'fretboard-note-locations.b3',
      ]),
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
    id: 'octave-shapes',
    category: TheoryCategory.fretboardTheory,
    level: TheoryLevel.beginner,
    aliases: ['octave shape', 'two frets over', 'find any note'],
    blocks: [
      TheoryParagraph('octave-shapes.p1'),
      TheoryIntervalProfile(
        interval: TheoryInterval.octave,
        root: TheoryRoots.g,
      ),
      TheoryParagraph('octave-shapes.p2'),
      TheoryBullets([
        'octave-shapes.b1',
        'octave-shapes.b2',
        'octave-shapes.b3',
      ]),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.g,
            scaleDefinition: ScaleDefinition.majorPentatonic,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-shapes',
    category: TheoryCategory.fretboardTheory,
    level: TheoryLevel.intermediate,
    aliases: ['interval shape', 'shape thinking', 'distance on strings'],
    blocks: [
      TheoryParagraph('interval-shapes.p1'),
      TheoryIntervalProfile(
        interval: TheoryInterval.perfectFifth,
        root: TheoryRoots.a,
      ),
      TheoryIntervalProfile(
        interval: TheoryInterval.majorThird,
        root: TheoryRoots.a,
      ),
      TheoryIntervalProfile(
        interval: TheoryInterval.minorSeventh,
        root: TheoryRoots.a,
      ),
      TheoryParagraph('interval-shapes.p2'),
      TheoryBullets([
        'interval-shapes.b1',
        'interval-shapes.b2',
        'interval-shapes.b3',
      ]),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            root: TheoryRoots.a,
            chordQuality: ChordQuality.dominantSeventh,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'movable-patterns',
    category: TheoryCategory.fretboardTheory,
    level: TheoryLevel.intermediate,
    aliases: ['barre', 'movable', 'transpose shape', 'e shape', 'a shape'],
    blocks: [
      TheoryParagraph('movable-patterns.p1'),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.f,
        quality: ChordQuality.major,
        firstFret: 1,
        lastFret: 5,
        captionId: 'movable-patterns.fretboard',
      ),
      TheoryParagraph('movable-patterns.p2'),
      TheoryBullets([
        'movable-patterns.b1',
        'movable-patterns.b2',
        'movable-patterns.b3',
      ]),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            root: TheoryRoots.f,
            chordQuality: ChordQuality.major,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'caged-system',
    category: TheoryCategory.fretboardTheory,
    level: TheoryLevel.advanced,
    aliases: ['caged', 'c a g e d', 'five shapes'],
    blocks: [
      TheoryParagraph('caged-system.p1'),
      TheoryBullets(['caged-system.b1', 'caged-system.b2', 'caged-system.b3']),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.c,
        quality: ChordQuality.major,
        firstFret: 0,
        lastFret: 12,
        captionId: 'caged-system.fretboard',
      ),
      TheoryParagraph('caged-system.p2'),
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
];

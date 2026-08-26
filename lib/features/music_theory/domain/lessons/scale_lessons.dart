import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

const scaleLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'major-scale',
    category: TheoryCategory.scales,
    level: TheoryLevel.beginner,
    aliases: ['ionian', 'wwhwwwh', 'do re mi'],
    blocks: [
      TheoryParagraph('major-scale.p1'),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'major-scale.example',
      ),
      TheoryParagraph('major-scale.p2'),
      TheoryBullets(['major-scale.b1', 'major-scale.b2', 'major-scale.b3']),
      TheoryFretboardDiagram.scale(
        root: TheoryRoots.g,
        definition: ScaleDefinition.major,
        firstFret: 2,
        lastFret: 7,
        captionId: 'major-scale.fretboard',
      ),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.c,
          definition: ScaleDefinition.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'natural-minor-scale',
    category: TheoryCategory.scales,
    level: TheoryLevel.beginner,
    aliases: ['aeolian', 'relative minor', 'minor scale'],
    blocks: [
      TheoryParagraph('natural-minor-scale.p1'),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.naturalMinor,
        captionId: 'natural-minor-scale.example',
      ),
      TheoryParagraph('natural-minor-scale.p2'),
      TheoryBullets([
        'natural-minor-scale.b1',
        'natural-minor-scale.b2',
        'natural-minor-scale.b3',
      ]),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.a,
          definition: ScaleDefinition.naturalMinor,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'harmonic-minor-scale',
    category: TheoryCategory.scales,
    level: TheoryLevel.intermediate,
    aliases: ['harmonic minor', 'raised seventh', 'v7 in minor'],
    blocks: [
      TheoryParagraph('harmonic-minor-scale.p1'),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.harmonicMinor,
        captionId: 'harmonic-minor-scale.example',
      ),
      TheoryParagraph('harmonic-minor-scale.p2'),
      TheoryBullets([
        'harmonic-minor-scale.b1',
        'harmonic-minor-scale.b2',
        'harmonic-minor-scale.b3',
      ]),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.a,
          definition: ScaleDefinition.harmonicMinor,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'melodic-minor-scale',
    category: TheoryCategory.scales,
    level: TheoryLevel.intermediate,
    aliases: ['melodic minor', 'jazz minor', 'raised sixth'],
    blocks: [
      TheoryParagraph('melodic-minor-scale.p1'),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.melodicMinor,
        captionId: 'melodic-minor-scale.example',
      ),
      TheoryParagraph('melodic-minor-scale.p2'),
      TheoryBullets([
        'melodic-minor-scale.b1',
        'melodic-minor-scale.b2',
        'melodic-minor-scale.b3',
      ]),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.a,
          definition: ScaleDefinition.melodicMinor,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'pentatonic-scales',
    category: TheoryCategory.scales,
    level: TheoryLevel.beginner,
    aliases: ['pentatonic', 'five notes', 'box 1'],
    blocks: [
      TheoryParagraph('pentatonic-scales.p1'),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.minorPentatonic,
        captionId: 'pentatonic-scales.exampleMinor',
      ),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.majorPentatonic,
        captionId: 'pentatonic-scales.exampleMajor',
      ),
      TheoryParagraph('pentatonic-scales.p2'),
      TheoryBullets([
        'pentatonic-scales.b1',
        'pentatonic-scales.b2',
        'pentatonic-scales.b3',
      ]),
      TheoryFretboardDiagram.scale(
        root: TheoryRoots.a,
        definition: ScaleDefinition.minorPentatonic,
        firstFret: 5,
        lastFret: 8,
        captionId: 'pentatonic-scales.fretboard',
      ),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.a,
            scaleDefinition: ScaleDefinition.minorPentatonic,
          ),
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'blues-scale',
    category: TheoryCategory.scales,
    level: TheoryLevel.intermediate,
    aliases: ['blues', 'blue note', 'b5'],
    blocks: [
      TheoryParagraph('blues-scale.p1'),
      TheoryScaleExample(
        root: TheoryRoots.a,
        definition: ScaleDefinition.blues,
        captionId: 'blues-scale.example',
      ),
      TheoryParagraph('blues-scale.p2'),
      TheoryBullets(['blues-scale.b1', 'blues-scale.b2', 'blues-scale.b3']),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.a,
          definition: ScaleDefinition.blues,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'modes',
    category: TheoryCategory.scales,
    level: TheoryLevel.advanced,
    aliases: [
      'mode',
      'dorian',
      'phrygian',
      'lydian',
      'mixolydian',
      'locrian',
      'modal',
    ],
    blocks: [
      TheoryParagraph('modes.p1'),
      TheoryScaleExample(
        root: TheoryRoots.d,
        definition: ScaleDefinition.dorian,
        captionId: 'modes.exampleDorian',
      ),
      TheoryScaleExample(
        root: TheoryRoots.g,
        definition: ScaleDefinition.mixolydian,
        captionId: 'modes.exampleMixolydian',
      ),
      TheoryScaleExample(
        root: TheoryRoots.f,
        definition: ScaleDefinition.lydian,
        captionId: 'modes.exampleLydian',
      ),
      TheoryParagraph('modes.p2'),
      TheoryBullets(['modes.b1', 'modes.b2', 'modes.b3']),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.d,
          definition: ScaleDefinition.dorian,
        ),
      ),
    ],
  ),
];

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

const guitarLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'standard-tuning',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.beginner,
    aliases: ['eadgbe', 'standard tuning', 'open strings'],
    blocks: [
      TheoryParagraph('standard-tuning.p1'),
      TheoryTuningTable([
        TuningPresets.standard,
      ], captionId: 'standard-tuning.example'),
      TheoryParagraph('standard-tuning.p2'),
      TheoryBullets([
        'standard-tuning.b1',
        'standard-tuning.b2',
        'standard-tuning.b3',
      ]),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.guitarTuner)),
    ],
  ),
  TheoryLesson(
    id: 'alternate-tunings',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.intermediate,
    aliases: ['drop d', 'dadgad', 'open g', 'open d', 'alternate tuning'],
    blocks: [
      TheoryParagraph('alternate-tunings.p1'),
      TheoryTuningTable([
        TuningPresets.dropD,
        TuningPresets.dadgad,
        TuningPresets.openG,
        TuningPresets.openD,
        TuningPresets.halfStepDown,
      ], captionId: 'alternate-tunings.example'),
      TheoryParagraph('alternate-tunings.p2'),
      TheoryBullets([
        'alternate-tunings.b1',
        'alternate-tunings.b2',
        'alternate-tunings.b3',
      ]),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.guitarTuner)),
    ],
  ),
  TheoryLesson(
    id: 'capo',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.beginner,
    aliases: ['capo', 'clamp', 'shortcut key change'],
    blocks: [
      TheoryParagraph('capo.p1'),
      TheoryFacts([
        TheoryFact(labelId: 'capo.fret2Label', valueId: 'capo.fret2Value'),
        TheoryFact(labelId: 'capo.fret3Label', valueId: 'capo.fret3Value'),
        TheoryFact(labelId: 'capo.fret5Label', valueId: 'capo.fret5Value'),
      ]),
      TheoryParagraph('capo.p2'),
      TheoryBullets(['capo.b1', 'capo.b2', 'capo.b3']),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.d,
          definition: ScaleDefinition.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'transposition',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.intermediate,
    aliases: ['transpose', 'change key', 'semitones up'],
    blocks: [
      TheoryParagraph('transposition.p1'),
      TheoryDiatonicTable(key: TheoryRoots.cMajorKey),
      TheoryDiatonicTable(key: TheoryRoots.gMajorKey),
      TheoryParagraph('transposition.p2'),
      TheoryBullets([
        'transposition.b1',
        'transposition.b2',
        'transposition.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'chord-construction-on-guitar',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.advanced,
    aliases: ['build chords', 'doubling', 'omit fifth', 'voice leading'],
    blocks: [
      TheoryParagraph('chord-construction-on-guitar.p1'),
      TheoryChordFormula(ChordQuality.dominantSeventh),
      TheoryFretboardDiagram.chord(
        root: TheoryRoots.a,
        quality: ChordQuality.dominantSeventh,
        firstFret: 0,
        lastFret: 7,
        captionId: 'chord-construction-on-guitar.fretboard',
      ),
      TheoryParagraph('chord-construction-on-guitar.p2'),
      TheoryBullets([
        'chord-construction-on-guitar.b1',
        'chord-construction-on-guitar.b2',
        'chord-construction-on-guitar.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.a,
          quality: ChordQuality.dominantSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'scale-positions',
    category: TheoryCategory.guitarTheory,
    level: TheoryLevel.advanced,
    aliases: ['position', 'three notes per string', 'box', 'shifting'],
    blocks: [
      TheoryParagraph('scale-positions.p1'),
      TheoryFretboardDiagram.scale(
        root: TheoryRoots.g,
        definition: ScaleDefinition.major,
        firstFret: 2,
        lastFret: 9,
        captionId: 'scale-positions.fretboard',
      ),
      TheoryParagraph('scale-positions.p2'),
      TheoryBullets([
        'scale-positions.b1',
        'scale-positions.b2',
        'scale-positions.b3',
      ]),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.g,
            scaleDefinition: ScaleDefinition.major,
          ),
        ),
      ),
    ],
  ),
];

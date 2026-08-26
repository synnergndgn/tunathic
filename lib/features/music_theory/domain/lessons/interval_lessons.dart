import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/music_theory/domain/lessons/lesson_roots.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/tools/tool_definition.dart';

/// The thirteen distances inside one octave, plus the lesson that frames them.
///
/// Each lesson titles itself with the interval's own name, so the name is
/// written once per language and reused by every diagram that labels it.
const intervalLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'interval-basics',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['interval', 'distance', 'semitone', 'half step'],
    blocks: [
      TheoryParagraph('interval-basics.p1'),
      TheoryParagraph('interval-basics.p2'),
      TheoryScaleExample(
        root: TheoryRoots.c,
        definition: ScaleDefinition.major,
        captionId: 'interval-basics.example',
      ),
      TheoryBullets([
        'interval-basics.b1',
        'interval-basics.b2',
        'interval-basics.b3',
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
    id: 'interval-perfect-unison',
    titleOverrideId: 'intervalName.perfect-unison',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['p1', 'unison', '0 semitones'],
    blocks: [
      TheoryParagraph('interval-perfect-unison.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.perfectUnison,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-perfect-unison.usage'),
      TheoryBullets([
        'interval-perfect-unison.b1',
        'interval-perfect-unison.b2',
        'interval-perfect-unison.b3',
      ]),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.guitarTuner)),
    ],
  ),
  TheoryLesson(
    id: 'interval-minor-second',
    titleOverrideId: 'intervalName.minor-second',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['m2', 'b2', 'half step', 'semitone'],
    blocks: [
      TheoryParagraph('interval-minor-second.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.minorSecond,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-minor-second.usage'),
      TheoryBullets([
        'interval-minor-second.b1',
        'interval-minor-second.b2',
        'interval-minor-second.b3',
      ]),
      TheoryTryIt(
        OpenScaleLibraryAction(
          root: TheoryRoots.e,
          definition: ScaleDefinition.phrygian,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-major-second',
    titleOverrideId: 'intervalName.major-second',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['m2 major', 'whole step', 'tone', '2'],
    blocks: [
      TheoryParagraph('interval-major-second.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.majorSecond,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-major-second.usage'),
      TheoryBullets([
        'interval-major-second.b1',
        'interval-major-second.b2',
        'interval-major-second.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.d,
          quality: ChordQuality.suspendedSecond,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-minor-third',
    titleOverrideId: 'intervalName.minor-third',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['m3', 'b3', 'minor third'],
    blocks: [
      TheoryParagraph('interval-minor-third.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.minorThird,
        root: TheoryRoots.a,
      ),
      TheoryParagraph('interval-minor-third.usage'),
      TheoryBullets([
        'interval-minor-third.b1',
        'interval-minor-third.b2',
        'interval-minor-third.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.a,
          quality: ChordQuality.minor,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-major-third',
    titleOverrideId: 'intervalName.major-third',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['m3 major', '3', 'major third'],
    blocks: [
      TheoryParagraph('interval-major-third.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.majorThird,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-major-third.usage'),
      TheoryBullets([
        'interval-major-third.b1',
        'interval-major-third.b2',
        'interval-major-third.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.major,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-perfect-fourth',
    titleOverrideId: 'intervalName.perfect-fourth',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['p4', '4', 'fourth'],
    blocks: [
      TheoryParagraph('interval-perfect-fourth.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.perfectFourth,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-perfect-fourth.usage'),
      TheoryBullets([
        'interval-perfect-fourth.b1',
        'interval-perfect-fourth.b2',
        'interval-perfect-fourth.b3',
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
    id: 'interval-tritone',
    titleOverrideId: 'intervalName.tritone',
    category: TheoryCategory.intervals,
    level: TheoryLevel.intermediate,
    aliases: ['tt', 'a4', 'd5', '#4', 'b5', 'tritone', 'diabolus'],
    blocks: [
      TheoryParagraph('interval-tritone.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.augmentedFourth,
        root: TheoryRoots.c,
        enharmonic: TheoryInterval.diminishedFifth,
      ),
      TheoryParagraph('interval-tritone.usage'),
      TheoryBullets([
        'interval-tritone.b1',
        'interval-tritone.b2',
        'interval-tritone.b3',
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
    id: 'interval-perfect-fifth',
    titleOverrideId: 'intervalName.perfect-fifth',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['p5', '5', 'fifth', 'power chord'],
    blocks: [
      TheoryParagraph('interval-perfect-fifth.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.perfectFifth,
        root: TheoryRoots.a,
      ),
      TheoryParagraph('interval-perfect-fifth.usage'),
      TheoryBullets([
        'interval-perfect-fifth.b1',
        'interval-perfect-fifth.b2',
        'interval-perfect-fifth.b3',
      ]),
      TheoryTryIt(OpenCircleOfFifthsAction()),
    ],
  ),
  TheoryLesson(
    id: 'interval-minor-sixth',
    titleOverrideId: 'intervalName.minor-sixth',
    category: TheoryCategory.intervals,
    level: TheoryLevel.intermediate,
    aliases: ['m6', 'b6', 'minor sixth'],
    blocks: [
      TheoryParagraph('interval-minor-sixth.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.minorSixth,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-minor-sixth.usage'),
      TheoryBullets([
        'interval-minor-sixth.b1',
        'interval-minor-sixth.b2',
        'interval-minor-sixth.b3',
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
    id: 'interval-major-sixth',
    titleOverrideId: 'intervalName.major-sixth',
    category: TheoryCategory.intervals,
    level: TheoryLevel.intermediate,
    aliases: ['m6 major', '6', 'major sixth'],
    blocks: [
      TheoryParagraph('interval-major-sixth.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.majorSixth,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-major-sixth.usage'),
      TheoryBullets([
        'interval-major-sixth.b1',
        'interval-major-sixth.b2',
        'interval-major-sixth.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.sixth,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-minor-seventh',
    titleOverrideId: 'intervalName.minor-seventh',
    category: TheoryCategory.intervals,
    level: TheoryLevel.intermediate,
    aliases: ['m7', 'b7', 'minor seventh'],
    blocks: [
      TheoryParagraph('interval-minor-seventh.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.minorSeventh,
        root: TheoryRoots.g,
      ),
      TheoryParagraph('interval-minor-seventh.usage'),
      TheoryBullets([
        'interval-minor-seventh.b1',
        'interval-minor-seventh.b2',
        'interval-minor-seventh.b3',
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
    id: 'interval-major-seventh',
    titleOverrideId: 'intervalName.major-seventh',
    category: TheoryCategory.intervals,
    level: TheoryLevel.intermediate,
    aliases: ['m7 major', 'maj7', '7', 'major seventh'],
    blocks: [
      TheoryParagraph('interval-major-seventh.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.majorSeventh,
        root: TheoryRoots.c,
      ),
      TheoryParagraph('interval-major-seventh.usage'),
      TheoryBullets([
        'interval-major-seventh.b1',
        'interval-major-seventh.b2',
        'interval-major-seventh.b3',
      ]),
      TheoryTryIt(
        OpenChordLibraryAction(
          root: TheoryRoots.c,
          quality: ChordQuality.majorSeventh,
        ),
      ),
    ],
  ),
  TheoryLesson(
    id: 'interval-octave',
    titleOverrideId: 'intervalName.octave',
    category: TheoryCategory.intervals,
    level: TheoryLevel.beginner,
    aliases: ['p8', '8va', 'octave', '12 frets'],
    blocks: [
      TheoryParagraph('interval-octave.character'),
      TheoryIntervalProfile(
        interval: TheoryInterval.octave,
        root: TheoryRoots.e,
      ),
      TheoryParagraph('interval-octave.usage'),
      TheoryBullets([
        'interval-octave.b1',
        'interval-octave.b2',
        'interval-octave.b3',
      ]),
      TheoryTryIt(
        OpenFretboardAction(
          state: FretboardRouteState(
            mode: FretboardMode.scale,
            root: TheoryRoots.e,
            scaleDefinition: ScaleDefinition.minorPentatonic,
          ),
        ),
      ),
    ],
  ),
];

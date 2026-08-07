import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/tools/tool_definition.dart';

const _straightValues = [
  TheoryNoteValue(nameId: 'noteValue.whole', beats: 4, symbol: '1'),
  TheoryNoteValue(nameId: 'noteValue.half', beats: 2, symbol: '1/2'),
  TheoryNoteValue(nameId: 'noteValue.quarter', beats: 1, symbol: '1/4'),
  TheoryNoteValue(nameId: 'noteValue.eighth', beats: 0.5, symbol: '1/8'),
  TheoryNoteValue(nameId: 'noteValue.sixteenth', beats: 0.25, symbol: '1/16'),
];

const _restValues = [
  TheoryNoteValue(nameId: 'restValue.whole', beats: 4, symbol: '1'),
  TheoryNoteValue(nameId: 'restValue.half', beats: 2, symbol: '1/2'),
  TheoryNoteValue(nameId: 'restValue.quarter', beats: 1, symbol: '1/4'),
  TheoryNoteValue(nameId: 'restValue.eighth', beats: 0.5, symbol: '1/8'),
];

const _dottedValues = [
  TheoryNoteValue(nameId: 'noteValue.half', beats: 2, symbol: '1/2'),
  TheoryNoteValue(nameId: 'noteValue.dottedHalf', beats: 3, symbol: '1/2.'),
  TheoryNoteValue(nameId: 'noteValue.quarter', beats: 1, symbol: '1/4'),
  TheoryNoteValue(
    nameId: 'noteValue.dottedQuarter',
    beats: 1.5,
    symbol: '1/4.',
  ),
  TheoryNoteValue(
    nameId: 'noteValue.dottedEighth',
    beats: 0.75,
    symbol: '1/8.',
  ),
];

const _tripletValues = [
  TheoryNoteValue(nameId: 'noteValue.quarter', beats: 1, symbol: '1/4'),
  TheoryNoteValue(nameId: 'noteValue.eighth', beats: 0.5, symbol: '1/8'),
  TheoryNoteValue(
    nameId: 'noteValue.eighthTriplet',
    beats: 1 / 3,
    symbol: '1/8³',
  ),
  TheoryNoteValue(
    nameId: 'noteValue.quarterTriplet',
    beats: 2 / 3,
    symbol: '1/4³',
  ),
];

const _swingValues = [
  TheoryNoteValue(nameId: 'noteValue.eighth', beats: 0.5, symbol: '1/8'),
  TheoryNoteValue(nameId: 'noteValue.swungLong', beats: 2 / 3, symbol: '1/4³'),
  TheoryNoteValue(nameId: 'noteValue.swungShort', beats: 1 / 3, symbol: '1/8³'),
];

const rhythmLessons = <TheoryLesson>[
  TheoryLesson(
    id: 'bpm',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.beginner,
    aliases: ['bpm', 'tempo', 'beats per minute', 'metronome'],
    blocks: [
      TheoryParagraph('bpm.p1'),
      TheoryFacts([
        TheoryFact(labelId: 'bpm.slowLabel', valueId: 'bpm.slowValue'),
        TheoryFact(labelId: 'bpm.mediumLabel', valueId: 'bpm.mediumValue'),
        TheoryFact(labelId: 'bpm.fastLabel', valueId: 'bpm.fastValue'),
      ]),
      TheoryParagraph('bpm.p2'),
      TheoryBullets(['bpm.b1', 'bpm.b2', 'bpm.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.bpmTap)),
    ],
  ),
  TheoryLesson(
    id: 'note-values',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.beginner,
    aliases: ['note value', 'whole note', 'quarter note', 'duration'],
    blocks: [
      TheoryParagraph('note-values.p1'),
      TheoryNoteValueChart(_straightValues),
      TheoryParagraph('note-values.p2'),
      TheoryBullets(['note-values.b1', 'note-values.b2', 'note-values.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
    ],
  ),
  TheoryLesson(
    id: 'rests',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.beginner,
    aliases: ['rest', 'silence', 'pause'],
    blocks: [
      TheoryParagraph('rests.p1'),
      TheoryNoteValueChart(_restValues),
      TheoryParagraph('rests.p2'),
      TheoryBullets(['rests.b1', 'rests.b2', 'rests.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
    ],
  ),
  TheoryLesson(
    id: 'dotted-notes',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.intermediate,
    aliases: ['dot', 'dotted', 'half again'],
    blocks: [
      TheoryParagraph('dotted-notes.p1'),
      TheoryNoteValueChart(_dottedValues),
      TheoryParagraph('dotted-notes.p2'),
      TheoryBullets(['dotted-notes.b1', 'dotted-notes.b2', 'dotted-notes.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
    ],
  ),
  TheoryLesson(
    id: 'triplets',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.intermediate,
    aliases: ['triplet', 'three in the time of two', 'tuplet'],
    blocks: [
      TheoryParagraph('triplets.p1'),
      TheoryNoteValueChart(_tripletValues),
      TheoryParagraph('triplets.p2'),
      TheoryBullets(['triplets.b1', 'triplets.b2', 'triplets.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
    ],
  ),
  TheoryLesson(
    id: 'swing',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.advanced,
    aliases: ['swing', 'shuffle', 'groove', 'long short'],
    blocks: [
      TheoryParagraph('swing.p1'),
      TheoryNoteValueChart(_swingValues),
      TheoryParagraph('swing.p2'),
      TheoryBullets(['swing.b1', 'swing.b2', 'swing.b3']),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.bpmTap)),
    ],
  ),
  TheoryLesson(
    id: 'time-signatures',
    category: TheoryCategory.rhythm,
    level: TheoryLevel.intermediate,
    aliases: ['time signature', '4/4', '3/4', '6/8', 'meter', 'bar'],
    blocks: [
      TheoryParagraph('time-signatures.p1'),
      TheoryFacts([
        TheoryFact(
          labelId: 'time-signatures.commonLabel',
          valueId: 'time-signatures.commonValue',
        ),
        TheoryFact(
          labelId: 'time-signatures.waltzLabel',
          valueId: 'time-signatures.waltzValue',
        ),
        TheoryFact(
          labelId: 'time-signatures.compoundLabel',
          valueId: 'time-signatures.compoundValue',
        ),
        TheoryFact(
          labelId: 'time-signatures.oddLabel',
          valueId: 'time-signatures.oddValue',
        ),
      ]),
      TheoryParagraph('time-signatures.p2'),
      TheoryBullets([
        'time-signatures.b1',
        'time-signatures.b2',
        'time-signatures.b3',
      ]),
      TheoryTryIt(OpenPracticeToolAction(ToolDefinition.metronome)),
    ],
  ),
];

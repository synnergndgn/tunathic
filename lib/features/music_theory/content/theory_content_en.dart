import 'package:tunathic/features/music_theory/content/en/chord_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/circle_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/fretboard_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/guitar_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/harmony_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/interval_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/musical_notes_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/rhythm_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/scale_content_en.dart';
import 'package:tunathic/features/music_theory/content/en/shared_content_en.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';

const theoryContentEn = TheoryContent(
  languageCode: 'en',
  entries: {
    ...sharedContentEn,
    ...musicalNotesContentEn,
    ...intervalContentEn,
    ...chordContentEn,
    ...scaleContentEn,
    ...circleContentEn,
    ...fretboardContentEn,
    ...rhythmContentEn,
    ...harmonyContentEn,
    ...guitarContentEn,
  },
);

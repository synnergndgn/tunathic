import 'package:tunathic/features/music_theory/content/tr/chord_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/circle_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/fretboard_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/guitar_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/harmony_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/interval_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/musical_notes_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/rhythm_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/scale_content_tr.dart';
import 'package:tunathic/features/music_theory/content/tr/shared_content_tr.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';

const theoryContentTr = TheoryContent(
  languageCode: 'tr',
  entries: {
    ...sharedContentTr,
    ...musicalNotesContentTr,
    ...intervalContentTr,
    ...chordContentTr,
    ...scaleContentTr,
    ...circleContentTr,
    ...fretboardContentTr,
    ...rhythmContentTr,
    ...harmonyContentTr,
    ...guitarContentTr,
  },
);

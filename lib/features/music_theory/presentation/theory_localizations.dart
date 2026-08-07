import 'package:flutter/material.dart';
import 'package:tunathic/features/music_theory/content/theory_content_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

extension TheoryLocalizations on AppLocalizations {
  String theoryCategoryName(TheoryCategory category) => switch (category) {
    TheoryCategory.musicalNotes => theoryCategoryMusicalNotes,
    TheoryCategory.intervals => theoryCategoryIntervals,
    TheoryCategory.chords => theoryCategoryChords,
    TheoryCategory.scales => theoryCategoryScales,
    TheoryCategory.circleOfFifths => theoryCategoryCircleOfFifths,
    TheoryCategory.fretboardTheory => theoryCategoryFretboardTheory,
    TheoryCategory.rhythm => theoryCategoryRhythm,
    TheoryCategory.harmony => theoryCategoryHarmony,
    TheoryCategory.guitarTheory => theoryCategoryGuitarTheory,
  };

  String theoryCategoryDescription(
    TheoryCategory category,
  ) => switch (category) {
    TheoryCategory.musicalNotes => theoryCategoryMusicalNotesDescription,
    TheoryCategory.intervals => theoryCategoryIntervalsDescription,
    TheoryCategory.chords => theoryCategoryChordsDescription,
    TheoryCategory.scales => theoryCategoryScalesDescription,
    TheoryCategory.circleOfFifths => theoryCategoryCircleOfFifthsDescription,
    TheoryCategory.fretboardTheory => theoryCategoryFretboardTheoryDescription,
    TheoryCategory.rhythm => theoryCategoryRhythmDescription,
    TheoryCategory.harmony => theoryCategoryHarmonyDescription,
    TheoryCategory.guitarTheory => theoryCategoryGuitarTheoryDescription,
  };

  String theoryLevelName(TheoryLevel level) => switch (level) {
    TheoryLevel.beginner => beginner,
    TheoryLevel.intermediate => intermediate,
    TheoryLevel.advanced => advanced,
  };

  /// The label on a lesson's "Try it" button.
  String theoryActionLabel(TheoryAction action) => switch (action) {
    OpenChordLibraryAction() => theoryOpenInChordLibrary,
    OpenScaleLibraryAction() => theoryOpenInScaleLibrary,
    OpenCircleOfFifthsAction() => theoryOpenCircle,
    OpenFretboardAction() => theoryOpenInteractiveFretboard,
    OpenPracticeToolAction(tool: final tool) => switch (tool) {
      ToolDefinition.metronome => theoryOpenMetronome,
      ToolDefinition.bpmTap => theoryOpenBpmTap,
      _ => theoryOpenGuitarTuner,
    },
  };
}

/// Icons live in the presentation layer so the catalog stays free of Flutter.
IconData theoryCategoryIcon(TheoryCategory category) => switch (category) {
  TheoryCategory.musicalNotes => Icons.music_note_outlined,
  TheoryCategory.intervals => Icons.swap_vert,
  TheoryCategory.chords => Icons.library_music_outlined,
  TheoryCategory.scales => Icons.stacked_line_chart,
  TheoryCategory.circleOfFifths => Icons.donut_large_outlined,
  TheoryCategory.fretboardTheory => Icons.grid_on_outlined,
  TheoryCategory.rhythm => Icons.timer_outlined,
  TheoryCategory.harmony => Icons.account_tree_outlined,
  TheoryCategory.guitarTheory => Icons.music_note,
};

extension TheoryContentContext on BuildContext {
  /// Lesson prose for the locale this subtree is rendered in.
  TheoryContent get theoryContent => TheoryContentLibrary.forLanguageCode(
    Localizations.localeOf(this).languageCode,
  );
}

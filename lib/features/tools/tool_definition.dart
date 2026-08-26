import 'package:flutter/material.dart';
import 'package:tunathic/l10n/app_localizations.dart';

enum ToolCategory { practice, theoryReference, training }

enum ToolDefinition {
  guitarTuner('guitar-tuner', Icons.graphic_eq),
  metronome('metronome', Icons.timer_outlined),
  bpmTap('bpm-tap', Icons.touch_app_outlined),
  repertoire('repertoire', Icons.library_books_outlined),
  musicTheory('music-theory', Icons.school_outlined),
  chordLibrary('chord-library', Icons.library_music_outlined),
  scaleLibrary('scale-library', Icons.stacked_line_chart),
  interactiveFretboard('interactive-fretboard', Icons.grid_on_outlined),
  circleOfFifths('circle-of-fifths', Icons.donut_large_outlined),
  earTraining('ear-training', Icons.hearing_outlined),
  chordFinder('chord-finder', Icons.search),
  capoCalculator('capo-calculator', Icons.calculate_outlined);

  const ToolDefinition(this.id, this.icon);

  final String id;
  final IconData icon;

  bool get isAvailable =>
      this == ToolDefinition.bpmTap ||
      this == ToolDefinition.metronome ||
      this == ToolDefinition.guitarTuner ||
      this == ToolDefinition.chordLibrary ||
      this == ToolDefinition.scaleLibrary ||
      this == ToolDefinition.interactiveFretboard ||
      this == ToolDefinition.circleOfFifths ||
      this == ToolDefinition.musicTheory ||
      this == ToolDefinition.repertoire;

  ToolCategory get category => switch (this) {
    ToolDefinition.guitarTuner ||
    ToolDefinition.metronome ||
    ToolDefinition.bpmTap ||
    ToolDefinition.repertoire => ToolCategory.practice,
    ToolDefinition.musicTheory ||
    ToolDefinition.chordLibrary ||
    ToolDefinition.scaleLibrary ||
    ToolDefinition.interactiveFretboard ||
    ToolDefinition.circleOfFifths ||
    ToolDefinition.chordFinder ||
    ToolDefinition.capoCalculator => ToolCategory.theoryReference,
    ToolDefinition.earTraining => ToolCategory.training,
  };

  static ToolDefinition? fromId(String? id) {
    for (final tool in values) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  String title(AppLocalizations localizations) => switch (this) {
    ToolDefinition.guitarTuner => localizations.guitarTuner,
    ToolDefinition.metronome => localizations.metronome,
    ToolDefinition.bpmTap => localizations.bpmTap,
    ToolDefinition.repertoire => localizations.repertoire,
    ToolDefinition.musicTheory => localizations.musicTheory,
    ToolDefinition.chordLibrary => localizations.chordLibrary,
    ToolDefinition.scaleLibrary => localizations.scaleLibrary,
    ToolDefinition.interactiveFretboard => localizations.interactiveFretboard,
    ToolDefinition.circleOfFifths => localizations.circleOfFifths,
    ToolDefinition.earTraining => localizations.earTraining,
    ToolDefinition.chordFinder => localizations.chordFinder,
    ToolDefinition.capoCalculator => localizations.capoCalculator,
  };

  /// The dashboard subtitle. Only the learning hub describes itself; every
  /// other card shows its availability on that line instead.
  String? subtitle(AppLocalizations localizations) =>
      this == musicTheory ? localizations.musicTheoryTagline : null;
}

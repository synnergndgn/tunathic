import 'package:flutter/material.dart';
import 'package:tunathic/l10n/app_localizations.dart';

enum ToolCategory { practice, theoryReference, training }

enum ToolDefinition {
  guitarTuner('guitar-tuner', Icons.graphic_eq),
  metronome('metronome', Icons.timer_outlined),
  bpmTap('bpm-tap', Icons.touch_app_outlined),
  chordLibrary('chord-library', Icons.library_music_outlined),
  scaleLibrary('scale-library', Icons.stacked_line_chart),
  circleOfFifths('circle-of-fifths', Icons.donut_large_outlined),
  intervalTrainer('interval-trainer', Icons.swap_vert),
  earTraining('ear-training', Icons.hearing_outlined),
  chordFinder('chord-finder', Icons.search),
  capoCalculator('capo-calculator', Icons.calculate_outlined);

  const ToolDefinition(this.id, this.icon);

  final String id;
  final IconData icon;

  bool get isAvailable =>
      this == ToolDefinition.bpmTap || this == ToolDefinition.metronome;

  ToolCategory get category => switch (this) {
    ToolDefinition.guitarTuner ||
    ToolDefinition.metronome ||
    ToolDefinition.bpmTap => ToolCategory.practice,
    ToolDefinition.chordLibrary ||
    ToolDefinition.scaleLibrary ||
    ToolDefinition.circleOfFifths ||
    ToolDefinition.chordFinder ||
    ToolDefinition.capoCalculator => ToolCategory.theoryReference,
    ToolDefinition.intervalTrainer ||
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
    ToolDefinition.chordLibrary => localizations.chordLibrary,
    ToolDefinition.scaleLibrary => localizations.scaleLibrary,
    ToolDefinition.circleOfFifths => localizations.circleOfFifths,
    ToolDefinition.intervalTrainer => localizations.intervalTrainer,
    ToolDefinition.earTraining => localizations.earTraining,
    ToolDefinition.chordFinder => localizations.chordFinder,
    ToolDefinition.capoCalculator => localizations.capoCalculator,
  };
}

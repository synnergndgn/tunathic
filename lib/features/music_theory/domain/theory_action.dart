import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/tools/tool_definition.dart';

/// A "Try it" target that hands a lesson's example to an existing tool.
///
/// Actions carry structural music-theory values rather than URLs. The router
/// helper turns them into the query the released libraries already understand,
/// so no lesson duplicates navigation knowledge.
sealed class TheoryAction {
  const TheoryAction();

  /// The tool the action opens, used for the button icon and label.
  ToolDefinition get tool;
}

final class OpenChordLibraryAction extends TheoryAction {
  const OpenChordLibraryAction({required this.root, required this.quality});

  final SpelledPitchClass root;
  final ChordQuality quality;

  @override
  ToolDefinition get tool => ToolDefinition.chordLibrary;

  String get chordSymbol => '${root.symbol}${quality.symbol}';
}

final class OpenScaleLibraryAction extends TheoryAction {
  const OpenScaleLibraryAction({required this.root, required this.definition});

  final SpelledPitchClass root;
  final ScaleDefinition definition;

  @override
  ToolDefinition get tool => ToolDefinition.scaleLibrary;
}

final class OpenFretboardAction extends TheoryAction {
  const OpenFretboardAction({required this.state});

  final FretboardRouteState state;

  @override
  ToolDefinition get tool => ToolDefinition.interactiveFretboard;
}

final class OpenCircleOfFifthsAction extends TheoryAction {
  const OpenCircleOfFifthsAction();

  @override
  ToolDefinition get tool => ToolDefinition.circleOfFifths;
}

/// Opens a practice tool that needs no theory argument.
final class OpenPracticeToolAction extends TheoryAction {
  const OpenPracticeToolAction(this.tool)
    : assert(
        tool == ToolDefinition.metronome ||
            tool == ToolDefinition.bpmTap ||
            tool == ToolDefinition.guitarTuner,
        'Only argument-free practice tools are supported.',
      );

  @override
  final ToolDefinition tool;
}

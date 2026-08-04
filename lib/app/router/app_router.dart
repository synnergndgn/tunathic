import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_screen.dart';
import 'package:tunathic/features/about/presentation/about_screen.dart';
import 'package:tunathic/features/dashboard/presentation/dashboard_screen.dart';
import 'package:tunathic/features/chord_library/domain/chord_library_route_state.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_screen.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_screen.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/fretboard/presentation/interactive_fretboard_screen.dart';
import 'package:tunathic/features/interval_trainer/presentation/interval_trainer_screen.dart';
import 'package:tunathic/features/metronome/presentation/metronome_screen.dart';
import 'package:tunathic/features/privacy/presentation/privacy_screen.dart';
import 'package:tunathic/features/repertoire/presentation/repertoire_screen.dart';
import 'package:tunathic/features/repertoire/presentation/song_editor_screen.dart';
import 'package:tunathic/features/repertoire/presentation/song_view_screen.dart';
import 'package:tunathic/features/settings/presentation/settings_screen.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_screen.dart';
import 'package:tunathic/features/scale_library/domain/scale_library_route_state.dart';
import 'package:tunathic/features/tool_placeholder/presentation/not_found_screen.dart';
import 'package:tunathic/features/tool_placeholder/presentation/tool_placeholder_screen.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/features/tuner/presentation/guitar_tuner_screen.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_prototype_screen.dart';

abstract final class AppRoutes {
  static const dashboard = '/';
  static const settings = '/settings';
  static const about = '/about';
  static const privacy = '/privacy';
  static const tunerDiagnostics = '/debug/tuner-diagnostics';

  static const repertoire = '/tools/repertoire';
  static const repertoireNewSong = '/tools/repertoire/new';

  static String tool(ToolDefinition tool) => '/tools/${tool.id}';

  /// The performance view. [editChords] opens it ready to place chords, which
  /// is where a newly written set of lyrics goes next.
  static String repertoireSong(String songId, {bool editChords = false}) =>
      editChords ? '$repertoire/$songId?chords=edit' : '$repertoire/$songId';

  static String repertoireSongEditor(String songId) =>
      '$repertoire/$songId/edit';

  static String fretboard(FretboardRouteState state) => Uri(
    path: tool(ToolDefinition.interactiveFretboard),
    queryParameters: state.toQuery(),
  ).toString();

  static String scaleLibrary(ScaleLibraryRouteState state) => Uri(
    path: tool(ToolDefinition.scaleLibrary),
    queryParameters: state.toQuery(),
  ).toString();

  static String chordLibrary(ChordLibraryRouteState state) => Uri(
    path: tool(ToolDefinition.chordLibrary),
    queryParameters: state.toQuery(),
  ).toString();
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.tunerDiagnostics,
          builder: (context, state) => const TunerAudioPrototypeScreen(),
        ),
      GoRoute(
        path: AppRoutes.repertoireNewSong,
        builder: (context, state) => const SongEditorScreen(),
      ),
      GoRoute(
        path: '/tools/repertoire/:songId',
        builder: (context, state) => SongViewScreen(
          songId: state.pathParameters['songId']!,
          startInChordEditing: state.uri.queryParameters['chords'] == 'edit',
        ),
      ),
      GoRoute(
        path: '/tools/repertoire/:songId/edit',
        builder: (context, state) =>
            SongEditorScreen(songId: state.pathParameters['songId']),
      ),
      GoRoute(
        path: '/tools/:toolId',
        builder: (context, state) {
          final tool = ToolDefinition.fromId(state.pathParameters['toolId']);
          if (tool == null) return const NotFoundScreen();
          if (tool == ToolDefinition.bpmTap) {
            return BpmTapScreen(allowApplyResult: state.extra == true);
          }
          if (tool == ToolDefinition.metronome) {
            return const MetronomeScreen();
          }
          if (tool == ToolDefinition.guitarTuner) {
            return const GuitarTunerScreen();
          }
          if (tool == ToolDefinition.chordLibrary) {
            return ChordLibraryScreen(
              initialState: ChordLibraryRouteState.fromQuery(
                state.uri.queryParameters,
              ),
            );
          }
          if (tool == ToolDefinition.scaleLibrary) {
            return ScaleLibraryScreen(
              initialState: ScaleLibraryRouteState.fromQuery(
                state.uri.queryParameters,
              ),
            );
          }
          if (tool == ToolDefinition.interactiveFretboard) {
            return InteractiveFretboardScreen(
              initialState: FretboardRouteState.fromQuery(
                state.uri.queryParameters,
              ),
            );
          }
          if (tool == ToolDefinition.circleOfFifths) {
            return const CircleOfFifthsScreen();
          }
          if (tool == ToolDefinition.intervalTrainer) {
            return const IntervalTrainerScreen();
          }
          if (tool == ToolDefinition.repertoire) {
            return const RepertoireScreen();
          }
          return ToolPlaceholderScreen(tool: tool);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
  ref.onDispose(router.dispose);
  return router;
});

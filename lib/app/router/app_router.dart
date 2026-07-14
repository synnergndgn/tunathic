import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_screen.dart';
import 'package:tunathic/features/dashboard/presentation/dashboard_screen.dart';
import 'package:tunathic/features/metronome/presentation/metronome_screen.dart';
import 'package:tunathic/features/settings/presentation/settings_screen.dart';
import 'package:tunathic/features/tool_placeholder/presentation/not_found_screen.dart';
import 'package:tunathic/features/tool_placeholder/presentation/tool_placeholder_screen.dart';
import 'package:tunathic/features/tools/tool_definition.dart';

abstract final class AppRoutes {
  static const dashboard = '/';
  static const settings = '/settings';

  static String tool(ToolDefinition tool) => '/tools/${tool.id}';
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
          return ToolPlaceholderScreen(tool: tool);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
  ref.onDispose(router.dispose);
  return router;
});

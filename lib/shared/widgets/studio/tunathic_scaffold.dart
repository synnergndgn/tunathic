import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/shared/widgets/studio/studio_background.dart';

/// The shell every Tunathic screen is built in.
///
/// It exists so a screen never re-decides what the backdrop, the app bar and
/// the maximum content width are — that is the whole of what makes the pages
/// look like one product.
final class TunathicScaffold extends StatelessWidget {
  const TunathicScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.showSignalLines = false,
    this.maxContentWidth = AppSpacing.contentMaxWidth,
    this.bottomDock,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool showSignalLines;

  /// Content is centred and capped so a tablet gets a readable column instead
  /// of a stretched one.
  final double maxContentWidth;

  /// A control dock pinned under the content, outside the scroll area.
  final Widget? bottomDock;

  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final studio = StudioTheme.of(context);
    return Scaffold(
      backgroundColor: studio.backdropBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const _InstrumentAppBarFace(),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          ...actions,
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: StudioBackground(
        showSignalLines: showSignalLines,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: bottomDock == null
                  ? body
                  : Column(
                      children: [
                        Expanded(child: body),
                        bottomDock!,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _InstrumentAppBarFace extends StatelessWidget {
  const _InstrumentAppBarFace();

  @override
  Widget build(BuildContext context) {
    final studio = StudioTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              Colors.white.withValues(alpha: isDark ? 0.08 : 0.82),
              studio.panelRaised,
            ),
            studio.panel,
            Color.alphaBlend(
              Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              studio.panel,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _AppBarBevelPainter(
          edge: studio.panelBorderStrong,
          isDark: isDark,
        ),
      ),
    );
  }
}

final class _AppBarBevelPainter extends CustomPainter {
  const _AppBarBevelPainter({required this.edge, required this.isDark});

  final Color edge;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.width, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.10 : 0.85)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      Paint()
        ..color = edge
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.36 : 0.16)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_AppBarBevelPainter oldDelegate) =>
      oldDelegate.edge != edge || oldDelegate.isDark != isDark;
}
